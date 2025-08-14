from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class FeedbackBase(BaseModel):
    rating: int = Field(..., ge=1, le=5, description="Rating from 1 to 5")
    comment: Optional[str] = Field(None, description="Optional feedback comment")


class FeedbackResponse(FeedbackBase):
    feedback_id: str
    appointment_id: str
    citizen_id: str
    submitted_at: datetime

    # Related data
    citizen_name: Optional[str] = None
    citizen_email: Optional[str] = None
    service_name: Optional[str] = None
    service_description: Optional[str] = None
    appointment_datetime: Optional[datetime] = None
    appointment_reference: Optional[str] = None

    class Config:
        from_attributes = True


class FeedbackListResponse(BaseModel):
    feedback: List[FeedbackResponse]
    total: int
    average_rating: float
    rating_distribution: dict
    satisfaction_rate: float  # Percentage of 4-5 star ratings


class FeedbackStatsResponse(BaseModel):
    total_feedback: int
    average_rating: float
    rating_distribution: dict  # {1: count, 2: count, ...}
    satisfaction_rate: float
    recent_feedback_count: int
    monthly_trend: List[dict]  # [{month: str, count: int, average: float}]
