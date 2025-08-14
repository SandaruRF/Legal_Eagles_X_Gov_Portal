# backend/app/core/notification_manager.py
from datetime import datetime, timedelta
from typing import Dict, List
from fastapi import WebSocket
from prisma import Prisma
import asyncio
import smtplib
from email.message import EmailMessage
from dotenv import load_dotenv
import os

from app.db.citizen.db_notification import (
    create_notification,
    get_upcoming_appointments_for_notifications,
    get_expiring_documents_for_notifications,
    get_citizen_email
)
from app.schemas.citizen.notification_schema import NotificationCreate

# Load email credentials
load_dotenv()

class NotificationManager:
    def __init__(self, db: Prisma):
        self.active_connections: Dict[str, WebSocket] = {}
        self.task = None
        self.db = db
        self.email_address = os.getenv("EMAIL_ADDRESS")
        self.email_password = os.getenv("EMAIL_PASSWORD")

    async def connect(self, citizen_id: str, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[citizen_id] = websocket

    def disconnect(self, citizen_id: str):
        if citizen_id in self.active_connections:
            del self.active_connections[citizen_id]

    async def send_personal_message(self, message: str, citizen_id: str):
        if citizen_id in self.active_connections:
            await self.active_connections[citizen_id].send_text(message)

    async def broadcast(self, message: str):
        for connection in self.active_connections.values():
            await connection.send_text(message)

    async def send_email_notification(self, email: str, subject: str, message: str):
        """Send an email notification"""
        msg = EmailMessage()
        msg.set_content(message)
        msg["Subject"] = subject
        msg["From"] = self.email_address
        msg["To"] = email

        try:
            with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
                server.login(self.email_address, self.email_password)
                server.send_message(msg)
            return True
        except Exception as e:
            print(f"Error sending email to {email}: {e}")
            return False

    async def start_periodic_check(self, db: Prisma):
        """Start background task to check for notifications periodically"""
        if self.task is None or self.task.done():
            self.task = asyncio.create_task(self._check_notifications_periodically(db))

    async def _check_notifications_periodically(self, db: Prisma):
        """Check for notifications every 5 minutes"""
        while True:
            await self._check_appointment_reminders(db)
            await self._check_renewal_reminders(db)
            await asyncio.sleep(300)  # 5 minutes

    async def _check_appointment_reminders(self, db: Prisma):
        """Check and send appointment reminders"""
        appointments = await get_upcoming_appointments_for_notifications(db)
        
        for appointment in appointments:
            # Notification message
            message = f"Reminder: You have an appointment for {appointment.service.name} at {appointment.appointment_datetime}"
            
            # Create notification in database
            notification = NotificationCreate(
                message=message,
                priority="high",
                type="Appointment",
                citizen_id=appointment.citizen_id,
                appointment_id=appointment.appointment_id
            )
            
            created_notification = await create_notification(db, notification)
            
            # Send via WebSocket if user is connected
            await self.send_personal_message(
                f"APPOINTMENT_REMINDER:{created_notification.notification_id}",
                appointment.citizen_id
            )
            
            # Send email notification
            citizen_email = await get_citizen_email(db, appointment.citizen_id)
            if citizen_email:
                email_subject = f"Appointment Reminder: {appointment.service.name}"
                await self.send_email_notification(citizen_email, email_subject, message)

    async def _check_renewal_reminders(self, db: Prisma):
        """Check and send document renewal reminders"""
        documents = await get_expiring_documents_for_notifications(db)
        
        for doc in documents:
            days_until_expiry = (doc.expiry_date - datetime.now()).days
            
            # Determine priority based on days until expiry
            if days_until_expiry <= 7:
                priority = "high"
            elif days_until_expiry <= 14:
                priority = "medium"
            else:
                priority = "low"
            
            # Notification message
            message = f"Reminder: Your {doc.document_type} expires in {days_until_expiry} days"
            
            # Create notification in database
            notification = NotificationCreate(
                message=message,
                priority=priority,
                type="Document",
                citizen_id=doc.citizen_id,
                document_id=doc.document_id
            )
            
            created_notification = await create_notification(db, notification)
            
            # Send via WebSocket if user is connected
            await self.send_personal_message(
                f"RENEWAL_REMINDER:{created_notification.notification_id}",
                doc.citizen_id
            )
            
            # Send email notification
            citizen_email = await get_citizen_email(db, doc.citizen_id)
            if citizen_email:
                email_subject = f"Document Expiry Reminder: {doc.document_type}"
                await self.send_email_notification(citizen_email, email_subject, message)

# Global instance of the notification manager
notification_manager = NotificationManager()