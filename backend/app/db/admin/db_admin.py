from prisma import Prisma
from app.schemas.admin import admin_schema
from app.core.hashing import get_password_hash
from typing import List, Optional


async def get_admin_by_email(db: Prisma, email: str):
    """
    Retrieves an admin from the database by their email address.
    """
    return await db.admin.find_unique(where={"email": email})


async def get_admin_by_id(db: Prisma, admin_id: str):
    """
    Retrieves an admin from the database by their ID.
    """
    return await db.admin.find_unique(where={"admin_id": admin_id})


async def get_admins_by_department(db: Prisma, department_id: str) -> List:
    """
    Retrieves all admins from a specific department.
    """
    return await db.admin.find_many(where={"department_id": department_id})


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


async def update_admin(
    db: Prisma, admin_id: str, admin_update: admin_schema.AdminUpdate
):
    """
    Updates an admin record in the database.
    """
    update_data = {}

    if admin_update.full_name is not None:
        update_data["full_name"] = admin_update.full_name
    if admin_update.email is not None:
        update_data["email"] = admin_update.email
    if admin_update.password is not None:
        update_data["password"] = get_password_hash(admin_update.password)
    if admin_update.role is not None:
        update_data["role"] = admin_update.role
    if admin_update.department_id is not None:
        update_data["department_id"] = admin_update.department_id

    return await db.admin.update(where={"admin_id": admin_id}, data=update_data)


async def delete_admin(db: Prisma, admin_id: str):
    """
    Deletes an admin record from the database.
    """
    return await db.admin.delete(where={"admin_id": admin_id})
