from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime
from prisma.enums import AppointmentStatus

class Officer(BaseModel):
    id: str
    name: str

class AppointmentSlot(BaseModel):
    slot_id: str
    date: str
    time: str
    available: bool
    officer: Officer

class AppointmentBookingRequest(BaseModel):
    service_id: str
    slot_id: str
    citizen_id: str
    uploaded_documents: Dict[str, Any]

class AppointmentBookingResponse(BaseModel):
    appointment_id: str
    reference_number: str
    service: Dict[str, str]
    scheduled_date: str
    scheduled_time: str

class AppointmentListItem(BaseModel):
    appointment_id: str
    reference_number: str
    service_name: str
    scheduled_date: str
    scheduled_time: str
    status: str
    address: str

class AppointmentListResponse(BaseModel):
    appointments: List[AppointmentListItem]

class AppointmentCreate(BaseModel):
    appointment_datetime: datetime
    service_id: str
    citizen_id: str
    assigned_admin_id: Optional[str] = None
    status: Optional[AppointmentStatus] = AppointmentStatus.Booked
    documents: Optional[List[Dict[str, str]]] = None
