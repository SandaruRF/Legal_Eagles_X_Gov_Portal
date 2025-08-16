from pydantic import BaseModel
from prisma.enums import VaultDocumentType
from typing import List
import datetime

class VaultDocument(BaseModel):
    """
    Response model for a single document in the digital vault.
    """
    document_id: str
    document_type: VaultDocumentType
    document_urls: List[str] 
    uploaded_at: datetime.datetime
    expiry_date: datetime.date | None

    class Config:
        from_attributes = True
