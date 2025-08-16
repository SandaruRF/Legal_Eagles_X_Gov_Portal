from pydantic import BaseModel, EmailStr
from prisma.enums import AdminRole
from typing import Optional
import datetime


class Department(BaseModel):
    """Base schema with common department fields."""
    department_id: str
    name: str