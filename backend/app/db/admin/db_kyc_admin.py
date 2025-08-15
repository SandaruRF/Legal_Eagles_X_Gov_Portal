
from prisma import Prisma
from prisma.enums import KYCStatus
from app.schemas.admin import admin_schema
import datetime

async def get_pending_kycs(db: Prisma):
    """
    Retrieves all KYC records with a 'Pending' status, including citizen details.
    """
    return await db.kyc.find_many(
        where={"status": KYCStatus.Pending},
        include={"citizen": True}
    )

async def get_kyc_by_id(db: Prisma, kyc_id: str):
    """
    Retrieves a single KYC record by its ID, including citizen details.
    """
    return await db.kyc.find_unique(
        where={"kyc_id": kyc_id},
        include={"citizen": True}
    )

async def update_kyc_status(db: Prisma, kyc_id: str, new_status: KYCStatus, admin: admin_schema.Admin):
    """
    Updates the status of a KYC record and logs which admin performed the action.
    """
    return await db.kyc.update(
        where={"kyc_id": kyc_id},
        data={
            "status": new_status,
            "verified_by_id": admin.admin_id,
            "verified_at": datetime.datetime.utcnow()
        }
    )
