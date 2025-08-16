from prisma import Prisma
from app.schemas.admin import appointment_schema
from typing import List, Optional
from prisma.enums import AppointmentStatus


async def get_appointment_by_id(db: Prisma, appointment_id: str):
    """
    Get an appointment by its ID with related data.
    """
    return await db.appointment.find_unique(
        where={"appointment_id": appointment_id},
        include={
            "citizen": True,
            "service": {"include": {"department": True}},
            "assigned_admin": True,
        },
    )


async def get_appointments_by_department(
    db: Prisma, department_id: str, skip: int = 0, limit: int = 100
):
    """
    Get all appointments for a specific department with pagination.
    """
    return await db.appointment.find_many(
        where={"service": {"department_id": department_id}},
        include={
            "citizen": True,
            "service": {"include": {"department": True}},
            "assigned_admin": True,
        },
        skip=skip,
        take=limit,
        order={"appointment_datetime": "desc"},
    )


async def get_appointments_by_admin(
    db: Prisma, admin_id: str, skip: int = 0, limit: int = 100
):
    """
    Get all appointments assigned to a specific admin.
    """
    return await db.appointment.find_many(
        where={"assigned_admin_id": admin_id},
        include={
            "citizen": True,
            "service": {"include": {"department": True}},
            "assigned_admin": True,
        },
        skip=skip,
        take=limit,
        order={"appointment_datetime": "desc"},
    )


async def get_appointments_by_status(
    db: Prisma,
    department_id: str,
    status: AppointmentStatus,
    skip: int = 0,
    limit: int = 100,
):
    """
    Get appointments by status for a specific department.
    """
    return await db.appointment.find_many(
        where={"status": status, "service": {"department_id": department_id}},
        include={
            "citizen": True,
            "service": {"include": {"department": True}},
            "assigned_admin": True,
        },
        skip=skip,
        take=limit,
        order={"appointment_datetime": "desc"},
    )


async def update_appointment(
    db: Prisma,
    appointment_id: str,
    appointment_update: appointment_schema.AppointmentUpdate,
):
    """
    Update an appointment.
    """
    update_data = {}

    if appointment_update.appointment_datetime is not None:
        update_data["appointment_datetime"] = appointment_update.appointment_datetime
    if appointment_update.status is not None:
        update_data["status"] = appointment_update.status
    if appointment_update.assigned_admin_id is not None:
        update_data["assigned_admin_id"] = appointment_update.assigned_admin_id

    return await db.appointment.update(
        where={"appointment_id": appointment_id},
        data=update_data,
        include={
            "citizen": True,
            "service": {"include": {"department": True}},
            "assigned_admin": True,
        },
    )


async def get_appointment_documents(db: Prisma, appointment_id: str):
    """
    Get all documents for a specific appointment.
    """
    return await db.appointmentdocument.find_many(
        where={"appointment_id": appointment_id}, order={"uploaded_at": "desc"}
    )
