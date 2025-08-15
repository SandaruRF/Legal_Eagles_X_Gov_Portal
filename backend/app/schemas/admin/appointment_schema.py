from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List
from enum import Enum


class AppointmentStatus(str, Enum):
    Booked = "Booked"
    Confirmed = "Confirmed"
    Completed = "Completed"
    Cancelled = "Cancelled"
    NoShow = "NoShow"


class AppointmentDocumentResponse(BaseModel):
    appointment_doc_id: str
    document_name: str
    document_url: str
    uploaded_at: datetime
    appointment_id: str

    class Config:
        from_attributes = True


class AppointmentResponse(BaseModel):
    appointment_id: str
    appointment_datetime: datetime
    status: AppointmentStatus
    reference_number: str
    created_at: datetime
    citizen_id: str
    service_id: str
    assigned_admin_id: Optional[str] = None

    # Related data
    citizen_name: Optional[str] = None
    citizen_email: Optional[str] = None
    citizen_phone: Optional[str] = None
    service_name: Optional[str] = None
    service_description: Optional[str] = None
    assigned_admin_name: Optional[str] = None

    class Config:
        from_attributes = True


class AppointmentListResponse(BaseModel):
    appointments: List[AppointmentResponse]
    total: int

    class Config:
        from_attributes = True


class AppointmentUpdate(BaseModel):
    appointment_datetime: Optional[datetime] = None
    status: Optional[AppointmentStatus] = None
    assigned_admin_id: Optional[str] = None

    class Config:
        from_attributes = True


class AppointmentUpdateRequest(BaseModel):
    appointment_datetime: Optional[datetime] = None
    status: Optional[AppointmentStatus] = None
    assigned_admin_id: Optional[str] = None

    class Config:
        from_attributes = True
