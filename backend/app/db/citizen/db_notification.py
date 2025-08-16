# backend/app/db/citizen/db_notification.py
from prisma import Prisma
from app.schemas.citizen.notification_schema import NotificationCreate
from datetime import datetime, timedelta

async def create_notification(db: Prisma, notification: NotificationCreate):
    """Create a new notification in the database"""
    return await db.notification.create(data={
        "message": notification.message,
        "priority": notification.priority,
        "type": notification.type,
        "is_read": notification.is_read,
        "citizen_id": notification.citizen_id,
        "appointment_id": notification.appointment_id,
        "document_id": notification.document_id
    })

async def get_citizen_notifications(db: Prisma, citizen_id: str, is_read: bool = None):
    """Get notifications for a citizen, optionally filtered by read status"""
    where = {"citizen_id": citizen_id}
    if is_read is not None:
        where["is_read"] = is_read
    
    return await db.notification.find_many(
        where=where,
        order={"created_at": "desc"}
    )

async def mark_notification_as_read(db: Prisma, notification_id: str):
    """Mark a notification as read"""
    return await db.notification.update(
        where={"notification_id": notification_id},
        data={"is_read": True}
    )

async def get_upcoming_appointments_for_notifications(db: Prisma):
    """Get appointments that need reminders (24 hours before)"""
    now = datetime.now()
    reminder_time = now + timedelta(hours=24)
    
    return await db.appointment.find_many(
        where={
            "appointment_datetime": {
                "gte": now,
                "lte": reminder_time
            },
            "status": "Confirmed"
        },
        include={
            "service": True,
            "documents": True,
            "citizen": True
        }
    )

async def get_expiring_documents_for_notifications(db: Prisma):
    """Get documents that are expiring soon (within 1 month)"""
    now = datetime.now()
    one_month_later = now + timedelta(days=30)
    
    return await db.digitalvaultdocument.find_many(
        where={
            "expiry_date": {
                "gte": now,
                "lte": one_month_later
            }
        },
        include={
            "citizen": True
        }
    )

async def get_citizen_email(db: Prisma, citizen_id: str):
    """Get a citizen's email address"""
    citizen = await db.citizen.find_unique(
        where={"citizen_id": citizen_id},
        select={"email": True}
    )
    return citizen.email if citizen else None