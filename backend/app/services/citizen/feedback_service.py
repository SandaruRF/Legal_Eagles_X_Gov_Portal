from fastapi import HTTPException
from app.core.database import db
from app.db.citizen import feedback_repository
from app.schemas.citizen.feedback import FeedbackCreate


async def submit_feedback(citizen_id: str, payload: FeedbackCreate):
    # Check that the appointment belongs to the citizen
    appointment = await db.appointment.find_unique(
        where={"appointment_id": payload.appointment_id}
    )
    if not appointment or appointment.citizen_id != citizen_id:
        raise HTTPException(status_code=403, detail="Invalid appointment")

    # Check duplicate
    existing = await feedback_repository.get_feedback_by_appointment_id(payload.appointment_id)
    if existing:
        raise HTTPException(status_code=400, detail="Feedback already submitted")

    feedback = await feedback_repository.create_feedback(citizen_id, payload.model_dump())
    return {
        "status": "success",
        "feedback": {
            "id": feedback.feedback_id,
            "submission_date": feedback.submitted_at,
            "status": "submitted",
            "reference_number": feedback.reference_number
        }
    }
