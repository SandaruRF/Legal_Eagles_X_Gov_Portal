# app/db/citizen/feedback_repository.py

import uuid
from datetime import datetime
from app.core.database import db  # Shared Prisma client


async def create_feedback(citizen_id: str, data: dict):
    ref_no = f"FB-{datetime.utcnow().year}-{str(uuid.uuid4().int)[:6]}"

    return await db.feedback.create(
        data={
            "rating": data["rating"],
            "comment": data.get("comment"),
            "reference_number": ref_no,
            "citizen_id": citizen_id,
            "appointment_id": data["appointment_id"],
        }
    )


async def get_feedback_by_appointment_id(appointment_id: str):
    return await db.feedback.find_unique(where={"appointment_id": appointment_id})
