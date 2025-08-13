from datetime import timedelta
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.security import OAuth2PasswordRequestForm
from prisma import Prisma
from prisma.errors import UniqueViolationError

from app.core.database import get_db
from app.schemas.admin import admin_schema
from app.schemas import token_schema
from app.db.admin import db_admin
from app.core import auth, hashing
from app.core.config import settings

router = APIRouter(prefix="/admins", tags=["Admins"])


@router.post("/register", response_model=admin_schema.Admin)
async def register_admin(
    admin_in: admin_schema.AdminCreate, db: Prisma = Depends(get_db)
):
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


@router.post("/login", response_model=token_schema.Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), db: Prisma = Depends(get_db)
):
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


@router.get("/me", response_model=admin_schema.Admin)
async def read_admins_me(
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
):
    """
    Fetch the details of the currently authenticated admin.
    """
    return current_admin


@router.get("/", response_model=List[admin_schema.Admin])
async def get_admins_by_department(
    department_id: Optional[str] = Query(None),
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
    db: Prisma = Depends(get_db),
):
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


@router.put("/{admin_id}", response_model=admin_schema.Admin)
async def update_admin(
    admin_id: str,
    admin_update: admin_schema.AdminUpdate,
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
    db: Prisma = Depends(get_db),
):
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


@router.delete("/{admin_id}")
async def delete_admin(
    admin_id: str,
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
    db: Prisma = Depends(get_db),
):
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
