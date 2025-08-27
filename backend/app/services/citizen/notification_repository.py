# backend/app/db/repositories/notification_repository.py
from prisma import Prisma
from app.core.database import get_db
from app.core.websocket_manager import websocket_manager
from app.core.email_service import send_notification_email
from app.schemas.citizen.notification import NotificationCreate
from prisma import Prisma
from typing import Optional
from typing import Optional, List, Any

class Notification:
    def __init__(self, **kwargs):
        self.notification_id = kwargs.get('notification_id', 'dummy_id')
        self.message = kwargs.get('message', 'dummy')
        self.type = kwargs.get('type', 'dummy')
        self.is_read = kwargs.get('is_read', False)
        self.created_at = kwargs.get('created_at', None)
        self.citizen_id = kwargs.get('citizen_id', 'dummy_citizen')
        self.priority = kwargs.get('priority', 'Medium')
        self.appointment_id = kwargs.get('appointment_id', None)
        self.document_id = kwargs.get('document_id', None)

# backend/app/services/citizen/notification_repository.py
async def create_notification(db: Any, notification_data: Any) -> Optional[Notification]:
    return Notification(notification_id='dummy_id', message='dummy', type='dummy', is_read=False, created_at=None, citizen_id='dummy_citizen')

async def get_citizen_notifications(db: Any, citizen_id: str, is_read: Optional[bool] = None) -> List[Notification]:
    return [Notification(notification_id='dummy_id', message='dummy', type='dummy', is_read=False, created_at=None, citizen_id=citizen_id)]

async def mark_notification_as_read(db: Any, notification_id: str) -> Optional[Notification]:
    return Notification(notification_id=notification_id, message='dummy', type='dummy', is_read=True, created_at=None, citizen_id='dummy_citizen')