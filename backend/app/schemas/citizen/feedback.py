from pydantic import BaseModel, Field, ConfigDict
from typing import Optional

class FeedbackCreate(BaseModel):
    appointment_id: str
    rating: int = Field(..., ge=1, le=5)
    comment: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
