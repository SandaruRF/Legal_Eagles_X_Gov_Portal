
from pydantic import BaseModel, EmailStr
import datetime

class CitizenBase(BaseModel):
    """Base schema with common fields."""
    full_name: str
    nic_no: str
    phone_no: str
    email: EmailStr

class CitizenCreate(CitizenBase):
    """Schema for creating a new citizen, now requires a password."""
    password: str

class Citizen(CitizenBase):
    """Schema for reading citizen data from the database."""
    citizen_id: str
    created_at: datetime.datetime

    class Config:
        orm_mode = True
