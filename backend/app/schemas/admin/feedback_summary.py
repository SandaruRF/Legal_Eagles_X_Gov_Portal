from pydantic import BaseModel
from typing import List


class RatingDistribution(BaseModel):
    star_5: int
    star_4: int
    star_3: int
    star_2: int
    star_1: int


class RecentComment(BaseModel):
    rating: int
    comment: str
    date: str  # ISO string YYYY-MM-DD


class FeedbackSummary(BaseModel):
    total_feedback: int
    average_rating: float
    rating_distribution: RatingDistribution
    recent_comments: List[RecentComment]


class FeedbackSummaryResponse(BaseModel):
    status: str
    summary: FeedbackSummary
