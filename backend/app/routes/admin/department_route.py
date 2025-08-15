from fastapi import APIRouter, Depends
from prisma import Prisma

from app.core.database import get_db
from app.schemas.admin import department_schema
from app.services.admin.department_service import get_department_service

router = APIRouter(prefix="/departments", tags=["Departments"])

@router.get("/{department_id}", response_model=department_schema.Department)
async def get_department(
    department_id: str,
    db: Prisma = Depends(get_db)
):
    return await get_department_service(db, department_id)