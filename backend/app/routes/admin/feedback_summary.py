from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.auth import get_current_admin
from app.schemas.admin.feedback_summary import FeedbackSummaryResponse
from app.db.admin import feedback_repository

router = APIRouter(
    prefix="/admin/feedback",
    tags=["Admin Feedback"]
)


@router.get("/service/{service_id}/summary", response_model=FeedbackSummaryResponse)
async def service_feedback_summary(
    service_id: str,
    current_admin=Depends(get_current_admin),
    db: Prisma = Depends(get_db)
):
    """
    Returns feedback summary for a given service.
    Admins can only retrieve summaries for services in their own department.
    """

    # ✅ Check service belongs to admin's department
    service = await db.service.find_unique(where={"service_id": service_id})
    if not service:
        raise HTTPException(status_code=404, detail="Service not found")

    if service.department_id != current_admin.department_id:
        raise HTTPException(status_code=403, detail="Access denied for this service")

    summary = await feedback_repository.get_feedback_summary_for_service(service_id)

    return {
        "status": "success",
        "summary": summary
    }
