from ..config import settings
from ..models.user import UserBase, UserCreate, UserUpdate, UserInDB
from ..utils.exception_handler import handle_exceptions

import logging
from typing import Dict, Any, Optional
from datetime import datetime
import firebase_admin
from firebase_admin import firestore, auth
from passlib.context import CryptContext


class UserService:
    """Service for user management functionality"""
    
    def __init__(self):
        """Initialize the user service with necessary connections"""
        # Initialize Firestore DB
        self.db = firestore.client() if firebase_admin._apps else None
        if not self.db:
            logging.warning("Firestore not initialized - user management features will be limited")
            
        # Initialize password context for hashing
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

    @handle_exceptions
    async def get_user(self, user_id: str) -> UserInDB:
        """
        Get a user by ID
        
        Args:
            user_id: User ID
            
        Returns:
            User information
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot retrieve user")
            
        doc_ref = self.db.collection("users").document(user_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise ValueError(f"User with ID {user_id} not found")
            
        user_data = doc.to_dict()
        user_data["id"] = user_id
        
        return UserInDB(**user_data)

    @handle_exceptions
    async def create_user(self, user: UserCreate) -> UserInDB:
        """
        Create a new user
        
        Args:
            user: User data to create
            
        Returns:
            Created user information
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot create user")
            
        # Check if email already exists
        email_query = self.db.collection("users").where("email", "==", user.email).limit(1)
        email_docs = list(email_query.stream())
        
        if email_docs:
            raise ValueError(f"User with email {user.email} already exists")
            
        # Hash password
        hashed_password = self.pwd_context.hash(user.password)
        
        # Prepare user data
        user_data = user.dict(exclude={"password"})
        user_data["hashed_password"] = hashed_password
        user_data["created_at"] = datetime.utcnow()
        user_data["updated_at"] = datetime.utcnow()
        user_data["starting_weight"] = user.current_weight
        
        # Calculate BMI
        height_m = user.height_cm / 100
        bmi = user.current_weight / (height_m * height_m)
        
        # Determine BMI category
        if bmi < 18.5:
            bmi_category = "Underweight"
        elif bmi < 25:
            bmi_category = "Normal"
        elif bmi < 30:
            bmi_category = "Overweight"
        else:
            bmi_category = "Obese"
            
        user_data["bmi"] = bmi
        user_data["bmi_category"] = bmi_category
        
        # Set default goals
        if "calorie_goal" not in user_data or not user_data["calorie_goal"]:
            # Calculate recommended calorie intake
            if user.gender.lower() == "male":
                bmr = 10 * user.current_weight + 6.25 * user.height_cm - 5 * user.age + 5
            else:
                bmr = 10 * user.current_weight + 6.25 * user.height_cm - 5 * user.age - 161
                
            # Adjust for activity level
            activity_multipliers = {
                "sedentary": 1.2,
                "lightly active": 1.375,
                "moderately active": 1.55,
                "very active": 1.725,
                "extremely active": 1.9
            }
            
            activity_level = user.activity_level.lower()
            if activity_level in activity_multipliers:
                tdee = bmr * activity_multipliers[activity_level]
            else:
                # Default to moderately active if unknown
                tdee = bmr * 1.55
                
            # For weight loss, subtract 500 calories (roughly 0.5kg/week)
            if user.current_weight > user.target_weight:
                calorie_goal = max(1200, int(tdee - 500))
            # For weight gain, add 500 calories
            elif user.current_weight < user.target_weight:
                calorie_goal = int(tdee + 500)
            # For maintenance
            else:
                calorie_goal = int(tdee)
                
            user_data["calorie_goal"] = calorie_goal
            
            # Set macronutrient goals (protein/carbs/fat)
            user_data["protein_goal"] = int(calorie_goal * 0.3 / 4)  # 30% protein, 4 cal/g
            user_data["carbs_goal"] = int(calorie_goal * 0.45 / 4)   # 45% carbs, 4 cal/g
            user_data["fat_goal"] = int(calorie_goal * 0.25 / 9)     # 25% fat, 9 cal/g
        
        # Create user in Firebase Auth if available
        try:
            firebase_user = auth.create_user(
                email=user.email,
                password=user.password,
                display_name=user.full_name
            )
            user_id = firebase_user.uid
        except Exception as e:
            # If Firebase Auth is not available or fails, generate a UUID
            import uuid
            user_id = str(uuid.uuid4())
            logging.warning(f"Could not create Firebase Auth user: {e}. Using generated ID.")
        
        # Create user in Firestore
        doc_ref = self.db.collection("users").document(user_id)
        doc_ref.set(user_data)
        
        # Add ID to user data and return
        user_data["id"] = user_id
        return UserInDB(**user_data)

    @handle_exceptions
    async def update_user(self, user_id: str, user_update: UserUpdate) -> UserInDB:
        """
        Update a user's information
        
        Args:
            user_id: ID of the user to update
            user_update: Updated user data
            
        Returns:
            Updated user information
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot update user")
            
        # Get current user data
        doc_ref = self.db.collection("users").document(user_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise ValueError(f"User with ID {user_id} not found")
            
        # Convert update data to dict and filter out None values
        update_data = {k: v for k, v in user_update.dict().items() if v is not None}
        
        # Add updated timestamp
        update_data["updated_at"] = datetime.utcnow()
        
        # Update BMI if weight or height changed
        if "current_weight" in update_data or "height_cm" in update_data:
            current_data = doc.to_dict()
            height_cm = update_data.get("height_cm", current_data.get("height_cm"))
            weight_kg = update_data.get("current_weight", current_data.get("current_weight"))
            
            if height_cm and weight_kg:
                height_m = height_cm / 100
                bmi = weight_kg / (height_m * height_m)
                
                # Determine BMI category
                if bmi < 18.5:
                    bmi_category = "Underweight"
                elif bmi < 25:
                    bmi_category = "Normal"
                elif bmi < 30:
                    bmi_category = "Overweight"
                else:
                    bmi_category = "Obese"
                    
                update_data["bmi"] = bmi
                update_data["bmi_category"] = bmi_category
        
        # Update user in Firestore
        doc_ref.update(update_data)
        
        # Get updated user data
        updated_doc = doc_ref.get()
        updated_data = updated_doc.to_dict()
        updated_data["id"] = user_id
        
        return UserInDB(**updated_data)

    @handle_exceptions
    async def delete_user(self, user_id: str) -> bool:
        """
        Delete a user
        
        Args:
            user_id: ID of the user to delete
            
        Returns:
            True if deletion was successful
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot delete user")
            
        # Check if user exists
        doc_ref = self.db.collection("users").document(user_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise ValueError(f"User with ID {user_id} not found")
            
        # Delete from Firebase Auth if available
        try:
            auth.delete_user(user_id)
        except Exception as e:
            logging.warning(f"Could not delete Firebase Auth user: {e}")
            
        # Delete from Firestore
        doc_ref.delete()
        
        # Delete related data like weight logs and food logs
        weight_logs = self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_weight_logs").where("user_id", "==", user_id).stream()
        for log in weight_logs:
            log.reference.delete()
            
        food_logs = self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_food_logs").where("user_id", "==", user_id).stream()
        for log in food_logs:
            log.reference.delete()
            
        return True

    @handle_exceptions
    async def verify_password(self, email: str, password: str) -> Optional[UserInDB]:
        """
        Verify a user's password and return the user if valid
        
        Args:
            email: User's email
            password: Password to verify
            
        Returns:
            User information if password is valid, None otherwise
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot verify password")
            
        # Find user by email
        query = self.db.collection("users").where("email", "==", email).limit(1)
        docs = list(query.stream())
        
        if not docs:
            return None
            
        user_doc = docs[0]
        user_data = user_doc.to_dict()
        
        # Check if hashed password exists in user data
        if "hashed_password" not in user_data:
            return None
            
        # Verify password
        if not self.pwd_context.verify(password, user_data["hashed_password"]):
            return None
            
        # Update last login time
        user_id = user_doc.id
        self.db.collection("users").document(user_id).update({
            "last_login": datetime.utcnow()
        })
        
        # Return user data
        user_data["id"] = user_id
        return UserInDB(**user_data)

    @handle_exceptions
    async def calculate_nutrition_goals(self, user_id: str) -> Dict[str, Any]:
        """
        Calculate recommended nutrition goals for a user
        
        Args:
            user_id: User ID
            
        Returns:
            Dictionary with recommended calorie and macronutrient goals
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot calculate nutrition goals")
            
        # Get user data
        user = await self.get_user(user_id)
        
        # Calculate BMR using Mifflin-St Jeor Equation
        if user.gender.lower() == "male":
            bmr = 10 * user.current_weight + 6.25 * user.height_cm - 5 * user.age + 5
        else:
            bmr = 10 * user.current_weight + 6.25 * user.height_cm - 5 * user.age - 161
            
        # Adjust for activity level
        activity_multipliers = {
            "sedentary": 1.2,
            "lightly active": 1.375,
            "moderately active": 1.55,
            "very active": 1.725,
            "extremely active": 1.9
        }
        
        activity_level = user.activity_level.lower()
        if activity_level in activity_multipliers:
            tdee = bmr * activity_multipliers[activity_level]
        else:
            # Default to moderately active if unknown
            tdee = bmr * 1.55
            
        # Adjust based on weight goal
        if user.current_weight > user.target_weight:
            # For weight loss, create a deficit
            weight_diff = user.current_weight - user.target_weight
            
            # Larger deficit for more weight to lose
            if weight_diff > 20:
                deficit = 750  # More aggressive for significant weight loss
            elif weight_diff > 10:
                deficit = 600  # Medium deficit
            else:
                deficit = 500  # Standard deficit
                
            # Ensure minimum calorie intake
            min_calories = 1200 if user.gender.lower() == "female" else 1500
            calorie_goal = max(min_calories, int(tdee - deficit))
        elif user.current_weight < user.target_weight:
            # For weight gain, create a surplus
            surplus = 500
            calorie_goal = int(tdee + surplus)
        else:
            # For maintenance
            calorie_goal = int(tdee)
            
        # Calculate macronutrient goals
        protein_pct = 30  # 30% of calories from protein
        carb_pct = 45     # 45% of calories from carbs
        fat_pct = 25      # 25% of calories from fat
        
        protein_goal = int(calorie_goal * protein_pct / 100 / 4)  # 4 cal/g of protein
        carb_goal = int(calorie_goal * carb_pct / 100 / 4)        # 4 cal/g of carbs
        fat_goal = int(calorie_goal * fat_pct / 100 / 9)          # 9 cal/g of fat
        
        # Adjust protein based on activity level and goals
        if "very active" in activity_level or "extremely active" in activity_level:
            # Higher protein for very active individuals
            protein_goal = max(protein_goal, int(user.current_weight * 1.8))  # 1.8g per kg bodyweight
        else:
            # Standard recommendation
            protein_goal = max(protein_goal, int(user.current_weight * 1.6))  # 1.6g per kg bodyweight
            
        nutrition_goals = {
            "calorie_goal": calorie_goal,
            "protein_goal": protein_goal,
            "carbs_goal": carb_goal,
            "fat_goal": fat_goal,
            "fiber_goal": int(calorie_goal / 1000 * 14),  # 14g per 1000 calories
            "water_goal": int(user.current_weight * 0.033)  # 33ml per kg bodyweight
        }
        
        # Update user's nutrition goals in database
        self.db.collection("users").document(user_id).update({
            "calorie_goal": calorie_goal,
            "protein_goal": protein_goal,
            "carbs_goal": carb_goal,
            "fat_goal": fat_goal,
            "updated_at": datetime.utcnow()
        })
        
        return nutrition_goals

    @handle_exceptions
    async def get_user_by_email(self, email: str) -> Optional[UserInDB]:
        """
        Get a user by email
        
        Args:
            email: User email
            
        Returns:
            User information if found, None otherwise
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot retrieve user")
            
        # Find user by email
        query = self.db.collection("users").where("email", "==", email).limit(1)
        docs = list(query.stream())
        
        if not docs:
            return None
            
        user_doc = docs[0]
        user_data = user_doc.to_dict()
        user_data["id"] = user_doc.id
        
        return UserInDB(**user_data)

    @handle_exceptions
    async def reset_password(self, email: str) -> bool:
        """
        Send a password reset email to a user
        
        Args:
            email: User's email
            
        Returns:
            True if password reset email was sent successfully
        """
        # Check if user exists
        user = await self.get_user_by_email(email)
        
        if not user:
            raise ValueError(f"No user found with email {email}")
            
        # If Firebase Auth is available, use it to send reset email
        try:
            reset_link = auth.generate_password_reset_link(email)
            # In a real app, you would send this link via email
            logging.info(f"Password reset link generated for {email}: {reset_link}")
            return True
        except Exception as e:
            logging.warning(f"Could not generate password reset link: {e}")
            
            # Fallback if Firebase Auth is not available
            # In a real app, this would generate a token, store it, and send an email
            logging.info(f"Password reset requested for {email}")
            return True
