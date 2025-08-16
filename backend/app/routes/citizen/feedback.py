from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma

from app.core.database import get_db
from app.core.auth import get_current_user
from app.schemas.citizen import citizen_schema
from app.schemas.citizen.feedback import FeedbackCreate
from app.db.citizen import feedback_repository

router = APIRouter(
    prefix="/citizen/feedback",
    tags=["Citizen Feedback"]
)


@router.post("/submit")
async def submit_feedback(
    payload: FeedbackCreate,
    current_user: citizen_schema.Citizen = Depends(get_current_user),
    db: Prisma = Depends(get_db),
):
    """
    Submit feedback for a completed appointment.

    Rules:
    - The appointment must exist and belong to the current logged-in citizen.
    - Only one feedback submission allowed per appointment.
    """

    # ✅ Validate appointment belongs to the current citizen
    appointment = await db.appointment.find_unique(
        where={"appointment_id": payload.appointment_id}
    )
    if not appointment or appointment.citizen_id != current_user.citizen_id:
        raise HTTPException(status_code=403, detail="Invalid appointment")

    # ✅ Prevent duplicates
    existing = await feedback_repository.get_feedback_by_appointment_id(
        payload.appointment_id
    )
    if existing:
        raise HTTPException(status_code=400, detail="Feedback already submitted")

    # ✅ Create feedback
    feedback = await feedback_repository.create_feedback(
        citizen_id=current_user.citizen_id,
        data=payload.model_dump()
    )

    return {
        "status": "success",
        "feedback": {
            "id": feedback.feedback_id,
            "submission_date": feedback.submitted_at,
            "status": "submitted"
        },
    }
