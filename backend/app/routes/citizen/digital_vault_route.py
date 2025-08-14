
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from prisma import Prisma
from supabase import Client
from typing import List
import datetime

from app.core.database import get_db
from app.core.auth import get_current_user
from app.core.supabase_client import get_supabase_client
from app.schemas.citizen import citizen_schema
from app.schemas.citizen.digital_vault_schema import VaultDocument
from app.db.citizen import db_digital_vault
from prisma.enums import VaultDocumentType

router = APIRouter(
    prefix="/citizen/vault",
    tags=["Digital Vault"]
)

BUCKET_NAME = "gov-portal-digital-vault"

@router.post("/upload", response_model=VaultDocument)
async def upload_vault_documents(
    current_user: citizen_schema.Citizen = Depends(get_current_user),
    doc_type: VaultDocumentType = Form(...),
    expiry_date: str | None = Form(None),
    files: List[UploadFile] = File(...), # Changed to accept a list of files
    db: Prisma = Depends(get_db),
    supabase: Client = Depends(get_supabase_client)
):
    """
    Upload one or more documents to the citizen's personal digital vault.
    All uploaded files will be associated with a single vault entry.
    """
    # Manually parse the date string if it exists
    parsed_expiry_date: datetime.date | None = None
    if expiry_date:
        try:
            parsed_expiry_date = datetime.date.fromisoformat(expiry_date)
        except (ValueError, TypeError):
            raise HTTPException(
                status_code=422,
                detail="Invalid date format for expiry_date. Please use YYYY-MM-DD."
            )

    uploaded_urls = []
    try:
        for file in files:
            # Create a unique path for each file to avoid overwrites
            file_path = f"{current_user.citizen_id}/vault/{doc_type.value}/{file.filename}"
            file_content = await file.read()
            
            # Upload file to Supabase Storage
            supabase.storage.from_(BUCKET_NAME).upload(file_path, file_content, {"x-upsert": "true"})
            
            # Get public URL and add it to our list
            public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(file_path)
            uploaded_urls.append(public_url)
            
        # Create a single database record with the list of URLs
        new_document = await db_digital_vault.create_vault_document(
            db, current_user, doc_type, uploaded_urls, parsed_expiry_date
        )
        return new_document
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"File upload failed: {e}")

@router.get("/documents", response_model=List[VaultDocument])
async def list_vault_documents(
    current_user: citizen_schema.Citizen = Depends(get_current_user),
    db: Prisma = Depends(get_db)
):
    """
    Retrieve a list of all documents in the citizen's digital vault.
    """
    documents = await db_digital_vault.get_vault_documents(db, current_user)
    return documents
