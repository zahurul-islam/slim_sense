from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional
from datetime import datetime
from ..models.nutrition import (
    FoodLog,
    FoodLogCreate,
    NutritionSummary,
    FoodSearchResult,
    FoodNutritionDetails
)
from ..models.user import UserInDB
from ..services.nutrition_service import NutritionService
from ..utils.auth import get_current_user
from ..utils.exception_handler import handle_exceptions

router = APIRouter()
nutrition_service = NutritionService()

@router.get("/search", response_model=List[FoodSearchResult])
@handle_exceptions
async def search_food(
    query: str,
    limit: int = Query(10, ge=1, le=50),
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Search for food items by name
    """
    results = await nutrition_service.search_food(query=query, limit=limit)
    return results

@router.get("/nutrition", response_model=FoodNutritionDetails)
@handle_exceptions
async def get_food_nutrition(
    food_name: str,
    serving_size: float = 1.0,
    serving_unit: str = "serving",
    brand: Optional[str] = None,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Get detailed nutrition information for a food item
    """
    details = await nutrition_service.get_food_nutrition(
        food_name=food_name,
        serving_size=serving_size,
        serving_unit=serving_unit,
        brand=brand
    )
    return details

@router.get("/barcode/{barcode}", response_model=FoodNutritionDetails)
@handle_exceptions
async def lookup_barcode(
    barcode: str,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Look up food information by barcode
    """
    details = await nutrition_service.lookup_barcode(barcode=barcode)
    return details

@router.post("/log", response_model=str)
@handle_exceptions
async def add_food_log(
    food_log: FoodLogCreate,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Add a new food log entry
    """
    # Ensure the user ID matches
    if food_log.user_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="Cannot add food log for another user"
        )
        
    log_id = await nutrition_service.add_food_log(food_log=food_log)
    return log_id

@router.get("/logs/{date}", response_model=List[FoodLog])
@handle_exceptions
async def get_food_logs_by_date(
    date: str,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Get all food logs for a user on a specific date (format: YYYY-MM-DD)
    """
    try:
        log_date = datetime.strptime(date, "%Y-%m-%d")
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Invalid date format. Use YYYY-MM-DD"
        )
        
    logs = await nutrition_service.get_food_logs_by_date(
        user_id=current_user.id,
        date=log_date
    )
    return logs

@router.put("/log/{log_id}", response_model=bool)
@handle_exceptions
async def update_food_log(
    log_id: str,
    update_data: dict,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Update an existing food log
    """
    success = await nutrition_service.update_food_log(
        food_log_id=log_id,
        user_id=current_user.id,
        update_data=update_data
    )
    return success

@router.delete("/log/{log_id}", response_model=bool)
@handle_exceptions
async def delete_food_log(
    log_id: str,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Delete a food log
    """
    success = await nutrition_service.delete_food_log(
        food_log_id=log_id,
        user_id=current_user.id
    )
    return success

@router.get("/favorites", response_model=List[FoodLog])
@handle_exceptions
async def get_favorite_foods(
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Get all favorite food logs for a user
    """
    favorites = await nutrition_service.get_favorite_foods(user_id=current_user.id)
    return favorites

@router.get("/summary/{date}", response_model=NutritionSummary)
@handle_exceptions
async def get_daily_nutrition_summary(
    date: str,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Get a summary of nutritional intake for a specific date (format: YYYY-MM-DD)
    """
    try:
        summary_date = datetime.strptime(date, "%Y-%m-%d")
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Invalid date format. Use YYYY-MM-DD"
        )
        
    summary = await nutrition_service.get_daily_nutrition_summary(
        user_id=current_user.id,
        date=summary_date
    )
    return summary
