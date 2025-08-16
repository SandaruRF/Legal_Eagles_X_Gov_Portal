import asyncio
from datetime import datetime, timedelta
from prisma import Prisma
from app.core.database import get_db
from app.services.citizen.notification_repository import create_notification
from app.schemas.citizen.notification import NotificationCreate
from prisma.enums import NotificationType, NotificationPriority, AppointmentStatus
import logging

logger = logging.getLogger(__name__)
CHECK_INTERVAL_SECONDS = 30  # Check every 30 seconds

async def appointment_status_monitor():
    """Monitors Appointment table for status changes and sends notifications"""
    db: Prisma = get_db()
    last_checked = datetime.now()
    
    while True:
        try:
            # Get appointments with status changes since last check
            appointments = await db.appointment.find_many(
                where={
                    "created_at": {"gt": last_checked},
                    "status": {"not": "NoShow"}  # Ignore NoShow
                },
                include={
                    "service": True,
                    "citizen": True
                }
            )
            
            for appt in appointments:
                # Skip if status didn't actually change (updated_at can trigger for other fields)
                history = await db.appointment.find_first(
                    where={"appointment_id": appt.appointment_id},
                    include={"history": True}  # Requires enabling Prisma's history feature
                )
                if not has_status_changed(history):
                    continue
                    
                await send_status_notification(db, appt)
            
            last_checked = datetime.now()
            await asyncio.sleep(CHECK_INTERVAL_SECONDS)
            
        except Exception as e:
            logger.error(f"Status monitor error: {str(e)}")
            await asyncio.sleep(60)  # Wait longer on error

def has_status_changed(history) -> bool:
    """Check if status changed in the history"""
    # Implementation depends on your Prisma history setup
    # Alternative: Compare with last known status in a cache
    return True  # Placeholder

# backend/app/services/citizen/appointment_status_monitor.py
async def send_status_notification(db: Prisma, appointment):
    """Generate and send notification for status change"""
    status = appointment.status.value
    action_required = ""
    
    if status == "Booked":
        action_required = "Please prepare your documents as listed in your appointment details."
    elif status == "Cancelled":
        action_required = "You may reschedule this appointment at your convenience."
    
    message = (
        f"Your appointment for {appointment.service.name} on "
        f"{appointment.appointment_datetime.strftime('%Y-%m-%d at %H:%M')} "
        f"is now {status}. {action_required}"
    )

    notification_data = NotificationCreate(
        message=message,
        priority=(
            NotificationPriority.High 
            if status in ["Cancelled", "Confirmed"] 
            else NotificationPriority.Medium
        ),
        type=NotificationType.AppointmentStatusChange,
        citizen_id=appointment.citizen_id,
        appointment_id=appointment.appointment_id
    )
    
    await create_notification(db, notification_data)