from prisma import Prisma
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from app.schemas.admin.feedback_schema import FeedbackResponse


async def get_feedback_list(
    db: Prisma,
    department_id: str,
    skip: int = 0,
    limit: int = 10,
    rating_filter: Optional[int] = None,
    date_from: Optional[datetime] = None,
    date_to: Optional[datetime] = None,
    service_filter: Optional[str] = None,
    search: Optional[str] = None,
) -> Dict[str, Any]:
    """Get paginated feedback list with filters for a specific department"""

    # Build where clause - always filter by department through appointment->service
    where_clause = {"appointment": {"service": {"department_id": department_id}}}

    if rating_filter:
        where_clause["rating"] = rating_filter

    if date_from and date_to:
        where_clause["submitted_at"] = {"gte": date_from, "lte": date_to}
    elif date_from:
        where_clause["submitted_at"] = {"gte": date_from}
    elif date_to:
        where_clause["submitted_at"] = {"lte": date_to}

    # Add additional filters to the existing appointment.service structure
    if service_filter:
        where_clause["appointment"]["service"]["service_id"] = service_filter

    if search:
        where_clause["OR"] = [
            {"comment": {"contains": search, "mode": "insensitive"}},
            {"citizen": {"full_name": {"contains": search, "mode": "insensitive"}}},
            {
                "appointment": {
                    "service": {"name": {"contains": search, "mode": "insensitive"}}
                }
            },
        ]

    # Get feedback with related data
    feedback_list = await db.feedback.find_many(
        where=where_clause,
        skip=skip,
        take=limit,
        order={"submitted_at": "desc"},
        include={"citizen": True, "appointment": {"include": {"service": True}}},
    )

    # Get total count
    total = await db.feedback.count(where=where_clause)

    # Calculate average rating manually (since aggregate is not available)
    if total > 0:
        all_feedback = await db.feedback.find_many(where=where_clause)
        total_rating = sum([f.rating for f in all_feedback])
        average_rating = total_rating / total
    else:
        average_rating = 0.0

    # Get rating distribution
    rating_distribution = {}
    for rating in range(1, 6):
        count = await db.feedback.count(where={**where_clause, "rating": rating})
        rating_distribution[str(rating)] = count

    # Calculate satisfaction rate (4-5 stars)
    satisfied_count = rating_distribution["4"] + rating_distribution["5"]
    satisfaction_rate = (satisfied_count / total * 100) if total > 0 else 0.0

    # Format response
    formatted_feedback = []
    for feedback in feedback_list:
        formatted_feedback.append(
            {
                "feedback_id": feedback.feedback_id,
                "appointment_id": feedback.appointment_id,
                "citizen_id": feedback.citizen_id,
                "rating": feedback.rating,
                "comment": feedback.comment,
                "submitted_at": feedback.submitted_at,
                "citizen_name": (
                    feedback.citizen.full_name if feedback.citizen else None
                ),
                "citizen_email": feedback.citizen.email if feedback.citizen else None,
                "service_name": (
                    feedback.appointment.service.name
                    if feedback.appointment and feedback.appointment.service
                    else None
                ),
                "service_description": (
                    feedback.appointment.service.description
                    if feedback.appointment and feedback.appointment.service
                    else None
                ),
                "appointment_datetime": (
                    feedback.appointment.appointment_datetime
                    if feedback.appointment
                    else None
                ),
                "appointment_reference": (
                    feedback.appointment.reference_number
                    if feedback.appointment
                    else None
                ),
            }
        )

    return {
        "feedback": formatted_feedback,
        "total": total,
        "average_rating": average_rating,
        "rating_distribution": rating_distribution,
        "satisfaction_rate": satisfaction_rate,
    }


async def get_feedback_by_id(
    db: Prisma, feedback_id: str
) -> Optional[FeedbackResponse]:
    """Get feedback by ID with all related data"""

    feedback = await db.feedback.find_unique(
        where={"feedback_id": feedback_id},
        include={"citizen": True, "appointment": {"include": {"service": True}}},
    )

    if not feedback:
        return None

    return FeedbackResponse(
        feedback_id=feedback.feedback_id,
        appointment_id=feedback.appointment_id,
        citizen_id=feedback.citizen_id,
        rating=feedback.rating,
        comment=feedback.comment,
        submitted_at=feedback.submitted_at,
        citizen_name=feedback.citizen.full_name if feedback.citizen else None,
        citizen_email=feedback.citizen.email if feedback.citizen else None,
        service_name=(
            feedback.appointment.service.name
            if feedback.appointment and feedback.appointment.service
            else None
        ),
        service_description=(
            feedback.appointment.service.description
            if feedback.appointment and feedback.appointment.service
            else None
        ),
        appointment_datetime=(
            feedback.appointment.appointment_datetime if feedback.appointment else None
        ),
        appointment_reference=(
            feedback.appointment.reference_number if feedback.appointment else None
        ),
    )


