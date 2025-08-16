from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional, List
from app.core.auth import get_current_admin
from app.services.admin.appointment_service import (
    get_appointments_by_department,
    get_appointment_by_id,
    update_appointment,
    get_appointment_documents,
)
from app.schemas.admin.appointment_schema import (
    AppointmentListResponse,
    AppointmentResponse,
    AppointmentDocumentResponse,
    AppointmentUpdateRequest,
)


router = APIRouter()


@router.get("/", response_model=AppointmentListResponse)
async def list_appointments(
    status: Optional[str] = Query(None, description="Filter by appointment status"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Number of records to return"),
    current_admin=Depends(get_current_admin),
):
    """
    Get all appointments for the current admin's department.
    Supports filtering by status and pagination.
    """
    return await get_appointments_by_department(
        department_id=current_admin.department_id, status=status, skip=skip, limit=limit
    )


@router.get("/{appointment_id}", response_model=AppointmentResponse)
async def get_appointment(
    appointment_id: str, current_admin=Depends(get_current_admin)
):
    """
    Get a specific appointment by ID.
    The appointment must belong to the current admin's department.
    """
    return await get_appointment_by_id(
        appointment_id=appointment_id, department_id=current_admin.department_id
    )


@router.put("/{appointment_id}", response_model=AppointmentResponse)
async def update_appointment_route(
    appointment_id: str,
    update_data: AppointmentUpdateRequest,
    current_admin=Depends(get_current_admin),
):
    """
    Update an appointment.
    The appointment must belong to the current admin's department.
    """
    return await update_appointment(
        appointment_id=appointment_id,
        department_id=current_admin.department_id,
        update_data=update_data,
    )


@router.get(
    "/{appointment_id}/documents", response_model=List[AppointmentDocumentResponse]
)
async def get_appointment_documents_route(
    appointment_id: str, current_admin=Depends(get_current_admin)
):
    """
    Get all documents for a specific appointment.
    The appointment must belong to the current admin's department.
    """
    return await get_appointment_documents(
        appointment_id=appointment_id, department_id=current_admin.department_id
    )
