from prisma import Prisma
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional


async def get_appointment_stats_by_department(
    db: Prisma, department_id: str
) -> Dict[str, int]:
    """Get appointment statistics for a department"""

    # Get all appointments for the department through services
    appointments = await db.appointment.find_many(
        where={"service": {"department_id": department_id}}, include={"service": True}
    )

    stats = {
        "total_appointments": len(appointments),
        "confirmed_appointments": len(
            [a for a in appointments if a.status == "Confirmed"]
        ),
        "completed_appointments": len(
            [a for a in appointments if a.status == "Completed"]
        ),
        "cancelled_appointments": len(
            [a for a in appointments if a.status == "Cancelled"]
        ),
        "no_show_appointments": len([a for a in appointments if a.status == "NoShow"]),
        "booked_appointments": len([a for a in appointments if a.status == "Booked"]),
    }

    return stats


async def get_hourly_distribution_by_department(
    db: Prisma, department_id: str
) -> List[Dict[str, Any]]:
    """Get hourly appointment distribution for today"""

    # Get today's date range
    today = datetime.now().date()
    start_of_day = datetime.combine(today, datetime.min.time())
    end_of_day = datetime.combine(today, datetime.max.time())

    # Get today's appointments for the department
    appointments = await db.appointment.find_many(
        where={
            "service": {"department_id": department_id},
            "appointment_datetime": {"gte": start_of_day, "lte": end_of_day},
        },
        include={"service": True},
    )

    # Group by hour
    hourly_counts = {}
    for hour in range(24):
        hourly_counts[f"{hour:02d}:00"] = 0

    for appointment in appointments:
        hour_key = f"{appointment.appointment_datetime.hour:02d}:00"
        hourly_counts[hour_key] += 1

    # Convert to list format
    hourly_data = [
        {"hour": hour, "appointments": count}
        for hour, count in hourly_counts.items()
        if count > 0  # Only include hours with appointments
    ]

    return hourly_data


async def get_recent_appointments_by_department(
    db: Prisma, department_id: str, limit: int = 5
) -> List[Dict[str, Any]]:
    """Get recent appointments for a department"""

    appointments = await db.appointment.find_many(
        where={"service": {"department_id": department_id}},
        include={"citizen": True, "service": True},
        order={"created_at": "desc"},
        take=limit,
    )

    recent_appointments = []
    for appointment in appointments:
        recent_appointments.append(
            {
                "appointment_id": appointment.appointment_id,
                "citizen_name": appointment.citizen.full_name,
                "service_name": appointment.service.name,
                "appointment_datetime": appointment.appointment_datetime,
                "status": appointment.status,
                "reference_number": appointment.reference_number,
            }
        )

    return recent_appointments


async def get_feedback_stats_by_department(
    db: Prisma, department_id: str
) -> Dict[str, Any]:
    """Get feedback statistics for a department"""

    # Get all feedback for appointments in this department
    feedback_records = await db.feedback.find_many(
        where={"appointment": {"service": {"department_id": department_id}}},
        include={"appointment": {"include": {"service": True}}},
    )

    if not feedback_records:
        return {
            "total_feedback": 0,
            "average_rating": 0.0,
            "rating_distribution": {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0},
        }

    # Calculate statistics
    total_feedback = len(feedback_records)
    total_rating = sum(fb.rating for fb in feedback_records)
    average_rating = (
        round(total_rating / total_feedback, 1) if total_feedback > 0 else 0.0
    )

    # Rating distribution
    rating_distribution = {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0}
    for feedback in feedback_records:
        rating_distribution[str(feedback.rating)] += 1

    return {
        "total_feedback": total_feedback,
        "average_rating": average_rating,
        "rating_distribution": rating_distribution,
    }


async def get_department_name(db: Prisma, department_id: str) -> Optional[str]:
    """Get department name by ID"""

    department = await db.department.find_unique(where={"department_id": department_id})

    return department.name if department else None


async def get_dashboard_overview_data(db: Prisma, department_id: str) -> Dict[str, Any]:
    """Get all dashboard overview data for a department"""

    # Get all data concurrently for better performance
    appointment_stats = await get_appointment_stats_by_department(db, department_id)
    hourly_distribution = await get_hourly_distribution_by_department(db, department_id)
    recent_appointments = await get_recent_appointments_by_department(db, department_id)
    feedback_stats = await get_feedback_stats_by_department(db, department_id)
    department_name = await get_department_name(db, department_id)

    # Calculate performance metrics
    total = appointment_stats["total_appointments"]
    completed = appointment_stats["completed_appointments"]
    no_show = appointment_stats["no_show_appointments"]
    confirmed = appointment_stats["confirmed_appointments"]

    performance_metrics = {
        "processing_efficiency": (
            round((completed / total * 100), 1) if total > 0 else 0.0
        ),
        "no_show_rate": round((no_show / total * 100), 1) if total > 0 else 0.0,
        "confirmation_rate": round((confirmed / total * 100), 1) if total > 0 else 0.0,
    }

    return {
        "appointment_stats": appointment_stats,
        "hourly_distribution": hourly_distribution,
        "recent_appointments": recent_appointments,
        "feedback_stats": feedback_stats,
        "performance_metrics": performance_metrics,
        "department_name": department_name or "Unknown Department",
    }
