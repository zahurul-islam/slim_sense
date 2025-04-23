from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any


class PromptTemplate(BaseModel):
    """Template for LLM prompts"""
    template: str
    variables: Dict[str, Any]


class WeightLossRecommendation(BaseModel):
    """Model for AI weight loss recommendations"""
    daily_calorie_target: int
    macronutrient_breakdown: Dict[str, Any]  # protein, carbs, fat percentages
    sample_meal_plan: Dict[str, List[Dict[str, Any]]]  # meals by day and type
    recommended_exercises: List[Dict[str, Any]]  # exercise recommendations
    weekly_progression_goals: List[str]  # goals for each week
    explanation: str  # explanation of the recommendation
    tips: Optional[List[str]] = None  # additional tips
    challenges: Optional[List[str]] = None  # potential challenges
    

class WorkoutRecommendation(BaseModel):
    """Model for workout recommendations"""
    warm_up: List[Dict[str, Any]]  # warm up exercises
    main_exercises: List[Dict[str, Any]]  # main workout exercises with sets/reps
    cool_down: List[Dict[str, Any]]  # cool down exercises
    progression_tips: List[str]  # tips for progression
    estimated_calories_burned: Optional[int] = None
    workout_duration_minutes: int
    difficulty_level: str
    fitness_level: str
    equipment_needed: List[str]
    explanation: str  # explanation of the workout
    
    
class DietaryAnalysis(BaseModel):
    """Model for dietary habit analysis"""
    strengths: List[str]
    improvement_areas: List[str]
    nutrient_analysis: Dict[str, Any]
    balanced_diet_score: float
    recommendations: List[str]
    explanation: str
    
    
class WeightProgressForecast(BaseModel):
    """Model for weight progress forecasts"""
    weekly_projections: List[Dict[str, Any]]
    expected_completion_date: Optional[str] = None
    sustainable_rate: float  # sustainable weight loss rate
    calorie_deficit_required: int
    challenges: List[str]
    recommendations: List[str]
    explanation: str
