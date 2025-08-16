from prisma import Prisma

async def log_message(citizen_id: str, message: str, response: str ):
    db = Prisma()
    await db.connect()
    await db.messagelog.create({
        "citizen_id": citizen_id,
        "message": message,
        "response": response
    })
    await db.disconnect()