async def get_feedback_stats(db: Prisma, department_id: str) -> Dict[str, Any]:
    """Get feedback statistics for a specific department"""

    # Department filter for all queries
    department_filter = {"appointment": {"service": {"department_id": department_id}}}

    # Total feedback count
    total_count = await db.feedback.count(where=department_filter)

    # Calculate average rating manually
    if total_count > 0:
        all_feedback = await db.feedback.find_many(where=department_filter)
        total_rating = sum([f.rating for f in all_feedback])
        average_rating = total_rating / total_count
    else:
        average_rating = 0.0

    # Rating distribution
    rating_distribution = {}
    for rating in range(1, 6):
        count = await db.feedback.count(where={**department_filter, "rating": rating})
        rating_distribution[rating] = count

    # Satisfaction rate (4-5 stars)
    satisfied_count = rating_distribution[4] + rating_distribution[5]
    satisfaction_rate = (
        (satisfied_count / total_count * 100) if total_count > 0 else 0.0
    )

    # Recent feedback (last 30 days)
    thirty_days_ago = datetime.now() - timedelta(days=30)
    recent_count = await db.feedback.count(
        where={**department_filter, "submitted_at": {"gte": thirty_days_ago}}
    )

    # Monthly trend (last 12 months)
    monthly_trend = []
    for i in range(12):
        month_start = datetime.now().replace(day=1) - timedelta(days=30 * i)
        month_end = (
            month_start.replace(month=month_start.month + 1)
            if month_start.month < 12
            else month_start.replace(year=month_start.year + 1, month=1)
        )

        month_feedback = await db.feedback.find_many(
            where={
                **department_filter,
                "submitted_at": {"gte": month_start, "lt": month_end},
            }
        )

        month_count = len(month_feedback)
        month_average = 0.0
        if month_count > 0:
            total_rating = sum([f.rating for f in month_feedback])
            month_average = total_rating / month_count

        monthly_trend.append(
            {
                "month": month_start.strftime("%Y-%m"),
                "count": month_count,
                "average": month_average,
            }
        )

    return {
        "total_feedback": total_count,
        "average_rating": average_rating,
        "rating_distribution": rating_distribution,
        "satisfaction_rate": satisfaction_rate,
        "recent_feedback_count": recent_count,
        "monthly_trend": monthly_trend,
    }


async def get_feedback_rating_by_service_stats(
    db: Prisma, department_id: str
) -> Dict[str, Any]:
    """Get feedback rating statistics grouped by service/appointment type"""

    # Get all feedback with service details for the department
    feedback_with_services = await db.feedback.find_many(
        where={"appointment": {"service": {"department_id": department_id}}},
        include={
            "appointment": {
                "include": {
                    "service": True
                }
            }
        },
    )

    # Group by service and calculate stats
    service_stats = {}
    
    for feedback in feedback_with_services:
        service_name = feedback.appointment.service.name
        rating = feedback.rating
        
        if service_name not in service_stats:
            service_stats[service_name] = {
                "service_name": service_name,
                "total_feedback": 0,
                "total_rating": 0,
                "rating_distribution": {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
            }
        
        service_stats[service_name]["total_feedback"] += 1
        service_stats[service_name]["total_rating"] += rating
        service_stats[service_name]["rating_distribution"][rating] += 1
    
    # Calculate averages and satisfaction rates
    result = []
    for service_name, stats in service_stats.items():
        total = stats["total_feedback"]
        if total > 0:
            average_rating = stats["total_rating"] / total
            satisfaction_rate = ((stats["rating_distribution"][4] + stats["rating_distribution"][5]) / total) * 100
        else:
            average_rating = 0
            satisfaction_rate = 0
            
        result.append({
            "service_name": service_name,
            "total_feedback": total,
            "average_rating": round(average_rating, 2),
            "satisfaction_rate": round(satisfaction_rate, 1),
            "rating_distribution": stats["rating_distribution"]
        })
    
    # Sort by total feedback descending
    result.sort(key=lambda x: x["total_feedback"], reverse=True)
    
    return {"service_ratings": result}
