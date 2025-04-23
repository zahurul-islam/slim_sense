from ..config import settings
from ..models.weight import WeightLog, WeightLogCreate, WeightStats
from ..utils.exception_handler import handle_exceptions

import logging
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
import firebase_admin
from firebase_admin import firestore
import numpy as np


class WeightService:
    """Service for weight tracking functionality"""
    
    def __init__(self):
        """Initialize the weight service with necessary connections"""
        # Initialize Firestore DB
        self.db = firestore.client() if firebase_admin._apps else None
        if not self.db:
            logging.warning("Firestore not initialized - weight tracking features will be limited")

    @handle_exceptions
    async def add_weight_log(self, weight_log: WeightLogCreate) -> str:
        """
        Add a new weight log entry to the database
        
        Args:
            weight_log: Weight log data to add
            
        Returns:
            ID of the newly created weight log
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot add weight log")
            
        # Set current time if not provided
        if not weight_log.logged_at:
            weight_log.logged_at = datetime.utcnow()
            
        # Convert to dict for Firestore
        weight_log_dict = weight_log.dict()
        
        # Add created_at timestamp
        weight_log_dict["created_at"] = datetime.utcnow()
        
        # Add to database
        doc_ref = self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_weight_logs").document()
        doc_ref.set(weight_log_dict)
        
        # Update user's current weight
        await self._update_user_weight(weight_log.user_id, weight_log.weight_kg)
        
        return doc_ref.id

    @handle_exceptions
    async def get_weight_logs(
        self, 
        user_id: str, 
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        limit: int = 100
    ) -> List[WeightLog]:
        """
        Get weight logs for a user within a date range
        
        Args:
            user_id: User ID
            start_date: Start date (inclusive)
            end_date: End date (inclusive)
            limit: Maximum number of logs to return
            
        Returns:
            List of weight logs
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot retrieve weight logs")
            
        # Build query
        query = (
            self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_weight_logs")
            .where("user_id", "==", user_id)
            .order_by("logged_at", direction=firestore.Query.DESCENDING)
            .limit(limit)
        )
        
        # Add date filters if provided
        if start_date:
            query = query.where("logged_at", ">=", start_date)
        if end_date:
            end_date_plus_one = end_date + timedelta(days=1)
            query = query.where("logged_at", "<", end_date_plus_one)
            
        # Execute query
        docs = query.stream()
        
        # Convert to model objects
        weight_logs = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            weight_logs.append(WeightLog(**data))
            
        # Sort by date (ascending)
        weight_logs.sort(key=lambda x: x.logged_at)
            
        return weight_logs

    @handle_exceptions
    async def update_weight_log(
        self, 
        weight_log_id: str, 
        user_id: str, 
        update_data: Dict[str, Any]
    ) -> bool:
        """
        Update an existing weight log
        
        Args:
            weight_log_id: ID of the weight log to update
            user_id: User ID for verification
            update_data: Data fields to update
            
        Returns:
            True if update was successful
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot update weight log")
            
        # Get the document
        doc_ref = self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_weight_logs").document(weight_log_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise ValueError(f"Weight log with ID {weight_log_id} not found")
            
        # Verify owner
        if doc.to_dict().get("user_id") != user_id:
            raise ValueError("Cannot update weight log: user ID mismatch")
            
        # Update the document
        doc_ref.update(update_data)
        
        # Update user's current weight if this is the most recent entry and weight changed
        if "weight_kg" in update_data:
            latest_log = await self._get_latest_weight_log(user_id)
            if latest_log and latest_log.id == weight_log_id:
                await self._update_user_weight(user_id, update_data["weight_kg"])
        
        return True

    @handle_exceptions
    async def delete_weight_log(self, weight_log_id: str, user_id: str) -> bool:
        """
        Delete a weight log
        
        Args:
            weight_log_id: ID of the weight log to delete
            user_id: User ID for verification
            
        Returns:
            True if deletion was successful
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot delete weight log")
            
        # Get the document
        doc_ref = self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_weight_logs").document(weight_log_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise ValueError(f"Weight log with ID {weight_log_id} not found")
            
        # Verify owner
        doc_data = doc.to_dict()
        if doc_data.get("user_id") != user_id:
            raise ValueError("Cannot delete weight log: user ID mismatch")
            
        # Check if this is the latest entry
        is_latest = False
        latest_log = await self._get_latest_weight_log(user_id)
        if latest_log and latest_log.id == weight_log_id:
            is_latest = True
            
        # Delete the document
        doc_ref.delete()
        
        # Update user's current weight if needed
        if is_latest:
            new_latest = await self._get_latest_weight_log(user_id)
            if new_latest:
                await self._update_user_weight(user_id, new_latest.weight_kg)
        
        return True

    @handle_exceptions
    async def get_weight_stats(self, user_id: str) -> WeightStats:
        """
        Get weight statistics for a user
        
        Args:
            user_id: User ID
            
        Returns:
            Weight statistics
        """
        if not self.db:
            raise ValueError("Firestore not initialized - cannot retrieve weight stats")
            
        # Get user data
        user_doc = self.db.collection("users").document(user_id).get()
        if not user_doc.exists:
            raise ValueError(f"User with ID {user_id} not found")
            
        user_data = user_doc.to_dict()
        
        # Get weight logs
        all_logs = await self.get_weight_logs(user_id)
        
        if not all_logs:
            # No weight logs, use user data
            return WeightStats(
                current_weight=user_data.get("current_weight", 0),
                starting_weight=user_data.get("starting_weight", 0),
                target_weight=user_data.get("target_weight", 0),
                total_change=0,
                bmi=user_data.get("bmi"),
                bmi_category=user_data.get("bmi_category"),
                weight_logs=[]
            )
            
        # Sort logs by date
        all_logs.sort(key=lambda x: x.logged_at)
        
        # Current weight (latest log)
        current_weight = all_logs[-1].weight_kg
        
        # Starting weight (first log or user starting weight)
        starting_weight = user_data.get("starting_weight")
        if not starting_weight:
            starting_weight = all_logs[0].weight_kg
            
        # Target weight from user data
        target_weight = user_data.get("target_weight", 0)
        
        # Total change
        total_change = current_weight - starting_weight
        
        # Weekly and monthly changes
        now = datetime.utcnow()
        week_ago = now - timedelta(days=7)
        month_ago = now - timedelta(days=30)
        
        weekly_change = None
        monthly_change = None
        
        # Find log closest to a week ago
        week_ago_log = None
        min_week_diff = float('inf')
        
        for log in all_logs:
            diff = abs((log.logged_at - week_ago).total_seconds())
            if diff < min_week_diff:
                min_week_diff = diff
                week_ago_log = log
                
        if week_ago_log and min_week_diff < 86400 * 4:  # Within 4 days
            weekly_change = current_weight - week_ago_log.weight_kg
            
        # Find log closest to a month ago
        month_ago_log = None
        min_month_diff = float('inf')
        
        for log in all_logs:
            diff = abs((log.logged_at - month_ago).total_seconds())
            if diff < min_month_diff:
                min_month_diff = diff
                month_ago_log = log
                
        if month_ago_log and min_month_diff < 86400 * 7:  # Within 7 days
            monthly_change = current_weight - month_ago_log.weight_kg
            
        # Calculate BMI if height is available
        bmi = user_data.get("bmi")
        bmi_category = user_data.get("bmi_category")
        
        if not bmi and "height_cm" in user_data:
            height_m = user_data["height_cm"] / 100
            bmi = current_weight / (height_m * height_m)
            
            # Determine BMI category
            if bmi < 18.5:
                bmi_category = "Underweight"
            elif bmi < 25:
                bmi_category = "Normal"
            elif bmi < 30:
                bmi_category = "Overweight"
            else:
                bmi_category = "Obese"
                
        # Prepare trend data
        trend_data = []
        for log in all_logs:
            trend_data.append({
                "date": log.logged_at.strftime("%Y-%m-%d"),
                "weight": log.weight_kg,
                "notes": log.notes
            })
            
        # Calculate estimated completion date based on recent trend
        estimated_completion_date = None
        if len(all_logs) >= 2 and target_weight != current_weight:
            # Use the most recent 30 days or less of data
            recent_cutoff = now - timedelta(days=30)
            recent_logs = [log for log in all_logs if log.logged_at >= recent_cutoff]
            
            if len(recent_logs) >= 2:
                # Calculate average daily change
                first_recent = recent_logs[0]
                last_recent = recent_logs[-1]
                days_diff = (last_recent.logged_at - first_recent.logged_at).days
                
                if days_diff > 0:
                    avg_daily_change = (last_recent.weight_kg - first_recent.weight_kg) / days_diff
                    
                    if avg_daily_change != 0:
                        # Calculate days until target
                        weight_diff = target_weight - current_weight
                        days_to_target = int(weight_diff / avg_daily_change)
                        
                        # Ensure progress is in the right direction
                        is_losing = current_weight > target_weight
                        is_trending_down = avg_daily_change < 0
                        
                        if (is_losing and is_trending_down) or (not is_losing and not is_trending_down):
                            estimated_completion_date = now + timedelta(days=days_to_target)
                            
        # Target date from user data
        target_date = user_data.get("target_date")
                
        return WeightStats(
            current_weight=current_weight,
            starting_weight=starting_weight,
            target_weight=target_weight,
            total_change=total_change,
            weekly_change=weekly_change,
            monthly_change=monthly_change,
            bmi=bmi,
            bmi_category=bmi_category,
            weight_logs=all_logs,
            trend_data=trend_data,
            target_date=target_date,
            estimated_completion_date=estimated_completion_date
        )

    @handle_exceptions
    async def _get_latest_weight_log(self, user_id: str) -> Optional[WeightLog]:
        """
        Get the most recent weight log for a user
        
        Args:
            user_id: User ID
            
        Returns:
            The most recent weight log, or None if no logs exist
        """
        if not self.db:
            return None
            
        query = (
            self.db.collection(settings.APP_NAME.lower().replace(" ", "_") + "_weight_logs")
            .where("user_id", "==", user_id)
            .order_by("logged_at", direction=firestore.Query.DESCENDING)
            .limit(1)
        )
        
        docs = list(query.stream())
        
        if not docs:
            return None
            
        doc = docs[0]
        data = doc.to_dict()
        data["id"] = doc.id
        
        return WeightLog(**data)

    @handle_exceptions
    async def _update_user_weight(self, user_id: str, weight_kg: float) -> bool:
        """
        Update the current weight in the user's profile
        
        Args:
            user_id: User ID
            weight_kg: New weight value
            
        Returns:
            True if update was successful
        """
        if not self.db:
            return False
            
        # Get user document
        user_ref = self.db.collection("users").document(user_id)
        user_doc = user_ref.get()
        
        if not user_doc.exists:
            return False
            
        # Update user data
        user_data = user_doc.to_dict()
        
        # If this is the first weight, set starting weight too
        if "starting_weight" not in user_data or user_data["starting_weight"] is None:
            user_ref.update({
                "current_weight": weight_kg,
                "starting_weight": weight_kg,
                "updated_at": datetime.utcnow()
            })
        else:
            # Just update current weight
            user_ref.update({
                "current_weight": weight_kg,
                "updated_at": datetime.utcnow()
            })
            
        # Update BMI if height is available
        if "height_cm" in user_data:
            height_m = user_data["height_cm"] / 100
            bmi = weight_kg / (height_m * height_m)
            
            # Determine BMI category
            if bmi < 18.5:
                bmi_category = "Underweight"
            elif bmi < 25:
                bmi_category = "Normal"
            elif bmi < 30:
                bmi_category = "Overweight"
            else:
                bmi_category = "Obese"
                
            user_ref.update({
                "bmi": bmi,
                "bmi_category": bmi_category
            })
            
        return True
