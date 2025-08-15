from app.db.admin.db_analytics import get_analytics_data
from app.schemas.admin.analytics_schema import AnalyticsResponse
from app.core.database import db


async def get_analytics_overview(department_id: str) -> AnalyticsResponse:
    """
    Get complete analytics data for a department including all services hourly distributions
    
    Args:
        department_id: The department ID to get analytics for
        
    Returns:
        AnalyticsResponse: Complete analytics data including all services for client-side filtering
        
    Raises:
        Exception: If there's an error fetching the data
    """
    try:
        # Get all analytics data (includes hourly distribution for all services)
        analytics_data = await get_analytics_data(db, department_id)
        
        # Return structured response
        return AnalyticsResponse(**analytics_data)
        
    except Exception as e:
        raise Exception(f"Error fetching analytics data: {str(e)}")
