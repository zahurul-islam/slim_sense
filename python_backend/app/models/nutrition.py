from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime


class FoodLogBase(BaseModel):
    """Base food log model with common attributes"""
    food_name: str
    meal_type: str  # breakfast, lunch, dinner, snack
    calories: int = Field(..., ge=0)
    protein: float = Field(..., ge=0)
    carbs: float = Field(..., ge=0)
    fat: float = Field(..., ge=0)
    serving_size: float = Field(..., gt=0)
    serving_unit: str
    is_favorite: bool = False


class FoodLogCreate(FoodLogBase):
    """Model for creating a new food log"""
    user_id: str
    logged_at: Optional[datetime] = None
    photo_url: Optional[str] = None
    fiber: Optional[float] = None
    sugar: Optional[float] = None
    sodium: Optional[float] = None
    cholesterol: Optional[float] = None
    brand: Optional[str] = None
    barcode: Optional[str] = None
    is_custom: bool = False


class FoodLog(FoodLogBase):
    """Complete food log model with all attributes"""
    id: str
    user_id: str
    logged_at: datetime
    created_at: datetime
    photo_url: Optional[str] = None
    fiber: Optional[float] = None
    sugar: Optional[float] = None
    sodium: Optional[float] = None
    cholesterol: Optional[float] = None
    brand: Optional[str] = None
    barcode: Optional[str] = None
    is_custom: bool = False

    class Config:
        orm_mode = True


class NutritionSummary(BaseModel):
    """Summary of nutritional intake for a day"""
    total_calories: int
    total_protein: float
    total_carbs: float
    total_fat: float
    total_fiber: Optional[float] = None
    calorie_goal: Optional[int] = None
    protein_goal: Optional[int] = None
    carbs_goal: Optional[int] = None
    fat_goal: Optional[int] = None
    meal_breakdown: Dict[str, List[FoodLog]]
    remaining_calories: Optional[int] = None
    nutrient_percentages: Optional[Dict[str, float]] = None

    class Config:
        orm_mode = True


class FoodSearchResult(BaseModel):
    """Model for food search results"""
    food_name: str
    serving_size: float
    serving_unit: str
    calories: Optional[int] = None
    photo_url: Optional[str] = None
    brand: Optional[str] = None
    barcode: Optional[str] = None
    is_custom: bool = False


class FoodNutritionDetails(BaseModel):
    """Detailed nutrition information for a food item"""
    food_name: str
    serving_size: float
    serving_unit: str
    calories: int
    protein: float
    carbs: float
    fat: float
    fiber: Optional[float] = None
    sugar: Optional[float] = None
    sodium: Optional[float] = None
    cholesterol: Optional[float] = None
    photo_url: Optional[str] = None
    brand: Optional[str] = None
    barcode: Optional[str] = None
    micronutrients: Optional[Dict[str, Any]] = None


class MealRecommendation(BaseModel):
    """Model for meal recommendations"""
    recipe_name: str
    calories: int
    protein: float
    carbs: float
    fat: float
    ingredients: List[str]
    preparation_steps: List[str]
    nutrition_facts: Dict[str, Any]
    photo_url: Optional[str] = None
    prep_time_minutes: Optional[int] = None
    cook_time_minutes: Optional[int] = None
    meal_type: str
    difficulty: Optional[str] = None
    tags: List[str] = []
