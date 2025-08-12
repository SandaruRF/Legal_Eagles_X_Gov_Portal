from prisma import Prisma
from app.schemas.citizen import citizen_schema

async def get_or_create_kyc_record(db: Prisma, current_user: citizen_schema.Citizen):
    """
    Retrieves a user's KYC record, creating one if it doesn't exist.
    """
    kyc_record = await db.kyc.find_unique(where={"citizen_id": current_user.citizen_id})
    if not kyc_record:
        kyc_record = await db.kyc.create(
            data={"citizen_id": current_user.citizen_id}
        )
    return kyc_record

async def update_kyc_nic_front(db: Prisma, citizen_id: str, file_url: str):
    """
    Updates the NIC front image URL for a citizen's KYC record.
    """
    return await db.kyc.update(
        where={"citizen_id": citizen_id},
        data={"nic_front_url": file_url}
    )

async def update_kyc_nic_back(db: Prisma, citizen_id: str, file_url: str):
    """
    Updates the NIC back image URL for a citizen's KYC record.
    """
    return await db.kyc.update(
        where={"citizen_id": citizen_id},
        data={"nic_back_url": file_url}
    )

async def update_kyc_selfie(db: Prisma, citizen_id: str, file_url: str):
    """
    Updates the selfie image URL for a citizen's KYC record.
    """
    return await db.kyc.update(
        where={"citizen_id": citizen_id},
        data={"selfie_url": file_url}
    )
