# backend/app/routes/notifications.py
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.database import get_db
from app.core.auth import get_current_user
from app.schemas.citizen import citizen_schema
from app.schemas.citizen.notification import NotificationResponse
from app.services.citizen.notification_repository import (
    get_unread_notifications,
    mark_notification_as_read
)

router = APIRouter(prefix="/notifications", tags=["Notifications"])

@router.get("/unread", response_model=list[NotificationResponse])
async def get_unread_notifications_endpoint(
    current_user: citizen_schema.Citizen = Depends(get_current_user),
    db: Prisma = Depends(get_db)
):
    """Get all unread notifications for the current user"""
    return await get_unread_notifications(db, current_user.citizen_id)

@router.post("/{notification_id}/read", response_model=NotificationResponse)
async def mark_notification_as_read_endpoint(
    notification_id: str,
    current_user: citizen_schema.Citizen = Depends(get_current_user),
    db: Prisma = Depends(get_db)
):
    """Mark a notification as read"""
    notification = await mark_notification_as_read(db, notification_id)
    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    return notification