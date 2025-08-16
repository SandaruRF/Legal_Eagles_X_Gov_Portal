# backend/app/schemas/notification.py
from datetime import datetime
from pydantic import BaseModel
from typing import Optional
from prisma.enums import NotificationPriority, NotificationType

class NotificationBase(BaseModel):
    message: str
    priority: NotificationPriority = NotificationPriority.Medium
    type: NotificationType
    citizen_id: str
    appointment_id: Optional[str] = None
    document_id: Optional[str] = None

class NotificationCreate(NotificationBase):
    pass

class NotificationResponse(NotificationBase):
    notification_id: str
    is_read: bool
    created_at: datetime
    
    class Config:
        from_attributes = True