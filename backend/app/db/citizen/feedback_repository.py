from app.core.database import db  # Shared Prisma client


async def create_feedback(citizen_id: str, data: dict):
    """
    Create a new feedback entry for the given citizen and appointment.
    Uses relation connect to satisfy Prisma's required relation inputs.
    """
    return await db.feedback.create(
        data={
            "rating": data["rating"],
            "comment": data.get("comment"),
            "appointment": {
                "connect": {"appointment_id": data["appointment_id"]}
            },
            "citizen": {
                "connect": {"citizen_id": citizen_id}
            }
        }
    )


async def get_feedback_by_appointment_id(appointment_id: str):
    """
    Retrieve feedback by appointment ID.
    """
    return await db.feedback.find_unique(
        where={"appointment_id": appointment_id}
    )
