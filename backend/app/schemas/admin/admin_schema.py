from pydantic import BaseModel, EmailStr
from prisma.enums import AdminRole
from typing import Optional
import datetime


class AdminBase(BaseModel):
    """Base schema with common admin fields."""
    full_name: str
    email: EmailStr
    role: AdminRole = AdminRole.Officer
    department_id: str


class AdminCreate(AdminBase):
    """Schema for creating a new admin."""
    password: str


class AdminUpdate(BaseModel):
    """Schema for updating an admin."""

    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    role: Optional[AdminRole] = None
    password: Optional[str] = None


class Admin(AdminBase):
    """Schema for reading admin data from the database."""

    admin_id: str

    class Config:
        orm_mode = True
