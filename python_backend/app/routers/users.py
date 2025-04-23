from fastapi import APIRouter, Depends, HTTPException, Body
from typing import Dict, Any
from ..models.user import UserCreate, UserUpdate, UserInDB
from ..services.user_service import UserService
from ..utils.auth import get_current_user, create_access_token
from ..utils.exception_handler import handle_exceptions
from ..config import settings

router = APIRouter()
user_service = UserService()

@router.post("/register", response_model=UserInDB)
@handle_exceptions
async def register_user(user: UserCreate):
    """
    Register a new user
    """
    new_user = await user_service.create_user(user=user)
    return new_user

@router.post("/login", response_model=Dict[str, Any])
@handle_exceptions
async def login(email: str = Body(...), password: str = Body(...)):
    """
    Login a user and return an access token
    """
    user = await user_service.verify_password(email=email, password=password)
    
    if not user:
        raise HTTPException(
            status_code=401,
            detail="Incorrect email or password"
        )
        
    # Create access token
    token_data = {"sub": user.id}
    access_token = create_access_token(token_data)
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user
    }

@router.get("/me", response_model=UserInDB)
@handle_exceptions
async def get_current_user_info(current_user: UserInDB = Depends(get_current_user)):
    """
    Get information about the current logged-in user
    """
    return current_user

@router.put("/me", response_model=UserInDB)
@handle_exceptions
async def update_current_user(
    update_data: UserUpdate,
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Update information for the current logged-in user
    """
    updated_user = await user_service.update_user(
        user_id=current_user.id,
        user_update=update_data
    )
    return updated_user

@router.delete("/me", response_model=bool)
@handle_exceptions
async def delete_current_user(current_user: UserInDB = Depends(get_current_user)):
    """
    Delete the current logged-in user account
    """
    success = await user_service.delete_user(user_id=current_user.id)
    return success

@router.post("/reset-password", response_model=Dict[str, str])
@handle_exceptions
async def reset_password(email: str = Body(...)):
    """
    Send a password reset email to a user
    """
    await user_service.reset_password(email=email)
    return {"message": "Password reset instructions sent to your email"}

@router.get("/nutrition-goals", response_model=Dict[str, Any])
@handle_exceptions
async def get_nutrition_goals(current_user: UserInDB = Depends(get_current_user)):
    """
    Calculate recommended nutrition goals for the current user
    """
    goals = await user_service.calculate_nutrition_goals(user_id=current_user.id)
    return goals
