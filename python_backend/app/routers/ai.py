from fastapi import APIRouter, Depends, HTTPException
from typing import List, Optional
from ..models.ai import (
    WeightLossRecommendation,
    WorkoutRecommendation,
    DietaryAnalysis,
    WeightProgressForecast
)
from ..models.nutrition import MealRecommendation
from ..models.user import UserInDB
from ..services.ai_service import AIService
from ..utils.auth import get_current_user
from ..utils.exception_handler import handle_exceptions

router = APIRouter()
ai_service = AIService()

@router.post("/weight-loss-plan", response_model=WeightLossRecommendation)
@handle_exceptions
async def get_weight_loss_recommendation(
    target_weight: float,
    dietary_preferences: Optional[List[str]] = None,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Generate a personalized weight loss plan based on user profile and preferences
    """
    preferences = dietary_preferences or current_user.dietary_preferences or []
    recommendation = await ai_service.get_weight_loss_recommendation(
        user=current_user,
        target_weight=target_weight,
        dietary_preferences=preferences
    )
    return recommendation

@router.post("/meal", response_model=MealRecommendation)
@handle_exceptions
async def get_meal_recommendation(
    calories: int,
    meal_type: str,
    dietary_restrictions: Optional[List[str]] = None,
    available_ingredients: Optional[List[str]] = None,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Generate a meal recommendation based on calorie target and dietary preferences
    """
    restrictions = dietary_restrictions or current_user.dietary_preferences or []
    recommendation = await ai_service.get_meal_recommendation(
        calories=calories,
        meal_type=meal_type,
        dietary_restrictions=restrictions,
        available_ingredients=available_ingredients
    )
    return recommendation

@router.post("/workout", response_model=WorkoutRecommendation)
@handle_exceptions
async def get_workout_recommendation(
    fitness_level: str,
    goal: str,
    available_minutes: int,
    available_equipment: Optional[List[str]] = None,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Generate a personalized workout plan based on fitness level, goals, and available equipment
    """
    equipment = available_equipment or ["none"]
    recommendation = await ai_service.get_workout_recommendation(
        fitness_level=fitness_level,
        goal=goal,
        available_minutes=available_minutes,
        available_equipment=equipment
    )
    return recommendation

@router.post("/analyze-diet", response_model=DietaryAnalysis)
@handle_exceptions
async def analyze_dietary_habits(
    food_logs_days: int = 7,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Analyze dietary habits based on recent food logs
    """
    from ..services.nutrition_service import NutritionService
    from datetime import datetime, timedelta
    
    nutrition_service = NutritionService()
    
    # Get recent food logs
    food_logs = []
    for day_offset in range(food_logs_days):
        log_date = datetime.utcnow() - timedelta(days=day_offset)
        day_logs = await nutrition_service.get_food_logs_by_date(
            user_id=current_user.id,
            date=log_date
        )
        food_logs.extend([log.dict() for log in day_logs])
    
    if not food_logs:
        raise HTTPException(
            status_code=404,
            detail=f"No food logs found in the last {food_logs_days} days"
        )
        
    analysis = await ai_service.analyze_dietary_habits(
        food_logs=food_logs,
        user=current_user
    )
    return analysis

@router.post("/forecast-weight", response_model=WeightProgressForecast)
@handle_exceptions
async def forecast_weight_progress(
    target_weight: Optional[float] = None,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Generate a forecast of weight progress based on current trends
    """
    from ..services.weight_service import WeightService
    from datetime import datetime, timedelta
    
    weight_service = WeightService()
    
    # Get recent weight logs
    weight_logs = await weight_service.get_weight_logs(
        user_id=current_user.id,
        start_date=datetime.utcnow() - timedelta(days=90),  # Last 90 days
        end_date=datetime.utcnow()
    )
    
    if not weight_logs:
        raise HTTPException(
            status_code=404,
            detail="No weight logs found to generate forecast"
        )
        
    # Use specified target weight or default to user's target
    target = target_weight or current_user.target_weight
    
    forecast = await ai_service.forecast_weight_progress(
        user=current_user,
        weight_logs=[log.dict() for log in weight_logs],
        target_weight=target
    )
    return forecast
