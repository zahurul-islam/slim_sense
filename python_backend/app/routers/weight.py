from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional
from datetime import datetime
from ..models.weight import WeightLog, WeightLogCreate, WeightStats
from ..models.user import UserInDB
from ..services.weight_service import WeightService
from ..utils.auth import get_current_user
from ..utils.exception_handler import handle_exceptions

router = APIRouter()
weight_service = WeightService()

@router.post("/log", response_model=str)
@handle_exceptions
async def add_weight_log(
    weight_log: WeightLogCreate,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Add a new weight log entry
    """
    # Ensure the user ID matches
    if weight_log.user_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="Cannot add weight log for another user"
        )
        
    log_id = await weight_service.add_weight_log(weight_log=weight_log)
    return log_id

@router.get("/logs", response_model=List[WeightLog])
@handle_exceptions
async def get_weight_logs(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    limit: int = Query(100, ge=1, le=1000),
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Get weight logs for a user within a date range
    """
    # Parse dates if provided
    start_datetime = None
    end_datetime = None
    
    if start_date:
        try:
            start_datetime = datetime.strptime(start_date, "%Y-%m-%d")
        except ValueError:
            raise HTTPException(
                status_code=400,
                detail="Invalid start_date format. Use YYYY-MM-DD"
            )
            
    if end_date:
        try:
            end_datetime = datetime.strptime(end_date, "%Y-%m-%d")
        except ValueError:
            raise HTTPException(
                status_code=400,
                detail="Invalid end_date format. Use YYYY-MM-DD"
            )
            
    logs = await weight_service.get_weight_logs(
        user_id=current_user.id,
        start_date=start_datetime,
        end_date=end_datetime,
        limit=limit
    )
    return logs

@router.put("/log/{log_id}", response_model=bool)
@handle_exceptions
async def update_weight_log(
    log_id: str,
    update_data: dict,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Update an existing weight log
    """
    success = await weight_service.update_weight_log(
        weight_log_id=log_id,
        user_id=current_user.id,
        update_data=update_data
    )
    return success

@router.delete("/log/{log_id}", response_model=bool)
@handle_exceptions
async def delete_weight_log(
    log_id: str,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Delete a weight log
    """
    success = await weight_service.delete_weight_log(
        weight_log_id=log_id,
        user_id=current_user.id
    )
    return success

@router.get("/stats", response_model=WeightStats)
@handle_exceptions
async def get_weight_stats(
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Get weight statistics for a user
    """
    stats = await weight_service.get_weight_stats(user_id=current_user.id)
    return stats
