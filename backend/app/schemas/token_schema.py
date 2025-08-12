from pydantic import BaseModel

class Token(BaseModel):
    """Schema for the JWT access token."""
    access_token: str
    token_type: str

class TokenData(BaseModel):
    """Schema for the data encoded within the JWT."""
    email: str | None = None
