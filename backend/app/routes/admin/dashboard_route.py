from fastapi import APIRouter, Depends, HTTPException, status
from app.core.auth import get_current_admin
from app.schemas.admin.dashboard_schema import DashboardOverviewResponse
from app.services.admin.dashboard_service import get_dashboard_overview

router = APIRouter()


@router.get("/overview", response_model=DashboardOverviewResponse)
async def get_dashboard_overview_endpoint(current_admin=Depends(get_current_admin)):
    """
    Get complete dashboard overview data for the admin's department

    Returns:
        DashboardOverviewResponse: Complete dashboard statistics and metrics
    """
    try:
        # Get dashboard data for the admin's department
        dashboard_data = await get_dashboard_overview(current_admin.department_id)
        return dashboard_data

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching dashboard overview: {str(e)}",
        )
