from ..config import settings
from ..models.nutrition import (
    FoodLog, 
    FoodLogCreate, 
    NutritionSummary, 
    FoodSearchResult,
    FoodNutritionDetails
)
from ..utils.exception_handler import handle_exceptions

import aiohttp
import json
import logging
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
import firebase_admin
from firebase_admin import firestore


class NutritionService:
    """Service for nutrition-related functionality"""
    
    def __init__(self):
        """Initialize the nutrition service with necessary connections"""
        # Initialize Firestore DB
        self.db = firestore.client() if firebase_admin._apps else None
        if not self.db:
            logging.warning("Firestore not initialized - nutrition storage features will be limited")
            
        # Nutritionix API credentials
        self.nutritionix_app_id = settings.NUTRITIONIX_APP_ID
        self.nutritionix_api_key = settings.NUTRITIONIX_API_KEY
        
        if not self.nutritionix_app_id or not self.nutritionix_api_key:
            logging.warning("Nutritionix credentials not found - food search and lookup features will be limited")

    @handle_exceptions
    async def search_food(self, query: str, limit: int = 10) -> List[FoodSearchResult]:
        """
        Search for food items by name using Nutritionix API
        
        Args:
            query: Food name or description to search for
            limit: Maximum number of results to return
            
        Returns:
            List of food search results
        """
        if not self.nutritionix_app_id or not self.nutritionix_api_key:
            raise ValueError("Nutritionix credentials not configured")
            
        async with aiohttp.ClientSession() as session:
            url = "https://trackapi.nutritionix.com/v2/search/instant"
            headers = {
                "x-app-id": self.nutritionix_app_id,
                "x-app-key": self.nutritionix_api_key
            }
            params = {
                "query": query,
                "detailed": "true"
            }
            
            async with session.get(url, headers=headers, params=params) as response:
                if response.status != 200:
                    error_text = await response.text()
                    raise ValueError(f"Nutritionix API error: {error_text}")
                    
                data = await response.json()
                results = []
                
                # Process common foods
                if "common" in data and data["common"]:
                    for item in data["common"][:limit]:
                        results.append(FoodSearchResult(
                            food_name=item["food_name"],
                            serving_size=item.get("serving_qty", 1.0),
                            serving_unit=item.get("serving_unit", "serving"),
                            calories=item.get("nf_calories"),
                            photo_url=item.get("photo", {}).get("thumb"),
                            is_custom=False
                        ))
                
                # Process branded foods
                if "branded" in data and data["branded"]:
                    for item in data["branded"][:limit]:
                        results.append(FoodSearchResult(
                            food_name=item["food_name"],
                            serving_size=item.get("serving_qty", 1.0),
                            serving_unit=item.get("serving_unit", "serving"),
                            calories=item.get("nf_calories"),
                            photo_url=item.get("photo", {}).get("thumb"),
                            brand=item.get("brand_name"),
                            barcode=item.get("nix_item_id"),
                            is_custom=False
                        ))
                        
                return results[:limit]

    @handle_exceptions
    async def get_food_nutrition(
        self, 
        food_name: str, 
        serving_size: float = 1.0,
        serving_unit: str = "serving",
        brand: Optional[str] = None
    ) -> FoodNutritionDetails:
        """
        Get detailed nutrition information for a food item
        
        Args:
            food_name: Name of the food
            serving_size: Size of the serving
            serving_unit: Unit of the serving (e.g., grams, cup)
            brand: Optional brand name for packaged foods
            
        Returns:
            Detailed nutrition information
        """
        if not self.nutritionix_app_id or not self.nutritionix_api_key:
            raise ValueError("Nutritionix credentials not configured")
            
        async with aiohttp.ClientSession() as session:
            url = "https://trackapi.nutritionix.com/v2/natural/nutrients"
            headers = {
                "x-app-id": self.nutritionix_app_id,
                "x-app-key": self.nutritionix_api_key,
                "Content-Type": "application/json"
            }
            
            # Construct query
            query = f"{serving_size} {serving_unit} {food_name}"
            if brand:
                query += f" by {brand}"
                
            payload = {
                "query": query,
                "timezone": "US/Eastern"
            }
            
            async with session.post(url, headers=headers, json=payload) as response:
                if response.status != 200:
                    error_text = await response.text()
                    raise ValueError(f"Nutritionix API error: {error_text}")
                    
                data = await response.json()
                
                if not data.get("foods") or len(data["foods"]) == 0:
                    raise ValueError(f"No nutrition information found for {food_name}")
                    
                food = data["foods"][0]
                
                return FoodNutritionDetails(
                    food_name=food["food_name"],
                    serving_size=food.get("serving_qty", serving_size),
                    serving_unit=food.get("serving_unit", serving_unit),
                    calories=int(food.get("nf_calories", 0)),
                    protein=float(food.get("nf_protein", 0)),
                    carbs=float(food.get("nf_total_carbohydrate", 0)),
                    fat=float(food.get("nf_total_fat", 0)),
                    fiber=float(food.get("nf_dietary_fiber", 0)) if "nf_dietary_fiber" in food else None,
                    sugar=float(food.get("nf_sugars", 0)) if "nf_sugars" in food else None,
                    sodium=float(food.get("nf_sodium", 0)) if "nf_sodium" in food else None,
                    cholesterol=float(food.get("nf_cholesterol", 0)) if "nf_cholesterol" in food else None,
                    photo_url=food.get("photo", {}).get("thumb"),
                    brand=food.get("brand_name"),
                    micronutrients={
                        "saturated_fat": food.get("nf_saturated_fat"),
                        "potassium": food.get("nf_potassium"),
                        "trans_fat": food.get("nf_trans_fatty_acid"),
                        "vitamin_a": food.get("nf_vitamin_a_dv"),
                        "vitamin_c": food.get("nf_vitamin_c_dv"),
                        "calcium": food.get("nf_calcium_dv"),
                        "iron": food.get("nf_iron_dv")
                    }
                )

    @handle_exceptions
    async def lookup_barcode(self, barcode: str) -> FoodNutritionDetails:
        """
        Look up food information by barcode
        
        Args:
            barcode: UPC/EAN barcode
            
        Returns:
            Detailed nutrition information for the product
        """
        if not self.nutritionix_app_id or not self.nutritionix_api_key:
            raise ValueError("Nutritionix credentials not configured")
            
        async with aiohttp.ClientSession() as session:
            url = "https://trackapi.nutritionix.com/v2/search/item"
            headers = {
                "x-app-id": self.nutritionix_app_id,
                "x-app-key": self.nutritionix_api_key
            }
            params = {
                "upc": barcode,
                "claims": "true"
            }
            
            async with session.get(url, headers=headers, params=params) as response:
                if response.status != 200:
                    error_text = await response.text()
                    raise ValueError(f"Nutritionix API error: {error_text}")
                    
                data = await response.json()
                
                if not data.get("foods") or len(data["foods"]) == 0:
                    raise ValueError(f"No product found for barcode {barcode}")
                    
                food = data["foods"][0]
                
                return FoodNutritionDetails(
                    food_name=food["food_name"],
                    serving_size=food.get("serving_qty", 1.0),
                    serving_unit=food.get("serving_unit", "serving"),
                    calories=int(food.get("nf_calories", 0)),
                    protein=float(food.get("nf_protein", 0)),
                    carbs=float(food.get("nf_total_carbohydrate", 0)),
                    fat=float(food.get("nf_total_fat", 0)),
                    fiber=float(food.get("nf_dietary_fiber", 0)) if "nf_dietary_fiber" in food else None,
                    sugar=float(food.get("nf_sugars", 0)) if "nf_sugars" in food else None,
                    sodium=float(food.get("nf_sodium", 0)) if "nf_sodium" in food else None,
                    cholesterol=float(food.get("nf_cholesterol", 0)) if "nf_cholesterol" in food else None,
                    photo_url=food.get("photo", {}).get("thumb"),
                    brand=food.get("brand_name"),
                    barcode=barcode,
                    micronutrients={
                        "saturated_fat": food.get("nf_saturated_fat"),
                        "potassium": food.get("nf_potassium"),
                        "trans_fat": food.get("nf_trans_fatty_acid"),
                        "vitamin_a": food.get("nf_vitamin_a_dv"),
                        "vitamin_c": food.get("nf_vitamin_c_dv"),
                        "calcium": food.get("nf_calcium_dv"),
                        "iron": food.get("nf_iron_dv")
                    }
                )

    @handle_exceptions
    async def add_food_log(self, food_log: FoodLogCreate) -> str:
        """
        Add a new food log entry to the database
        
        Args:
            food_log: Food log data to add
            
        Returns:
            ID of the newly created food log
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot add food log")
            
        # Set current time if not provided
        if not food_log.logged_at:
            food_log.logged_at = datetime.utcnow()
            
        # Convert to dict for Firestore
        food_log_dict = food_log.dict()
        
        # Add created_at timestamp
        food_log_dict["created_at"] = datetime.utcnow()
        
        # Add to database
        doc_ref = self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_food_logs").document()
        doc_ref.set(food_log_dict)
        
        return doc_ref.id

    @handle_exceptions
    async def get_food_logs_by_date(self, user_id: str, date: datetime) -> List[FoodLog]:
        """
        Get all food logs for a user on a specific date
        
        Args:
            user_id: User ID
            date: Date to get logs for
            
        Returns:
            List of food logs for the specified date
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot retrieve food logs")
            
        # Calculate start and end of the day in UTC
        start_date = datetime(date.year, date.month, date.day, 0, 0, 0)
        end_date = start_date + timedelta(days=1)
        
        # Query database
        query = (
            self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_food_logs")
            .where("user_id", "==", user_id)
            .where("logged_at", ">=", start_date)
            .where("logged_at", "<", end_date)
            .order_by("logged_at")
        )
        
        docs = query.stream()
        
        # Convert to model objects
        food_logs = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            food_logs.append(FoodLog(**data))
            
        return food_logs

    @handle_exceptions
    async def update_food_log(self, food_log_id: str, user_id: str, update_data: Dict[str, Any]) -> bool:
        """
        Update an existing food log
        
        Args:
            food_log_id: ID of the food log to update
            user_id: User ID for verification
            update_data: Data fields to update
            
        Returns:
            True if update was successful
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot update food log")
            
        # Get the document
        doc_ref = self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_food_logs").document(food_log_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise ValueError(f"Food log with ID {food_log_id} not found")
            
        # Verify owner
        if doc.to_dict().get("user_id") != user_id:
            raise ValueError("Cannot update food log: user ID mismatch")
            
        # Update the document
        doc_ref.update(update_data)
        
        return True

    @handle_exceptions
    async def delete_food_log(self, food_log_id: str, user_id: str) -> bool:
        """
        Delete a food log
        
        Args:
            food_log_id: ID of the food log to delete
            user_id: User ID for verification
            
        Returns:
            True if deletion was successful
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot delete food log")
            
        # Get the document
        doc_ref = self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_food_logs").document(food_log_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise ValueError(f"Food log with ID {food_log_id} not found")
            
        # Verify owner
        if doc.to_dict().get("user_id") != user_id:
            raise ValueError("Cannot delete food log: user ID mismatch")
            
        # Delete the document
        doc_ref.delete()
        
        return True

    @handle_exceptions
    async def get_favorite_foods(self, user_id: str) -> List[FoodLog]:
        """
        Get all favorite food logs for a user
        
        Args:
            user_id: User ID
            
        Returns:
            List of favorite food logs
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot retrieve favorite foods")
            
        # Query database
        query = (
            self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_food_logs")
            .where("user_id", "==", user_id)
            .where("is_favorite", "==", True)
            .order_by("food_name")
        )
        
        docs = query.stream()
        
        # Convert to model objects
        favorite_foods = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            favorite_foods.append(FoodLog(**data))
            
        return favorite_foods

    @handle_exceptions
    async def get_daily_nutrition_summary(self, user_id: str, date: datetime) -> NutritionSummary:
        """
        Get a summary of nutritional intake for a specific date
        
        Args:
            user_id: User ID
            date: Date to get summary for
            
        Returns:
            Nutrition summary for the specified date
        """
        # Get food logs for the date
        food_logs = await self.get_food_logs_by_date(user_id, date)
        
        # Calculate totals
        total_calories = 0
        total_protein = 0.0
        total_carbs = 0.0
        total_fat = 0.0
        total_fiber = 0.0
        
        # Organize logs by meal type
        meal_breakdown = {
            "breakfast": [],
            "lunch": [],
            "dinner": [],
            "snack": []
        }
        
        for log in food_logs:
            total_calories += log.calories
            total_protein += log.protein
            total_carbs += log.carbs
            total_fat += log.fat
            total_fiber += log.fiber if log.fiber else 0.0
            
            meal_type = log.meal_type.lower()
            if meal_type in meal_breakdown:
                meal_breakdown[meal_type].append(log)
            else:
                # Default to snack if unknown meal type
                meal_breakdown["snack"].append(log)
                
        # Get user's nutrition goals (if available)
        calorie_goal = None
        protein_goal = None
        carbs_goal = None
        fat_goal = None
        
        if self.db:
            user_doc = self.db.collection("users").document(user_id).get()
            if user_doc.exists:
                user_data = user_doc.to_dict()
                calorie_goal = user_data.get("calorie_goal")
                protein_goal = user_data.get("protein_goal")
                carbs_goal = user_data.get("carbs_goal")
                fat_goal = user_data.get("fat_goal")
                
        # Calculate remaining calories
        remaining_calories = calorie_goal - total_calories if calorie_goal else None
        
        # Calculate nutrient percentages
        nutrient_percentages = None
        if total_calories > 0:
            nutrient_percentages = {
                "protein": (total_protein * 4 / total_calories) * 100 if total_calories > 0 else 0,
                "carbs": (total_carbs * 4 / total_calories) * 100 if total_calories > 0 else 0,
                "fat": (total_fat * 9 / total_calories) * 100 if total_calories > 0 else 0
            }
            
        return NutritionSummary(
            total_calories=total_calories,
            total_protein=total_protein,
            total_carbs=total_carbs,
            total_fat=total_fat,
            total_fiber=total_fiber,
            calorie_goal=calorie_goal,
            protein_goal=protein_goal,
            carbs_goal=carbs_goal,
            fat_goal=fat_goal,
            meal_breakdown=meal_breakdown,
            remaining_calories=remaining_calories,
            nutrient_percentages=nutrient_percentages
        )
