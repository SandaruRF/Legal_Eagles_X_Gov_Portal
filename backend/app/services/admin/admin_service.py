from datetime import timedelta
from typing import List, Optional
from fastapi import HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from prisma import Prisma
from prisma.errors import UniqueViolationError

from app.schemas.admin import admin_schema
from app.schemas import token_schema
from app.db.admin import db_admin
from app.core import auth, hashing
from app.core.config import settings


async def register_admin_service(
    db: Prisma, admin_in: admin_schema.AdminCreate
) -> admin_schema.Admin:
    """
    Register a new admin in the system.
    """
    try:
        new_admin = await db_admin.create_admin(db, admin_in)
        return new_admin
    except UniqueViolationError:
        raise HTTPException(
            status_code=400,
            detail="An admin with the same email already exists.",
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"An unexpected error occurred: {e}",
        )


async def login_admin_service(
    db: Prisma, form_data: OAuth2PasswordRequestForm
) -> token_schema.Token:
    """
    Authenticate admin and return a JWT access token.
    """
    admin = await db_admin.get_admin_by_email(db, email=form_data.username)
    if not admin or not hashing.verify_password(form_data.password, admin.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": admin.email}, expires_delta=access_token_expires
    )

    return {"access_token": access_token, "token_type": "bearer"}


async def get_current_admin_service(
    current_admin: admin_schema.Admin,
) -> admin_schema.Admin:
    """
    Fetch the details of the currently authenticated admin.
    """
    return current_admin


async def get_admins_by_department_service(
    db: Prisma,
    current_admin: admin_schema.Admin,
    department_id: Optional[str] = None,
) -> List[admin_schema.Admin]:
    """
    Get all admins by department (Head role only).
    """
    # Check if current admin has Head role
    if current_admin.role != "Head":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only Head role can access admin management",
        )

    # If department_id is provided, filter by it, otherwise use current admin's department
    dept_id = department_id or current_admin.department_id

    try:
        admins = await db_admin.get_admins_by_department(db, dept_id)
        return admins
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch admins: {e}",
        )


async def update_admin_service(
    db: Prisma,
    admin_id: str,
    admin_update: admin_schema.AdminUpdate,
    current_admin: admin_schema.Admin,
) -> admin_schema.Admin:
    """
    Update an admin (Head role only).
    """
    # Check if current admin has Head role
    if current_admin.role != "Head":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only Head role can update admins",
        )

    try:
        # Check if admin exists and belongs to the same department
        existing_admin = await db_admin.get_admin_by_id(db, admin_id)
        if not existing_admin:
            raise HTTPException(status_code=404, detail="Admin not found")

        if existing_admin.department_id != current_admin.department_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Can only update admins in your department",
            )

        updated_admin = await db_admin.update_admin(db, admin_id, admin_update)
        return updated_admin
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to update admin: {e}",
        )


async def delete_admin_service(
    db: Prisma,
    admin_id: str,
    current_admin: admin_schema.Admin,
) -> dict:
    """
    Delete an admin (Head role only).
    """
    # Check if current admin has Head role
    if current_admin.role != "Head":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only Head role can delete admins",
        )

    # Prevent deleting self
    if admin_id == current_admin.admin_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own account",
        )

    try:
        # Check if admin exists and belongs to the same department
        existing_admin = await db_admin.get_admin_by_id(db, admin_id)
        if not existing_admin:
            raise HTTPException(status_code=404, detail="Admin not found")

        if existing_admin.department_id != current_admin.department_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Can only delete admins in your department",
            )

        await db_admin.delete_admin(db, admin_id)
        return {"message": "Admin deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to delete admin: {e}",
        )
