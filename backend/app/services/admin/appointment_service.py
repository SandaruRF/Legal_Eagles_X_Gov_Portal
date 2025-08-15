from typing import List, Optional
from app.core.database import db
from app.db.admin import db_appointment
from app.schemas.admin.appointment_schema import (
    AppointmentResponse,
    AppointmentListResponse,
    AppointmentDocumentResponse,
    AppointmentUpdateRequest,
    AppointmentUpdate,
    AppointmentStatus,
)
from fastapi import HTTPException


async def get_appointments_by_department(
    department_id: str, status: Optional[str] = None, skip: int = 0, limit: int = 100
) -> AppointmentListResponse:
    """Get all appointments for a specific department"""
    try:
        if status and status != "all":
            # Get appointments by status
            appointments = await db_appointment.get_appointments_by_status(
                db=db,
                department_id=department_id,
                status=status,
                skip=skip,
                limit=limit,
            )
        else:
            # Get all appointments for department
            appointments = await db_appointment.get_appointments_by_department(
                db=db, department_id=department_id, skip=skip, limit=limit
            )

        # Count total appointments
        where_clause = {"service": {"department_id": department_id}}
        if status and status != "all":
            where_clause["status"] = status
        total = await db.appointment.count(where=where_clause)

        # Transform data
        appointment_list = []
        for appointment in appointments:
            appointment_data = AppointmentResponse(
                appointment_id=appointment.appointment_id,
                appointment_datetime=appointment.appointment_datetime,
                status=appointment.status,
                reference_number=appointment.reference_number,
                created_at=appointment.created_at,
                citizen_id=appointment.citizen_id,
                service_id=appointment.service_id,
                assigned_admin_id=appointment.assigned_admin_id,
                citizen_name=(
                    appointment.citizen.full_name if appointment.citizen else None
                ),
                citizen_email=(
                    appointment.citizen.email if appointment.citizen else None
                ),
                citizen_phone=(
                    appointment.citizen.phone_no if appointment.citizen else None
                ),
                service_name=appointment.service.name if appointment.service else None,
                service_description=(
                    appointment.service.description if appointment.service else None
                ),
                assigned_admin_name=(
                    appointment.assigned_admin.full_name
                    if appointment.assigned_admin
                    else None
                ),
            )
            appointment_list.append(appointment_data)

        return AppointmentListResponse(appointments=appointment_list, total=total)

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to fetch appointments: {str(e)}"
        )


async def get_appointment_by_id(
    appointment_id: str, department_id: str
) -> AppointmentResponse:
    """Get a specific appointment by ID (must belong to the department)"""
    try:
        appointment = await db_appointment.get_appointment_by_id(
            db=db, appointment_id=appointment_id
        )

        if not appointment:
            raise HTTPException(status_code=404, detail="Appointment not found")

        # Check if appointment belongs to the department
        if appointment.service.department.department_id != department_id:
            raise HTTPException(status_code=404, detail="Appointment not found")

        return AppointmentResponse(
            appointment_id=appointment.appointment_id,
            appointment_datetime=appointment.appointment_datetime,
            status=appointment.status,
            reference_number=appointment.reference_number,
            created_at=appointment.created_at,
            citizen_id=appointment.citizen_id,
            service_id=appointment.service_id,
            assigned_admin_id=appointment.assigned_admin_id,
            citizen_name=appointment.citizen.full_name if appointment.citizen else None,
            citizen_email=appointment.citizen.email if appointment.citizen else None,
            citizen_phone=appointment.citizen.phone_no if appointment.citizen else None,
            service_name=appointment.service.name if appointment.service else None,
            service_description=(
                appointment.service.description if appointment.service else None
            ),
            assigned_admin_name=(
                appointment.assigned_admin.full_name
                if appointment.assigned_admin
                else None
            ),
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to fetch appointment: {str(e)}"
        )


async def update_appointment(
    appointment_id: str, department_id: str, update_data: AppointmentUpdateRequest
) -> AppointmentResponse:
    """Update an appointment (must belong to the department)"""
    try:
        # First check if appointment exists and belongs to department
        existing = await db_appointment.get_appointment_by_id(
            db=db, appointment_id=appointment_id
        )

        if not existing:
            raise HTTPException(status_code=404, detail="Appointment not found")

        # Check if appointment belongs to the department
        if existing.service.department.department_id != department_id:
            raise HTTPException(status_code=404, detail="Appointment not found")

        # Verify admin belongs to the same department if assigning
        if update_data.assigned_admin_id:
            admin = await db.admin.find_first(
                where={
                    "admin_id": update_data.assigned_admin_id,
                    "department_id": department_id,
                }
            )
            if not admin:
                raise HTTPException(
                    status_code=400, detail="Admin not found in this department"
                )

        # Update appointment using db layer
        appointment_update = AppointmentUpdate(
            appointment_datetime=update_data.appointment_datetime,
            status=update_data.status,
            assigned_admin_id=update_data.assigned_admin_id,
        )

        updated_appointment = await db_appointment.update_appointment(
            db=db, appointment_id=appointment_id, appointment_update=appointment_update
        )

        return AppointmentResponse(
            appointment_id=updated_appointment.appointment_id,
            appointment_datetime=updated_appointment.appointment_datetime,
            status=updated_appointment.status,
            reference_number=updated_appointment.reference_number,
            created_at=updated_appointment.created_at,
            citizen_id=updated_appointment.citizen_id,
            service_id=updated_appointment.service_id,
            assigned_admin_id=updated_appointment.assigned_admin_id,
            citizen_name=(
                updated_appointment.citizen.full_name
                if updated_appointment.citizen
                else None
            ),
            citizen_email=(
                updated_appointment.citizen.email
                if updated_appointment.citizen
                else None
            ),
            citizen_phone=(
                updated_appointment.citizen.phone_no
                if updated_appointment.citizen
                else None
            ),
            service_name=(
                updated_appointment.service.name
                if updated_appointment.service
                else None
            ),
            service_description=(
                updated_appointment.service.description
                if updated_appointment.service
                else None
            ),
            assigned_admin_name=(
                updated_appointment.assigned_admin.full_name
                if updated_appointment.assigned_admin
                else None
            ),
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to update appointment: {str(e)}"
        )


async def get_appointment_documents(
    appointment_id: str, department_id: str
) -> List[AppointmentDocumentResponse]:
    """Get all documents for a specific appointment (must belong to the department)"""
    try:
        # First check if appointment exists and belongs to department
        appointment = await db_appointment.get_appointment_by_id(
            db=db, appointment_id=appointment_id
        )

        if not appointment:
            raise HTTPException(status_code=404, detail="Appointment not found")

        # Check if appointment belongs to the department
        if appointment.service.department.department_id != department_id:
            raise HTTPException(status_code=404, detail="Appointment not found")

        # Get documents
        documents = await db_appointment.get_appointment_documents(
            db=db, appointment_id=appointment_id
        )

        return [
            AppointmentDocumentResponse(
                appointment_doc_id=doc.appointment_doc_id,
                document_name=doc.document_name,
                document_url=doc.document_url,
                uploaded_at=doc.uploaded_at,
                appointment_id=doc.appointment_id,
            )
            for doc in documents
        ]

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to fetch appointment documents: {str(e)}"
        )
