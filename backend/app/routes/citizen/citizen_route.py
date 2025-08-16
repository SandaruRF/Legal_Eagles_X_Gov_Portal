from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from prisma import Prisma
from prisma.errors import UniqueViolationError

from app.core.database import get_db
from app.schemas.citizen import citizen_schema
from app.schemas import token_schema
from app.db.citizen import db_citizen
from app.core import auth, hashing
from app.core.config import settings

router = APIRouter(
    prefix="/citizens",
    tags=["Citizens"]
)



@router.post("/register", response_model=citizen_schema.Citizen)
async def register_citizen(
    citizen_in: citizen_schema.CitizenCreate,
    db: Prisma = Depends(get_db)
):
    """
    Register a new citizen in the system.
    
    This endpoint ensures that the NIC, phone number, and email are unique.
    """
    try:
        new_citizen = await db_citizen.create_citizen(db, citizen_in)
        return new_citizen
    except UniqueViolationError:
        raise HTTPException(
            status_code=400,
            detail="A citizen with the same NIC, email, or phone number already exists.",
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
    Authenticate citizen and return a JWT access token.
    """
    citizen = await db_citizen.get_citizen_by_identifier(db, identifier=form_data.username)
    if not citizen or not hashing.verify_password(form_data.password, citizen.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": citizen.email}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=citizen_schema.Citizen)
async def read_users_me(current_user: citizen_schema.Citizen = Depends(auth.get_current_user)):
    """
    Fetch the details of the currently authenticated citizen.
    
    This is a protected endpoint. You must provide a valid JWT token in the
    Authorization header as a Bearer token.
    """
    return current_user