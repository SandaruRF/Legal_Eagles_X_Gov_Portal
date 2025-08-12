from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from prisma import Prisma
from supabase import Client

from app.core.database import get_db
from app.core.auth import get_current_user
from app.core.supabase_client import get_supabase_client
from app.schemas.citizen import citizen_schema
from app.schemas.citizen.citizen_kyc_schema import KYCStatusResponse
from app.db.citizen import db_citizen_kyc

router = APIRouter(
    prefix="/citizen/kyc",
    tags=["Citizen KYC"]
)

BUCKET_NAME = "gov-portal-kyc-files"

@router.post("/upload-nic-front", response_model=KYCStatusResponse)
async def upload_nic_front(
    current_user: citizen_schema.Citizen = Depends(get_current_user),
    db: Prisma = Depends(get_db),
    supabase: Client = Depends(get_supabase_client),
    file: UploadFile = File(...)
):
    """
    Upload the front side of the National ID card.
    """
    kyc_record = await db_citizen_kyc.get_or_create_kyc_record(db, current_user)
    file_path = f"{current_user.citizen_id}/nic_front.jpg"

    try:
        # Read the file content into bytes
        file_content = await file.read()
        # Upload file to Supabase Storage
        supabase.storage.from_(BUCKET_NAME).upload(file_path, file_content, {"content-type": "image/jpeg", "x-upsert": "true"})
        # Get public URL
        public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(file_path)
        # Update database
        updated_kyc = await db_citizen_kyc.update_kyc_nic_front(db, current_user.citizen_id, public_url)
        return updated_kyc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"File upload failed: {e}")


@router.post("/upload-nic-back", response_model=KYCStatusResponse)
async def upload_nic_back(
    current_user: citizen_schema.Citizen = Depends(get_current_user),
    db: Prisma = Depends(get_db),
    supabase: Client = Depends(get_supabase_client),
    file: UploadFile = File(...)
):
    """
    Upload the back side of the National ID card.
    """
    kyc_record = await db_citizen_kyc.get_or_create_kyc_record(db, current_user)
    file_path = f"{current_user.citizen_id}/nic_back.jpg"

    try:
        file_content = await file.read()
        supabase.storage.from_(BUCKET_NAME).upload(file_path, file_content, {"content-type": "image/jpeg", "x-upsert": "true"})
        public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(file_path)
        updated_kyc = await db_citizen_kyc.update_kyc_nic_back(db, current_user.citizen_id, public_url)
        return updated_kyc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"File upload failed: {e}")


@router.post("/upload-selfie", response_model=KYCStatusResponse)
async def upload_selfie(
    current_user: citizen_schema.Citizen = Depends(get_current_user),
    db: Prisma = Depends(get_db),
    supabase: Client = Depends(get_supabase_client),
    file: UploadFile = File(...)
):
    """
    Upload a selfie for verification.
    """
    kyc_record = await db_citizen_kyc.get_or_create_kyc_record(db, current_user)
    file_path = f"{current_user.citizen_id}/selfie.jpg"

    try:
        file_content = await file.read()
        supabase.storage.from_(BUCKET_NAME).upload(file_path, file_content, {"content-type": "image/jpeg", "x-upsert": "true"})
        public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(file_path)
        updated_kyc = await db_citizen_kyc.update_kyc_selfie(db, current_user.citizen_id, public_url)
        return updated_kyc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"File upload failed: {e}")
