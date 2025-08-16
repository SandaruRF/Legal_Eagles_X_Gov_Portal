from app.db.admin.db_dashboard import get_dashboard_overview_data
from app.schemas.admin.dashboard_schema import DashboardOverviewResponse
from app.core.database import db
from typing import Dict, Any


async def get_dashboard_overview(department_id: str) -> DashboardOverviewResponse:
    """
    Get complete dashboard overview data for a department

    Args:
        department_id: The department ID to get data for

    Returns:
        DashboardOverviewResponse: Complete dashboard data

    Raises:
        Exception: If there's an error fetching the data
    """
    try:
        # Get all dashboard data
        dashboard_data = await get_dashboard_overview_data(db, department_id)

        # Return structured response
        return DashboardOverviewResponse(**dashboard_data)

    except Exception as e:
        raise Exception(f"Error fetching dashboard overview: {str(e)}")
