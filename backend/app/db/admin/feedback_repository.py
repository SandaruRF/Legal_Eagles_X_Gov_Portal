from app.core.database import db
from typing import Dict, Any


async def get_feedback_summary_for_service(service_id: str) -> Dict[str, Any]:
    """
    Fetch feedback summary for all appointments of the given service_id.
    """

    feedbacks = await db.feedback.find_many(
        where={
            "appointment": {
                "service_id": service_id
            }
        },
        include={"appointment": True},
        order={"submitted_at": "desc"}
    )

    if not feedbacks:
        return {
            "total_feedback": 0,
            "average_rating": 0.0,
            "rating_distribution": {
                "star_5": 0,
                "star_4": 0,
                "star_3": 0,
                "star_2": 0,
                "star_1": 0
            },
            "recent_comments": []
        }

    total_feedback = len(feedbacks)
    average_rating = sum(f.rating for f in feedbacks) / total_feedback

    distribution = {
        "star_5": 0,
        "star_4": 0,
        "star_3": 0,
        "star_2": 0,
        "star_1": 0
    }
    for f in feedbacks:
        distribution[f"star_{f.rating}"] += 1

    # Take only latest 5 comments that are non-empty
    recent_comments = [
        {
            "rating": f.rating,
            "comment": f.comment,
            "date": f.submitted_at.date().isoformat()
        }
        for f in feedbacks if f.comment
    ][:5]

    return {
        "total_feedback": total_feedback,
        "average_rating": round(average_rating, 1),
        "rating_distribution": distribution,
        "recent_comments": recent_comments
    }
