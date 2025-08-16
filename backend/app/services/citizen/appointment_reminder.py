import asyncio
from datetime import datetime, timedelta
from app.core.database import get_db
from app.services.citizen.notification_repository import create_notification
from app.schemas.citizen.notification import NotificationCreate
from prisma.enums import NotificationType, NotificationPriority
import json
import logging

logger = logging.getLogger(__name__)
CHECK_INTERVAL_SECONDS = 60
MAX_RETRIES = 3
RETRY_DELAY = 5

async def execute_db_query(db, query_func, *args, **kwargs):
    """Helper function to execute DB queries with retry logic"""
    for attempt in range(MAX_RETRIES):
        try:
            return await query_func(*args, **kwargs)
        except Exception as e:
            if "prepared statement" in str(e) and attempt < MAX_RETRIES - 1:
                logger.warning(f"Query failed (attempt {attempt+1}), retrying...")
                await asyncio.sleep(RETRY_DELAY * (attempt + 1))
                continue
            raise

async def appointment_reminder_worker():
    """Background worker to send appointment reminders."""
    db = get_db()  # Get the global Prisma instance
    
    while True:
        try:
            now = datetime.now()
            reminder_time = now + timedelta(hours=24)
            
            # Use the helper function for DB queries
            appointments = await execute_db_query(
                db,
                db.appointment.find_many,
                where={
                    "appointment_datetime": {
                        "gte": reminder_time - timedelta(minutes=5),
                        "lt": reminder_time + timedelta(minutes=5)
                    },
                    "status": "Booked"
                },
                include={
                    "service": {"include": {"locations": True}},
                    "citizen": True
                }
            )
            
            for appt in appointments:
                try:
                    existing = await execute_db_query(
                        db,
                        db.notification.find_first,
                        where={
                            "appointment_id": appt.appointment_id,
                            "type": NotificationType.Appointment.name
                        }
                    )
                    if existing:
                        continue

                    # Document processing logic...
                    docs_list = []
                    if appt.service.required_documents:
                        try:
                            docs_list = json.loads(appt.service.required_documents) \
                                if isinstance(appt.service.required_documents, str) \
                                else appt.service.required_documents
                        except json.JSONDecodeError:
                            docs_list = [str(appt.service.required_documents)]

                    location = appt.service.locations[0].address if appt.service.locations else "TBD"
                    
                    await execute_db_query(
                        db,
                        create_notification,
                        db,
                        NotificationCreate(
                            message=(
                                f"Reminder: Your appointment for {appt.service.name} is tomorrow at "
                                f"{appt.appointment_datetime.strftime('%H:%M')}. "
                                f"Location: {location}. "
                                f"Required documents: {', '.join(docs_list) if docs_list else 'None'}"
                            ),
                            priority=NotificationPriority.Medium.name,
                            type=NotificationType.Appointment.name,
                            citizen_id=appt.citizen_id,
                            appointment_id=appt.appointment_id
                        )
                    )
                    
                except Exception as e:
                    logger.error(f"Failed to process appointment {appt.appointment_id}: {str(e)}")
                    continue

        except Exception as e:
            logger.error(f"Error in reminder worker: {str(e)}")
        finally:
            await asyncio.sleep(CHECK_INTERVAL_SECONDS)