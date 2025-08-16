from fastapi import APIRouter, Depends, HTTPException, status
from app.core.auth import get_current_admin
from app.schemas.admin.analytics_schema import AnalyticsResponse
from app.services.admin.analytics_service import get_analytics_overview

router = APIRouter()


@router.get("/analytics", response_model=AnalyticsResponse)
async def get_analytics_data_endpoint(
    current_admin=Depends(get_current_admin)
):
    """
    Get complete analytics data for the admin's department
    
    Returns:
        AnalyticsResponse: Complete analytics data including:
        - Overall hourly distribution (all appointments)
        - Hourly distribution for each service (for client-side filtering)
        - Most popular services
        - Status distribution for pie charts
        - Peak hour information
        - Available services for dropdown
        - Key metrics and department info
    """
    try:
        # Get analytics data for the admin's department (includes all services data)
        analytics_data = await get_analytics_overview(current_admin.department_id)
        return analytics_data
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching analytics data: {str(e)}"
        )
