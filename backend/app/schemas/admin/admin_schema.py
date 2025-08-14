from pydantic import BaseModel, EmailStr
from prisma.enums import AdminRole

class AdminBase(BaseModel):
    """Base schema with common admin fields."""
    full_name: str
    email: EmailStr
    role: AdminRole = AdminRole.Officer
    department_id: str

class AdminCreate(AdminBase):
    """Schema for creating a new admin."""
    password: str

class Admin(AdminBase):
    """Schema for reading admin data from the database."""
    admin_id: str

    class Config:
        from_attributes = True

class FormTemplateRequest(BaseModel):
    form_name: str
    form_template: dict
