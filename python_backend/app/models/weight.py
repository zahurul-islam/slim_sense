from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class WeightLogBase(BaseModel):
    """Base weight log model with common attributes"""
    weight_kg: float = Field(..., ge=20, le=300)
    notes: Optional[str] = None


class WeightLogCreate(WeightLogBase):
    """Model for creating a new weight log"""
    user_id: str
    logged_at: Optional[datetime] = None


class WeightLog(WeightLogBase):
    """Complete weight log model with all attributes"""
    id: str
    user_id: str
    logged_at: datetime
    created_at: datetime

    class Config:
        orm_mode = True


class WeightStats(BaseModel):
    """Weight statistics for a user"""
    current_weight: float
    starting_weight: float
    target_weight: float
    total_change: float
    weekly_change: Optional[float] = None
    monthly_change: Optional[float] = None
    bmi: Optional[float] = None
    bmi_category: Optional[str] = None
    weight_logs: List[WeightLog] = []
    trend_data: Optional[List[dict]] = None
    target_date: Optional[datetime] = None
    estimated_completion_date: Optional[datetime] = None
    
    class Config:
        orm_mode = True
