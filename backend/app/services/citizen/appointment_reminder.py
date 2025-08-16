import asyncio
from datetime import datetime, timedelta
from prisma import Prisma
from app.core.database import get_db
from app.services.citizen.notification_repository import create_notification
from app.schemas.citizen.notification import NotificationCreate
from prisma.enums import NotificationType, NotificationPriority
import json

CHECK_INTERVAL_SECONDS = 60  # check every minute

async def appointment_reminder_worker():
    """Background worker to send appointment reminders 24 hours before."""
    db: Prisma = get_db()
    while True:
        now = datetime.now()
        reminder_time = datetime.now() + timedelta(hours=24)
        # Use a range instead of exact minute matching
        appointments = await db.appointment.find_many(
            where={
                "appointment_datetime": {
                    "gte": reminder_time - timedelta(minutes=5),
                    "lt": reminder_time + timedelta(minutes=5)
                }
            },
            include={
                "service": True,
                "citizen": True
            }
        )

        for appt in appointments:
            # Check if a reminder already exists for this appointment
            existing = await db.notification.find_first(
                where={
                    "appointment_id": appt.appointment_id,
                    "type": NotificationType.Appointment
                }
            )
            if existing:
                continue  # Skip already reminded

            # Format required documents
            docs_list = []
            if appt.service.required_documents:
                try:
                    docs_list = json.loads(appt.service.required_documents)
                except:
                    docs_list = [str(appt.service.required_documents)]

            docs_text = ", ".join(docs_list) if docs_list else "No documents listed."

            # Format message
            message = (
                f"Your appointment for {appt.service.name} is due on "
                f"{appt.appointment_datetime.strftime('%Y-%m-%d')} at {appt.appointment_datetime.strftime('%H:%M')}. "
                "If you're unable to make it please cancel the appointment. "
                f"Kindly bring the below documents with you: {docs_text}"
            )

            # Create notification
            notification_data = NotificationCreate(
                message=message,
                priority=NotificationPriority.Medium,
                type=NotificationType.Appointment,
                citizen_id=appt.citizen_id,
                appointment_id=appt.appointment_id,
                document_id=None
            )
            await create_notification(db, notification_data)

        await asyncio.sleep(CHECK_INTERVAL_SECONDS)