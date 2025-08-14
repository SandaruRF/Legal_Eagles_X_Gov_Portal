from typing import Dict, Any, Optional
from datetime import datetime
from app.core.database import db
from app.db.admin.db_feedback import (
    get_feedback_list,
    get_feedback_by_id,
    get_feedback_stats,
    get_feedback_rating_by_service_stats,
)
from app.schemas.admin.feedback_schema import (
    FeedbackListResponse,
    FeedbackResponse,
    FeedbackStatsResponse,
)


async def get_all_feedback(
    department_id: str,
    page: int = 1,
    page_size: int = 10,
    rating_filter: Optional[int] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    service_filter: Optional[str] = None,
    search: Optional[str] = None,
) -> FeedbackListResponse:
    """Get paginated feedback list with filters for a specific department"""

    skip = (page - 1) * page_size

    # Parse date strings if provided
    parsed_date_from = None
    parsed_date_to = None

    if date_from:
        try:
            parsed_date_from = datetime.fromisoformat(date_from)
        except ValueError:
            pass

    if date_to:
        try:
            parsed_date_to = datetime.fromisoformat(date_to)
        except ValueError:
            pass

    result = await get_feedback_list(
        db=db,
        department_id=department_id,
        skip=skip,
        limit=page_size,
        rating_filter=rating_filter,
        date_from=parsed_date_from,
        date_to=parsed_date_to,
        service_filter=service_filter,
        search=search,
    )

    return FeedbackListResponse(**result)


async def get_feedback_details(feedback_id: str) -> Optional[FeedbackResponse]:
    """Get detailed feedback information"""

    return await get_feedback_by_id(db, feedback_id)


async def get_feedback_statistics(department_id: str) -> FeedbackStatsResponse:
    """Get comprehensive feedback statistics for a specific department"""

    stats = await get_feedback_stats(db, department_id)
    return FeedbackStatsResponse(**stats)


async def get_feedback_rating_by_service(department_id: str) -> Dict[str, Any]:
    """Get feedback rating statistics grouped by service/appointment type"""

    return await get_feedback_rating_by_service_stats(db, department_id)
