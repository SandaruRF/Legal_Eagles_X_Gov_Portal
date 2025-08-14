
from prisma import Prisma
from app.schemas.citizen import citizen_schema
from prisma.enums import VaultDocumentType
import datetime
from typing import List

async def create_vault_document(
    db: Prisma, 
    current_user: citizen_schema.Citizen,
    doc_type: VaultDocumentType,
    file_urls: List[str],  
    expiry_date: datetime.date | None
):
    """
    Creates a new document record in the citizen's digital vault.
    """
    new_doc = await db.digitalvaultdocument.create(
        data={
            "citizen_id": current_user.citizen_id,
            "document_type": doc_type,
            "document_urls": file_urls, 
            "expiry_date": expiry_date
        }
    )
    return new_doc

async def get_vault_documents(db: Prisma, current_user: citizen_schema.Citizen):
    """
    Retrieves all documents from a citizen's digital vault.
    """
    return await db.digitalvaultdocument.find_many(
        where={"citizen_id": current_user.citizen_id}
    )
