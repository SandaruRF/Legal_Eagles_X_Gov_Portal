from datetime import datetime, timedelta
from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from prisma import Prisma

from app.core.config import settings

from app.core.config import settings
from app.core.database import get_db
from app.db.citizen import db_citizen
from app.db.admin import db_admin
from app.schemas.citizen import citizen_schema
from app.schemas.admin import admin_schema

citizen_oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/citizens/login")
admin_oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/admins/login")

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Creates a new JWT access token.
    
    Args:
        data: The data to encode in the token (e.g., user ID).
        expires_delta: The lifespan of the token.
        
    Returns:
        The encoded JWT token as a string.
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now() + expires_delta
    else:
        expire = datetime.now() + timedelta(minutes=15)

    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(citizen_oauth2_scheme), db: Prisma = Depends(get_db)) -> citizen_schema.Citizen:
    """
    Dependency to get the current user from a JWT token.
    
    Decodes the token, validates the signature, and fetches the user from the database.
    Raises an exception if the token is invalid or the user doesn't exist.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = await db_citizen.get_citizen_by_email(db, email=email)
    if user is None:
        raise credentials_exception
    return user

async def get_current_admin(token: str = Depends(admin_oauth2_scheme), db: Prisma = Depends(get_db)) -> admin_schema.Admin:
    """
    Dependency to get the current admin from a JWT token.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate admin credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    admin = await db_admin.get_admin_by_email(db, email=email)
    if admin is None:
        raise credentials_exception
    return admin