from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional
from app.core.auth import get_current_admin
from app.services.admin.feedback_service import (
    get_all_feedback,
    get_feedback_details,
    get_feedback_statistics,
)
from app.schemas.admin.feedback_schema import (
    FeedbackListResponse,
    FeedbackResponse,
    FeedbackStatsResponse,
)

router = APIRouter()


@router.get("/feedback", response_model=FeedbackListResponse)
async def get_feedback_list(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(10, ge=1, le=100, description="Items per page"),
    rating_filter: Optional[int] = Query(
        None, ge=1, le=5, description="Filter by rating"
    ),
    date_from: Optional[str] = Query(None, description="Filter from date (ISO format)"),
    date_to: Optional[str] = Query(None, description="Filter to date (ISO format)"),
    service_filter: Optional[str] = Query(None, description="Filter by service ID"),
    search: Optional[str] = Query(
        None, description="Search in comments, citizen names, service names"
    ),
    current_admin=Depends(get_current_admin),
):
    """
    Get paginated feedback list with optional filters.
    Accessible by all authenticated admin users.
    """

    try:
        result = await get_all_feedback(
            department_id=current_admin.department_id,
            page=page,
            page_size=page_size,
            rating_filter=rating_filter,
            date_from=date_from,
            date_to=date_to,
            service_filter=service_filter,
            search=search,
        )
        return result

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching feedback: {str(e)}"
        )


@router.get("/feedback/stats", response_model=FeedbackStatsResponse)
async def get_feedback_statistics_endpoint(current_admin=Depends(get_current_admin)):
    """
    Get comprehensive feedback statistics.
    Accessible by all authenticated admin users.
    """

    try:
        stats = await get_feedback_statistics(current_admin.department_id)
        return stats

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching feedback statistics: {str(e)}"
        )


@router.get("/feedback/{feedback_id}", response_model=FeedbackResponse)
async def get_feedback_details_endpoint(
    feedback_id: str, current_admin=Depends(get_current_admin)
):
    """
    Get detailed feedback information by ID.
    Accessible by all authenticated admin users.
    """

    try:
        feedback = await get_feedback_details(feedback_id)

        if not feedback:
            raise HTTPException(status_code=404, detail="Feedback not found")

        return feedback

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching feedback details: {str(e)}"
        )
