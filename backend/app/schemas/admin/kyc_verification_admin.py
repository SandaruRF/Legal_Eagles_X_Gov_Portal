from pydantic import BaseModel, EmailStr
from prisma.enums import KYCStatus
import datetime

class CitizenForKYC(BaseModel):
    """A minimal citizen model to include in the KYC response."""
    full_name: str
    nic_no: str
    phone_no: str
    email: EmailStr

    class Config:
        from_attributes = True

class KYCAdminView(BaseModel):
    """
    Detailed KYC view for an admin, including citizen information.
    """
    kyc_id: str
    status: KYCStatus
    nic_front_url: str | None
    nic_back_url: str | None
    selfie_url: str | None
    citizen: CitizenForKYC

    class Config:
        orm_mode = True

class KYCUpdateRequest(BaseModel):
    """Schema for the admin's request to update a KYC status."""
    status: KYCStatus
