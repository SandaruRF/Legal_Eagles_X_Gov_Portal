# backend/app/routes/notification/notification_route.py
from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from typing import List
from datetime import datetime

from app.core.database import get_db
from app.core.auth import get_current_user
from app.schemas.citizen import citizen_schema
from app.schemas.citizen.notification_schema import (
    AppointmentNotificationResponse,
    RenewalNotificationResponse
)
from app.db.citizen.db_notification import (
    get_citizen_notifications,
    mark_notification_as_read
)

router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"]
)

@router.get("/get-appointment-notifications", response_model=List[AppointmentNotificationResponse])
async def get_appointment_notifications(
    current_user: citizen_schema.Citizen = Depends(get_current_user),
    db: Prisma = Depends(get_db)
):
    """Get all appointment notifications for the current user"""
    notifications = await get_citizen_notifications(
        db,
        current_user.citizen_id,
        is_read=False
    )
    
    appointment_notifications = []
    for notification in notifications:
        if notification.type == "Appointment" and notification.appointment_id:
            # Get appointment details
            appointment = await db.appointment.find_unique(
                where={"appointment_id": notification.appointment_id},
                include={"service": True, "documents": True}
            )
            
            if appointment:
                service_name = appointment.service.name if appointment.service else "Unknown Service"
                
                appointment_notifications.append(
                    AppointmentNotificationResponse(
                        notification_id=notification.notification_id,
                        read_status=notification.is_read,
                        service_name=service_name,
                        appointment_datetime=appointment.appointment_datetime,
                        email_sent=notification.email_sent
                    )
                )
    
    return appointment_notifications

@router.get("/get-renewals-notifications", response_model=List[RenewalNotificationResponse])
async def get_renewal_notifications(
    current_user: citizen_schema.Citizen = Depends(get_current_user),
    db: Prisma = Depends(get_db)
):
    """Get all document renewal notifications for the current user"""
    notifications = await get_citizen_notifications(
        db,
        current_user.citizen_id,
        is_read=False
    )
    
    renewal_notifications = []
    for notification in notifications:
        if notification.type == "Document" and notification.document_id:
            # Get document details
            document = await db.digitalvaultdocument.find_unique(
                where={"document_id": notification.document_id}
            )
            
            if document and document.expiry_date:
                days_until_expiry = (document.expiry_date - datetime.now()).days
                
                renewal_notifications.append(
                    RenewalNotificationResponse(
                        notification_id=notification.notification_id,
                        priority=notification.priority,
                        read_status=notification.is_read,
                        document_type=document.document_type,
                        expiry_date=document.expiry_date,
                        days_until_expiry=days_until_expiry,
                        email_sent=notification.email_sent
                    )
                )
    
    return renewal_notifications

@router.post("/mark-as-read/{notification_id}")
async def mark_notification_read(
    notification_id: str,
    db: Prisma = Depends(get_db)
):
    """Mark a notification as read"""
    try:
        await mark_notification_as_read(db, notification_id)
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))