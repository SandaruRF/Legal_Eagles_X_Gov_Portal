from prisma import Prisma
from app.schemas.citizen import citizen_schema
from app.core.security import get_password_hash

async def get_citizen_by_email(db: Prisma, email: str):
    """
    Retrieves a citizen from the database by their email address.
    
    Args:
        db: The Prisma database client.
        email: The citizen's email.
        
    Returns:
        The citizen object if found, otherwise None.
    """
    return await db.citizen.find_unique(where={"email": email})

async def create_citizen(db: Prisma, citizen: citizen_schema.CitizenCreate):
    """
    Creates a new citizen record in the database with a hashed password.
    
    Args:
        db: The Prisma database client.
        citizen: The Pydantic model containing the new citizen's data.
        
    Returns:
        The newly created citizen object.
    """
    # Hash the password before storing it
    hashed_password = get_password_hash(citizen.password)
    
    new_citizen = await db.citizen.create(
        data={
            "full_name": citizen.full_name,
            "nic_no": citizen.nic_no,
            "phone_no": citizen.phone_no,
            "email": citizen.email,
            "password": hashed_password, 
        }
    )
    return new_citizen
