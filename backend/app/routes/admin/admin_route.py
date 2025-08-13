from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from fastapi.security import OAuth2PasswordRequestForm
from prisma import Prisma

from app.core.database import get_db
from app.schemas.admin import admin_schema
from app.schemas import token_schema
from app.core import auth
from app.services.admin import admin_service

router = APIRouter(prefix="/admins", tags=["Admins"])


@router.post("/register", response_model=admin_schema.Admin)
async def register_admin(
    admin_in: admin_schema.AdminCreate, db: Prisma = Depends(get_db)
):
    """
    Register a new admin in the system.
    """
    return await admin_service.register_admin_service(db, admin_in)


@router.post("/login", response_model=token_schema.Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), db: Prisma = Depends(get_db)
):
    """
    Authenticate admin and return a JWT access token.
    """
    return await admin_service.login_admin_service(db, form_data)


@router.get("/me", response_model=admin_schema.Admin)
async def read_admins_me(
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
):
    """
    Fetch the details of the currently authenticated admin.
    """
    return await admin_service.get_current_admin_service(current_admin)


@router.get("/", response_model=List[admin_schema.Admin])
async def get_admins_by_department(
    department_id: Optional[str] = Query(None),
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
    db: Prisma = Depends(get_db),
):
    """
    Get all admins by department (Head role only).
    """
    return await admin_service.get_admins_by_department_service(
        db, current_admin, department_id
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
    return await admin_service.update_admin_service(
        db, admin_id, admin_update, current_admin
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
    return await admin_service.delete_admin_service(db, admin_id, current_admin)
