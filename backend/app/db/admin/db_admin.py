from prisma import Prisma
from app.schemas.admin import admin_schema
from app.core.hashing import get_password_hash

async def get_admin_by_email(db: Prisma, email: str):
    """
    Retrieves an admin from the database by their email address.
    """
    return await db.admin.find_unique(where={"email": email})

async def create_admin(db: Prisma, admin: admin_schema.AdminCreate):
    """
    Creates a new admin record in the database with a hashed password.
    """
    hashed_password = get_password_hash(admin.password)
    
    new_admin = await db.admin.create(
        data={
            "full_name": admin.full_name,
            "email": admin.email,
            "password": hashed_password,
            "role": admin.role,
            "department_id": admin.department_id,
        }
    )
    return new_admin
