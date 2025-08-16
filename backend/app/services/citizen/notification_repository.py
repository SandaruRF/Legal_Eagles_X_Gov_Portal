# backend/app/db/repositories/notification_repository.py
from prisma import Prisma
from app.core.database import get_db
from app.core.websocket_manager import websocket_manager
from app.core.email_service import send_notification_email
from app.schemas.citizen.notification import NotificationCreate
from prisma import Notification
from typing import Optional
from typing import Optional, List
# backend/app/services/citizen/notification_repository.py
async def create_notification(db: Prisma, notification_data: NotificationCreate) -> Optional[Notification]:
    """Create a new notification with type-specific handling"""
    notification = await db.notification.create({
        "message": notification_data.message,
        "priority": notification_data.priority,
        "type": notification_data.type,
        "citizen_id": notification_data.citizen_id,
        "appointment_id": notification_data.appointment_id,
        "document_id": notification_data.document_id
    })

    citizen = await db.citizen.find_unique(where={"citizen_id": notification_data.citizen_id})
    if not citizen:
        return notification

    # WebSocket notification
    await websocket_manager.send_personal_message({
        "notification_id": notification.notification_id,
        "message": notification.message,
        "type": notification.type,
        "is_read": notification.is_read,
        "created_at": notification.created_at.isoformat(),
        "citizen_id": notification.citizen_id
    }, notification_data.citizen_id)

    # Email notification
    appointment = None
    if notification_data.appointment_id:
        appointment = await db.appointment.find_unique(
            where={"appointment_id": notification_data.appointment_id},
            include={"service": True}
        )

    email_subject = f"Gov-Portal Notification: {notification.type}"
    if notification.type == "AppointmentStatusChange" and appointment:
        email_subject = f"Appointment Status Update: {appointment.status}"

    await send_notification_email(
        email=citizen.email,
        subject=email_subject,
        message=notification.message,
        notification_type=notification.type,
        appointment=appointment
    )

    return notification

async def mark_notification_as_read(db: Prisma, notification_id: str) -> Optional[Notification]:
    """Mark a notification as read"""
    return await db.notification.update(
        where={"notification_id": notification_id},
        data={"is_read": True}
    )

async def get_unread_notifications(db: Prisma, citizen_id: str) -> List[Notification]:
    """Get all unread notifications for a citizen"""
    return await db.notification.find_many(
        where={
            "citizen_id": citizen_id,
            "is_read": False
        },
        order={"created_at": "desc"}
    )