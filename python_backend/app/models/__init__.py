# Import models to make them accessible from the models package
from .user import UserBase, UserCreate, UserUpdate, UserInDB
from .weight import WeightLog, WeightLogCreate, WeightStats
from .nutrition import FoodLog, FoodLogCreate, NutritionSummary, MealRecommendation
from .ai import WeightLossRecommendation, WorkoutRecommendation, PromptTemplate
