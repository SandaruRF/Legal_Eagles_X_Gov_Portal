# backend/app/schemas/notification/notification_schema.py
from datetime import datetime
from enum import Enum
from pydantic import BaseModel
from typing import Optional

from prisma.enums import NotificationPriority, NotificationType

class NotificationBase(BaseModel):
    message: str
    priority: NotificationPriority
    type: NotificationType
    is_read: bool = False
    email_sent: bool = False  # Track if email was sent
    email_sent_at: Optional[datetime] = None  # When email was sent

class NotificationCreate(NotificationBase):
    citizen_id: str
    appointment_id: Optional[str] = None
    document_id: Optional[str] = None

class Notification(NotificationBase):
    notification_id: str
    created_at: datetime
    citizen_id: str
    appointment_id: Optional[str] = None
    document_id: Optional[str] = None

    class Config:
        orm_mode = True

class AppointmentNotificationResponse(BaseModel):
    notification_id: str
    priority: str = "high"
    read_status: bool
    type: str = "appointment_reminder"
    service_name: str
    appointment_datetime: datetime
    email_sent: bool  # Include email status in response

class RenewalNotificationResponse(BaseModel):
    notification_id: str
    priority: str
    read_status: bool
    type: str = "renewal_reminder"
    document_type: str
    expiry_date: datetime
    days_until_expiry: int
    email_sent: bool  # Include email status in response