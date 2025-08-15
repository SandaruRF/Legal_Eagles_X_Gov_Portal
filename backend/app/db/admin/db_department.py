from prisma import Prisma


async def get_department_by_id(db: Prisma, department_id: str):
    """
    Get a department by its ID.
    """
    return await db.department.find_unique(
        where={"department_id": department_id}
    )