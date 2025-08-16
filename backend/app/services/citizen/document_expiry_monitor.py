# backend/app/services/citizen/document_expiry_monitor.py
import asyncio
from datetime import datetime, timedelta
from prisma import Prisma
from app.core.database import get_db
from app.services.citizen.notification_repository import create_notification
from app.schemas.citizen.notification import NotificationCreate
from prisma.enums import NotificationType, NotificationPriority

CHECK_INTERVAL_HOURS = 6  # Check every 6 hours

async def document_expiry_monitor():
    """Monitors document expiry and sends notifications"""
    db: Prisma = await get_db()
    
    while True:
        try:
            now = datetime.now()
            
            # Documents expiring soon
            documents = await db.digitalvaultdocument.find_many(
                where={
                    "expiry_date": {
                        "not": None,
                        "gt": now  # Only future expiry dates
                    }
                },
                include={
                    "citizen": True
                }
            )
            
            for doc in documents:
                await check_and_notify(db, doc, now)
            
            await asyncio.sleep(CHECK_INTERVAL_HOURS * 3600)
            
        except Exception as e:
            logger.error(f"Document monitor error: {str(e)}")
            await asyncio.sleep(3600)  # Wait 1 hour on error

async def check_and_notify(db: Prisma, document, current_time: datetime):
    """Check if notification should be sent and trigger it"""
    if not document.expiry_date:
        return
    
    days_remaining = (document.expiry_date - current_time).days
    
    # Notification thresholds (30, 7, and 1 days before expiry)
    if days_remaining not in [1, 7, 30]:
        return
    
    # Check if notification already sent for this threshold
    existing = await db.notification.find_first(
        where={
            "document_id": document.document_id,
            "type": "DocumentExpiry",
            "message": {"contains": f"expire in {days_remaining} days"}
        }
    )
    if existing:
        return
    
    await send_expiry_notification(db, document, days_remaining)

async def send_expiry_notification(db: Prisma, document, days_remaining: int):
    """Create and send expiry notification"""
    message = (
        f"Your {document.document_type.lower()} is going to expire "
        f"on {document.expiry_date.strftime('%Y-%m-%d')} "
        f"(in {days_remaining} days). Kindly renew your document."
    )
    
    notification_data = NotificationCreate(
        message=message,
        priority=(
            NotificationPriority.High if days_remaining <= 7 
            else NotificationPriority.Medium
        ),
        type=NotificationType.DocumentExpiry,
        citizen_id=document.citizen_id,
        document_id=document.document_id,
        appointment_id=None  # Explicitly set to None
    )
    
    await create_notification(db, notification_data)