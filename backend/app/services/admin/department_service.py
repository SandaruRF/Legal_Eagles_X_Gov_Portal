from fastapi import HTTPException, Depends
from prisma import Prisma

from app.core.database import get_db
from app.db.admin.db_department import get_department_by_id


async def get_department_service(db: Prisma, department_id: str):
    department = await get_department_by_id(db, department_id)
    if not department:
        raise HTTPException(status_code=404, detail="Department not found")
    department = {"department_id": department.department_id, "name": department.name}
    return department