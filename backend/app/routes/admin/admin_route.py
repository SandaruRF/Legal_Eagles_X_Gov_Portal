from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from prisma import Prisma
from prisma.errors import UniqueViolationError

from app.core.database import get_db
from app.schemas.admin import admin_schema
from app.schemas import token_schema
from app.db.admin import db_admin
from app.core import auth, hashing
from app.core.config import settings

router = APIRouter(
    prefix="/admins",
    tags=["Admins", "Authentication"]
)

@router.post("/register", response_model=admin_schema.Admin)
async def register_admin(
    admin_in: admin_schema.AdminCreate,
    db: Prisma = Depends(get_db)
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
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Prisma = Depends(get_db)
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
async def read_admins_me(current_admin: admin_schema.Admin = Depends(auth.get_current_admin)):
    """
    Fetch the details of the currently authenticated admin.
    """
    return current_admin
