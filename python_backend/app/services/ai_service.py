from ..config import settings
from ..models.ai import (
    WeightLossRecommendation,
    WorkoutRecommendation,
    PromptTemplate,
    DietaryAnalysis,
    WeightProgressForecast
)
from ..models.nutrition import MealRecommendation
from ..models.user import UserInDB
from ..utils.exception_handler import handle_exceptions

import json
import logging
from typing import List, Dict, Any, Optional

# Conditionally import libraries based on API key availability
try:
    from openai import OpenAI
    from langchain.prompts import PromptTemplate as LangchainPromptTemplate
    from langchain.chains import LLMChain
    from langchain_openai import ChatOpenAI
    OPENAI_AVAILABLE = bool(settings.OPENAI_API_KEY)
except (ImportError, Exception) as e:
    logging.warning(f"OpenAI/Langchain integration not available: {e}")
    OPENAI_AVAILABLE = False


class AIService:
    """Service for AI-powered recommendations and analysis"""
    
    def __init__(self):
        """Initialize the AI service with the required clients"""
        # Initialize OpenAI client if API key is available
        if OPENAI_AVAILABLE:
            self.openai_client = OpenAI(api_key=settings.OPENAI_API_KEY)
            self.llm = ChatOpenAI(
                model="gpt-3.5-turbo-1106",
                temperature=0.7,
                api_key=settings.OPENAI_API_KEY
            )
        else:
            self.openai_client = None
            self.llm = None
            logging.warning("OpenAI client not available - AI features will be limited")
            
        # Define system prompts for different recommendation types
        self.weight_loss_system_prompt = """
        You are a professional nutritionist and fitness coach specializing in sustainable weight loss.
        Provide scientifically sound, safe, and personalized weight loss recommendations.
        Focus on sustainable habits rather than quick fixes.
        Consider the person's gender, age, activity level, and dietary preferences.
        Your advice should be specific, actionable, and backed by nutritional science.
        """
        
        self.meal_system_prompt = """
        You are a professional chef and nutritionist. 
        Create delicious, healthy recipes that match the requested specifications.
        Focus on making meals that are satisfying, nutritionally balanced, and simple to prepare.
        Include precise measurements and clear cooking instructions.
        Ensure the meal meets the calorie and macronutrient targets provided.
        """
        
        self.workout_system_prompt = """
        You are a certified personal trainer specializing in creating effective workouts.
        Design safe, appropriate exercises based on the person's fitness level and goals.
        Include proper form descriptions to prevent injury.
        Structure the workout with appropriate warm-up and cool-down exercises.
        Provide progression options for different fitness levels.
        Your recommendations should follow established exercise science principles.
        """

    @handle_exceptions
    async def get_weight_loss_recommendation(
        self,
        user: UserInDB,
        target_weight: float,
        dietary_preferences: List[str]
    ) -> WeightLossRecommendation:
        """
        Generate a personalized weight loss plan for a user
        
        Args:
            user: User profile data
            target_weight: Target weight in kg
            dietary_preferences: List of dietary preferences or restrictions
            
        Returns:
            WeightLossRecommendation object with personalized plan
        """
        if not OPENAI_AVAILABLE:
            raise ValueError("OpenAI integration not available - cannot generate weight loss recommendation")
            
        # Calculate BMI
        height_m = user.height_cm / 100
        bmi = user.current_weight / (height_m * height_m)
        
        # Determine weight loss rate based on current weight and BMI
        if bmi > 30:
            # For obese individuals, 1-2 kg per week can be safe
            weekly_rate = "1-2 kg"
        elif bmi > 25:
            # For overweight individuals
            weekly_rate = "0.5-1 kg"
        else:
            # For those with BMI in normal range
            weekly_rate = "0.25-0.5 kg"
            
        # Format dietary preferences
        preferences_text = ", ".join(dietary_preferences) if dietary_preferences else "No specific preferences"
        
        # Create the prompt
        prompt = f"""
        Create a personalized weight loss plan for:
        - Current weight: {user.current_weight} kg
        - Target weight: {target_weight} kg
        - Gender: {user.gender}
        - Age: {user.age}
        - Height: {user.height_cm} cm
        - BMI: {bmi:.1f}
        - Activity level: {user.activity_level}
        - Dietary preferences: {preferences_text}
        
        The plan should help them lose weight at a healthy rate of {weekly_rate} per week.
        
        Format your response as a JSON object with the following structure:
        {{
            "daily_calorie_target": number,
            "macronutrient_breakdown": {{
                "protein": number,  // percentage
                "carbs": number,    // percentage
                "fat": number       // percentage
            }},
            "sample_meal_plan": {{
                "day1": [
                    {{
                        "meal_type": "breakfast",
                        "meal_name": string,
                        "foods": [string],
                        "calories": number,
                        "protein": number,
                        "carbs": number,
                        "fat": number
                    }},
                    // lunch, dinner, snacks
                ],
                // day2, day3
            }},
            "recommended_exercises": [
                {{
                    "name": string,
                    "description": string,
                    "duration": string,
                    "intensity": string,
                    "frequency": string
                }}
            ],
            "weekly_progression_goals": [string],
            "explanation": string,
            "tips": [string],
            "challenges": [string]
        }}
        
        Ensure that your recommendations are medically sound, follow established nutrition and exercise guidelines, and are tailored to the individual's characteristics.
        """
        
        # Get response from OpenAI
        response = self.openai_client.chat.completions.create(
            model="gpt-3.5-turbo-1106",
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": self.weight_loss_system_prompt},
                {"role": "user", "content": prompt}
            ]
        )
        
        # Parse the response
        try:
            result = json.loads(response.choices[0].message.content)
            return WeightLossRecommendation(**result)
        except Exception as e:
            logging.error(f"Error parsing AI response: {e}")
            raise ValueError(f"Failed to generate a valid weight loss recommendation: {e}")

    @handle_exceptions
    async def get_meal_recommendation(
        self,
        calories: int,
        meal_type: str,
        dietary_restrictions: List[str],
        available_ingredients: Optional[List[str]] = None,
    ) -> MealRecommendation:
        """
        Generate a meal recommendation based on calorie and nutrition requirements
        
        Args:
            calories: Target calories for the meal
            meal_type: Type of meal (breakfast, lunch, dinner, snack)
            dietary_restrictions: List of dietary restrictions
            available_ingredients: Optional list of ingredients to use
            
        Returns:
            MealRecommendation object with recipe details
        """
        if not OPENAI_AVAILABLE:
            raise ValueError("OpenAI integration not available - cannot generate meal recommendation")
            
        # Format dietary restrictions
        restrictions_text = ", ".join(dietary_restrictions) if dietary_restrictions else "None"
        
        # Format available ingredients
        ingredients_text = (
            f"Using these available ingredients: {', '.join(available_ingredients)}"
            if available_ingredients
            else "Using commonly available ingredients"
        )
        
        # Calculate macronutrient targets based on meal type
        if meal_type.lower() == "breakfast":
            protein_pct = 25  # Higher protein for breakfast
            carbs_pct = 50
            fat_pct = 25
        elif meal_type.lower() == "snack":
            protein_pct = 30  # Higher protein for snacks
            carbs_pct = 40
            fat_pct = 30
        else:  # lunch or dinner
            protein_pct = 30
            carbs_pct = 40
            fat_pct = 30
            
        # Calculate macros in grams
        protein_g = (calories * (protein_pct / 100)) / 4  # 4 cals per gram of protein
        carbs_g = (calories * (carbs_pct / 100)) / 4     # 4 cals per gram of carbs
        fat_g = (calories * (fat_pct / 100)) / 9         # 9 cals per gram of fat
        
        # Create the prompt
        prompt = f"""
        Create a delicious and nutritious {meal_type} recipe:
        - Target calories: {calories} calories
        - Target protein: ~{protein_g:.0f}g ({protein_pct}%)
        - Target carbs: ~{carbs_g:.0f}g ({carbs_pct}%)
        - Target fat: ~{fat_g:.0f}g ({fat_pct}%)
        - Dietary restrictions: {restrictions_text}
        - {ingredients_text}
        
        Format your response as a JSON object with the following structure:
        {{
            "recipe_name": string,
            "calories": number,
            "protein": number,  // in grams
            "carbs": number,    // in grams
            "fat": number,      // in grams
            "ingredients": [string],  // with quantities
            "preparation_steps": [string],
            "nutrition_facts": {{
                "calories": number,
                "protein": number,
                "carbs": number,
                "fat": number,
                "fiber": number,
                "sugar": number
            }},
            "prep_time_minutes": number,
            "cook_time_minutes": number,
            "meal_type": string,
            "difficulty": string,
            "tags": [string]
        }}
        
        The recipe should be practical, easy to prepare, and flavorful.
        """
        
        # Get response from OpenAI
        response = self.openai_client.chat.completions.create(
            model="gpt-3.5-turbo-1106",
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": self.meal_system_prompt},
                {"role": "user", "content": prompt}
            ]
        )
        
        # Parse the response
        try:
            result = json.loads(response.choices[0].message.content)
            return MealRecommendation(**result)
        except Exception as e:
            logging.error(f"Error parsing AI response: {e}")
            raise ValueError(f"Failed to generate a valid meal recommendation: {e}")

    @handle_exceptions
    async def get_workout_recommendation(
        self,
        fitness_level: str,
        goal: str,
        available_minutes: int,
        available_equipment: List[str],
    ) -> WorkoutRecommendation:
        """
        Generate a personalized workout plan
        
        Args:
            fitness_level: User's fitness level (beginner, intermediate, advanced)
            goal: Workout goal (e.g., weight loss, muscle gain, endurance)
            available_minutes: Minutes available for workout
            available_equipment: List of available equipment
            
        Returns:
            WorkoutRecommendation object with workout details
        """
        if not OPENAI_AVAILABLE:
            raise ValueError("OpenAI integration not available - cannot generate workout recommendation")
            
        # Format available equipment
        equipment_text = ", ".join(available_equipment) if available_equipment else "No equipment (bodyweight only)"
        
        # Create the prompt
        prompt = f"""
        Create a personalized workout plan for:
        - Fitness level: {fitness_level}
        - Goal: {goal}
        - Available time: {available_minutes} minutes
        - Available equipment: {equipment_text}
        
        Format your response as a JSON object with the following structure:
        {{
            "warm_up": [
                {{
                    "name": string,
                    "description": string,
                    "duration": string,
                    "reps": number  // if applicable
                }}
            ],
            "main_exercises": [
                {{
                    "name": string,
                    "description": string,
                    "sets": number,
                    "reps": number,
                    "rest_seconds": number,
                    "equipment": string,
                    "target_muscles": [string],
                    "form_tips": [string]
                }}
            ],
            "cool_down": [
                {{
                    "name": string,
                    "description": string,
                    "duration": string
                }}
            ],
            "progression_tips": [string],
            "estimated_calories_burned": number,
            "workout_duration_minutes": number,
            "difficulty_level": string,
            "fitness_level": string,
            "equipment_needed": [string],
            "explanation": string
        }}
        
        The workout should be safe, effective, and matched to the person's fitness level and goals.
        Include detailed form descriptions for each exercise to help prevent injury.
        """
        
        # Get response from OpenAI
        response = self.openai_client.chat.completions.create(
            model="gpt-3.5-turbo-1106",
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": self.workout_system_prompt},
                {"role": "user", "content": prompt}
            ]
        )
        
        # Parse the response
        try:
            result = json.loads(response.choices[0].message.content)
            return WorkoutRecommendation(**result)
        except Exception as e:
            logging.error(f"Error parsing AI response: {e}")
            raise ValueError(f"Failed to generate a valid workout recommendation: {e}")

    @handle_exceptions
    async def analyze_dietary_habits(
        self, 
        food_logs: List[Dict[str, Any]], 
        user: UserInDB
    ) -> DietaryAnalysis:
        """
        Analyze a user's dietary habits based on their food logs
        
        Args:
            food_logs: List of user's food logs
            user: User information including their goals
            
        Returns:
            DietaryAnalysis with insights and recommendations
        """
        if not OPENAI_AVAILABLE:
            raise ValueError("OpenAI integration not available - cannot analyze dietary habits")
            
        # Convert food logs to a summarized format
        food_summary = []
        for log in food_logs:
            food_summary.append({
                "food_name": log["food_name"],
                "meal_type": log["meal_type"],
                "calories": log["calories"],
                "protein": log["protein"],
                "carbs": log["carbs"],
                "fat": log["fat"],
                "logged_at": log["logged_at"].isoformat() if hasattr(log["logged_at"], "isoformat") else log["logged_at"],
            })
            
        # Calculate daily averages
        total_days = len(set([log["logged_at"].split("T")[0] for log in food_summary]))
        total_calories = sum([log["calories"] for log in food_summary])
        total_protein = sum([log["protein"] for log in food_summary])
        total_carbs = sum([log["carbs"] for log in food_summary])
        total_fat = sum([log["fat"] for log in food_summary])
        
        if total_days > 0:
            avg_daily_calories = total_calories / total_days
            avg_daily_protein = total_protein / total_days
            avg_daily_carbs = total_carbs / total_days
            avg_daily_fat = total_fat / total_days
        else:
            avg_daily_calories = total_calories
            avg_daily_protein = total_protein
            avg_daily_carbs = total_carbs
            avg_daily_fat = total_fat
            
        # Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
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
            
        # Create the prompt
        prompt = f"""
        Analyze the dietary habits for a user with the following characteristics:
        - Gender: {user.gender}
        - Age: {user.age}
        - Current weight: {user.current_weight} kg
        - Target weight: {user.target_weight} kg
        - Height: {user.height_cm} cm
        - Activity level: {user.activity_level}
        - Dietary preferences: {', '.join(user.dietary_preferences) if user.dietary_preferences else 'None specified'}
        
        Their dietary information:
        - Average daily calories: {avg_daily_calories:.0f} kcal
        - Average daily protein: {avg_daily_protein:.1f} g
        - Average daily carbs: {avg_daily_carbs:.1f} g
        - Average daily fat: {avg_daily_fat:.1f} g
        - Estimated BMR: {bmr:.0f} kcal
        - Estimated TDEE: {tdee:.0f} kcal
        
        Detailed food logs:
        {json.dumps(food_summary[:20])}  # Limit to 20 items to avoid token limits
        
        Format your response as a JSON object with the following structure:
        {{
            "strengths": [string],
            "improvement_areas": [string],
            "nutrient_analysis": {{
                "protein_adequacy": string,
                "carb_quality": string,
                "fat_quality": string,
                "micronutrient_concerns": [string],
                "hydration": string
            }},
            "balanced_diet_score": number,  // 0-10 scale
            "recommendations": [string],
            "explanation": string
        }}
        
        Base your analysis on established nutritional guidelines and best practices for sustainable weight management.
        """
        
        # Get response from OpenAI
        response = self.openai_client.chat.completions.create(
            model="gpt-3.5-turbo-1106",
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": self.weight_loss_system_prompt},
                {"role": "user", "content": prompt}
            ]
        )
        
        # Parse the response
        try:
            result = json.loads(response.choices[0].message.content)
            return DietaryAnalysis(**result)
        except Exception as e:
            logging.error(f"Error parsing AI response: {e}")
            raise ValueError(f"Failed to generate a valid dietary analysis: {e}")

    @handle_exceptions
    async def forecast_weight_progress(
        self,
        user: UserInDB,
        weight_logs: List[Dict[str, Any]],
        target_weight: float,
    ) -> WeightProgressForecast:
        """
        Generate a forecast of weight progress based on current trends
        
        Args:
            user: User profile information
            weight_logs: List of user's weight logs
            target_weight: Target weight in kg
            
        Returns:
            WeightProgressForecast with projections and recommendations
        """
        if not OPENAI_AVAILABLE:
            raise ValueError("OpenAI integration not available - cannot forecast weight progress")
            
        # Format the weight logs
        weight_data = []
        for log in weight_logs:
            weight_data.append({
                "date": log["logged_at"].isoformat() if hasattr(log["logged_at"], "isoformat") else log["logged_at"],
                "weight_kg": log["weight_kg"]
            })
            
        # Sort by date
        weight_data.sort(key=lambda x: x["date"])
        
        # Calculate current trend if enough data points
        weight_change = 0
        weekly_rate = 0
        
        if len(weight_data) >= 2:
            first_weight = weight_data[0]["weight_kg"]
            last_weight = weight_data[-1]["weight_kg"]
            first_date = weight_data[0]["date"].split("T")[0]
            last_date = weight_data[-1]["date"].split("T")[0]
            
            # Calculate days between dates
            from datetime import datetime
            date_format = "%Y-%m-%d"
            d1 = datetime.strptime(first_date, date_format)
            d2 = datetime.strptime(last_date, date_format)
            days_diff = (d2 - d1).days
            
            if days_diff > 0:
                weight_change = last_weight - first_weight
                weekly_rate = (weight_change / days_diff) * 7
        
        # Create the prompt
        prompt = f"""
        Forecast weight progress for a user with the following characteristics:
        - Gender: {user.gender}
        - Age: {user.age}
        - Current weight: {user.current_weight} kg
        - Target weight: {target_weight} kg
        - Height: {user.height_cm} cm
        - Activity level: {user.activity_level}
        
        Weight history:
        {json.dumps(weight_data)}
        
        Current trends:
        - Total weight change: {weight_change:.2f} kg
        - Weekly rate: {weekly_rate:.2f} kg per week
        
        Format your response as a JSON object with the following structure:
        {{
            "weekly_projections": [
                {{
                    "week": number,
                    "projected_weight": number,
                    "required_calorie_deficit": number
                }}
            ],
            "expected_completion_date": string,  // when target weight might be reached
            "sustainable_rate": number,  // sustainable weekly weight loss in kg
            "calorie_deficit_required": number,  // daily deficit needed
            "challenges": [string],
            "recommendations": [string],
            "explanation": string
        }}
        
        Base your forecast on established weight loss principles and the user's current trends.
        Consider that sustainable weight loss is typically 0.5-1kg per week.
        If the current trend is not leading to the target weight, provide realistic adjustments.
        """
        
        # Get response from OpenAI
        response = self.openai_client.chat.completions.create(
            model="gpt-3.5-turbo-1106",
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": self.weight_loss_system_prompt},
                {"role": "user", "content": prompt}
            ]
        )
        
        # Parse the response
        try:
            result = json.loads(response.choices[0].message.content)
            return WeightProgressForecast(**result)
        except Exception as e:
            logging.error(f"Error parsing AI response: {e}")
            raise ValueError(f"Failed to generate a valid weight progress forecast: {e}")
