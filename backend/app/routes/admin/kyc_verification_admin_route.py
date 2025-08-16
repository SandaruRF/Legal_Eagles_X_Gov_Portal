from fastapi import APIRouter, Depends, HTTPException, status
from prisma import Prisma
from typing import List

from app.core.database import get_db
from app.core.auth import get_current_admin
from app.schemas.admin import admin_schema
from app.schemas.admin import kyc_verification_admin
from app.db.admin import db_kyc_admin

router = APIRouter(
    prefix="/admins/kyc_verifications",
    tags=["Admins KYC Verification"]
)

@router.get("/pending", response_model=List[kyc_verification_admin.KYCAdminView])
async def list_pending_kyc_submissions(
    current_admin: admin_schema.Admin = Depends(get_current_admin),
    db: Prisma = Depends(get_db)
):
    """
    Retrieve a list of all KYC submissions awaiting verification. (Admin only)
    """
    return await db_kyc_admin.get_pending_kycs(db)

@router.get("/{kyc_id}", response_model=kyc_verification_admin.KYCAdminView)
async def get_kyc_submission_details(
    kyc_id: str,
    current_admin: admin_schema.Admin = Depends(get_current_admin),
    db: Prisma = Depends(get_db)
):
    """
    Get the full details of a single KYC submission. (Admin only)
    """
    kyc_record = await db_kyc_admin.get_kyc_by_id(db, kyc_id)
    if not kyc_record:
        raise HTTPException(status_code=404, detail="KYC record not found")
    return kyc_record

@router.patch("/{kyc_id}/verify", response_model=kyc_verification_admin.KYCAdminView)
async def verify_kyc_submission(
    kyc_id: str,
    update_data: kyc_verification_admin.KYCUpdateRequest,
    current_admin: admin_schema.Admin = Depends(get_current_admin),
    db: Prisma = Depends(get_db)
):
    """
    Update the status of a KYC submission to 'Verified' or 'Rejected'. (Admin only)
    """
    kyc_record = await db_kyc_admin.get_kyc_by_id(db, kyc_id)
    if not kyc_record:
        raise HTTPException(status_code=404, detail="KYC record not found")

    updated_kyc = await db_kyc_admin.update_kyc_status(db, kyc_id, update_data.status, current_admin)
    
    # Refetch with citizen details to match the response model
    return await db_kyc_admin.get_kyc_by_id(db, updated_kyc.kyc_id)
