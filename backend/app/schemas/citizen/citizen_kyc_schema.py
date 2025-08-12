from pydantic import BaseModel
from prisma.enums import KYCStatus

class KYCStatusResponse(BaseModel):
    """
    Response model for the current status of a citizen's KYC process.
    """
    status: KYCStatus
    nic_front_url: str | None
    nic_back_url: str | None
    selfie_url: str | None

    class Config:
        orm_mode = True
