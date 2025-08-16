from prisma import Prisma
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional


async def get_overall_hourly_distribution(db: Prisma, department_id: str) -> List[Dict[str, Any]]:
    """Get hourly appointment distribution for all appointments in department (8 AM to 5 PM)"""
    
    # Get all appointments for the department
    appointments = await db.appointment.find_many(
        where={
            "service": {
                "department_id": department_id
            }
        },
        include={
            "service": True
        }
    )
    
    # Group by business hours only (8 AM to 5 PM = hours 8-17)
    hourly_counts = {}
    for hour in range(8, 18):  # 8 AM to 5 PM (17:00)
        hourly_counts[f"{hour:02d}:00"] = 0
    
    for appointment in appointments:
        hour = appointment.appointment_datetime.hour
        if 8 <= hour <= 17:  # Only count business hours
            hour_key = f"{hour:02d}:00"
            hourly_counts[hour_key] += 1
    
    # Convert to list format, include all business hours (even 0 counts for consistent charting)
    hourly_data = [
        {"hour": hour, "appointments": count}
        for hour, count in sorted(hourly_counts.items())
    ]
    
    return hourly_data


async def get_all_services_hourly_distribution(db: Prisma, department_id: str) -> List[Dict[str, Any]]:
    """Get hourly appointment distribution for each service in the department (8 AM to 5 PM)"""
    
    # Get all services in the department
    services = await db.service.find_many(
        where={
            "department_id": department_id
        }
    )
    
    services_hourly_data = []
    
    for service in services:
        # Get appointments for this service
        appointments = await db.appointment.find_many(
            where={
                "service_id": service.service_id
            }
        )
        
        # Group by business hours only (8 AM to 5 PM = hours 8-17)
        hourly_counts = {}
        for hour in range(8, 18):  # 8 AM to 5 PM (17:00)
            hourly_counts[f"{hour:02d}:00"] = 0
        
        for appointment in appointments:
            hour = appointment.appointment_datetime.hour
            if 8 <= hour <= 17:  # Only count business hours
                hour_key = f"{hour:02d}:00"
                hourly_counts[hour_key] += 1
        
        # Convert to list format, include all business hours (even 0 counts for consistent charting)
        hourly_data = [
            {"hour": hour, "appointments": count}
            for hour, count in sorted(hourly_counts.items())
        ]
        
        services_hourly_data.append({
            "service_id": service.service_id,
            "service_name": service.name,
            "hourly_data": hourly_data
        })
    
    return services_hourly_data


async def get_popular_services(db: Prisma, department_id: str, limit: int = 5) -> List[Dict[str, Any]]:
    """Get most popular services by appointment count"""
    
    # Get all appointments with service info
    appointments = await db.appointment.find_many(
        where={
            "service": {
                "department_id": department_id
            }
        },
        include={
            "service": True
        }
    )
    
    # Count appointments per service
    service_counts = {}
    for appointment in appointments:
        service_id = appointment.service.service_id
        service_name = appointment.service.name
        if service_id not in service_counts:
            service_counts[service_id] = {"service_id": service_id, "name": service_name, "appointments": 0}
        service_counts[service_id]["appointments"] += 1
    
    # Sort by count and get top services
    popular_services = sorted(service_counts.values(), key=lambda x: x["appointments"], reverse=True)
    
    return popular_services[:limit]


async def get_status_distribution(db: Prisma, department_id: str) -> List[Dict[str, Any]]:
    """Get appointment status distribution for pie chart"""
    
    appointments = await db.appointment.find_many(
        where={
            "service": {
                "department_id": department_id
            }
        },
        include={
            "service": True
        }
    )
    
    # Count by status
    status_counts = {}
    for appointment in appointments:
        status = appointment.status
        status_counts[status] = status_counts.get(status, 0) + 1
    
    # Define colors for each status
    status_colors = {
        "Completed": "#28a745",
        "Confirmed": "#FEB600", 
        "Booked": "#1976d2",
        "NoShow": "#8C1F28",
        "Cancelled": "#d32f2f"
    }
    
    # Convert to required format, only include statuses with counts > 0
    status_data = [
        {
            "name": status,
            "value": count,
            "color": status_colors.get(status, "#666666")
        }
        for status, count in status_counts.items()
        if count > 0
    ]
    
    return status_data


async def get_peak_hour_info(db: Prisma, department_id: str) -> Dict[str, Any]:
    """Get peak hour information"""
    
    # Get hourly distribution
    hourly_data = await get_overall_hourly_distribution(db, department_id)
    
    if not hourly_data:
        return {"hour": "09:00", "appointments": 0}
    
    # Find peak hour
    peak_hour = max(hourly_data, key=lambda x: x["appointments"])
    return peak_hour


async def get_available_services(db: Prisma, department_id: str) -> List[Dict[str, Any]]:
    """Get list of services available in the department for dropdown"""
    
    services = await db.service.find_many(
        where={
            "department_id": department_id
        }
    )
    
    return [
        {"service_id": service.service_id, "name": service.name}
        for service in services
    ]


async def get_analytics_metrics(db: Prisma, department_id: str) -> Dict[str, Any]:
    """Calculate analytics metrics"""
    
    appointments = await db.appointment.find_many(
        where={
            "service": {
                "department_id": department_id
            }
        },
        include={
            "service": True
        }
    )
    
    total_appointments = len(appointments)
    no_show_count = len([a for a in appointments if a.status == "NoShow"])
    
    # Calculate metrics
    no_show_rate = round((no_show_count / total_appointments * 100), 1) if total_appointments > 0 else 0.0
    
    return {
        "total_appointments": total_appointments,
        "total_workload": total_appointments,  # Same as total for now
        "no_show_rate": no_show_rate,
        "avg_processing_time": "45 min"  # Mock data for now
    }


async def get_analytics_data(db: Prisma, department_id: str) -> Dict[str, Any]:
    """Get all analytics data for a department"""
    
    # Get all required data
    overall_hourly = await get_overall_hourly_distribution(db, department_id)
    
    # Get hourly distribution for ALL services (for client-side filtering)
    services_hourly = await get_all_services_hourly_distribution(db, department_id)
    
    popular_services = await get_popular_services(db, department_id)
    status_distribution = await get_status_distribution(db, department_id)
    peak_hour = await get_peak_hour_info(db, department_id)
    available_services = await get_available_services(db, department_id)
    metrics = await get_analytics_metrics(db, department_id)
    
    # Get department name
    department = await db.department.find_unique(
        where={"department_id": department_id}
    )
    department_name = department.name if department else "Unknown Department"
    
    return {
        "overall_hourly_distribution": overall_hourly,
        "services_hourly_distribution": services_hourly,
        "popular_services": popular_services,
        "status_distribution": status_distribution,
        "peak_hour": peak_hour,
        "available_services": available_services,
        "metrics": metrics,
        "department_name": department_name
    }
