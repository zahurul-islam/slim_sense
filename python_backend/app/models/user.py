from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime


class UserBase(BaseModel):
    """Base user model with common attributes"""
    email: EmailStr
    full_name: str
    gender: str
    age: int = Field(..., ge=13, le=120)
    height_cm: float = Field(..., ge=50, le=300)
    activity_level: str
    dietary_preferences: List[str] = []
    has_completed_profile: bool = False


class UserCreate(UserBase):
    """Model for creating new users"""
    password: str = Field(..., min_length=8)
    current_weight: float = Field(..., ge=20, le=300)
    target_weight: float = Field(..., ge=20, le=300)


class UserUpdate(BaseModel):
    """Model for updating user information"""
    full_name: Optional[str] = None
    gender: Optional[str] = None
    age: Optional[int] = Field(None, ge=13, le=120)
    height_cm: Optional[float] = Field(None, ge=50, le=300)
    current_weight: Optional[float] = Field(None, ge=20, le=300)
    target_weight: Optional[float] = Field(None, ge=20, le=300)
    activity_level: Optional[str] = None
    dietary_preferences: Optional[List[str]] = None
    profile_image_url: Optional[str] = None
    has_completed_profile: Optional[bool] = None
    calorie_goal: Optional[int] = None
    protein_goal: Optional[int] = None
    carbs_goal: Optional[int] = None
    fat_goal: Optional[int] = None


class UserInDB(UserBase):
    """Model representing a user in the database"""
    id: str
    created_at: datetime
    updated_at: datetime
    current_weight: float
    target_weight: float
    starting_weight: float
    bmi: Optional[float] = None
    bmi_category: Optional[str] = None
    calorie_goal: Optional[int] = None
    protein_goal: Optional[int] = None
    carbs_goal: Optional[int] = None
    fat_goal: Optional[int] = None
    profile_image_url: Optional[str] = None
    has_premium: bool = False
    last_login: Optional[datetime] = None

    class Config:
        orm_mode = True
