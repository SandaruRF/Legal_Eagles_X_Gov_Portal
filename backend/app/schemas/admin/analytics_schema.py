from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime

class HourlyDataSchema(BaseModel):
    hour: str
    appointments: int

class ServicePopularitySchema(BaseModel):
    service_id: str
    name: str
    appointments: int

class StatusDistributionSchema(BaseModel):
    name: str
    value: int
    color: str

class PeakHourSchema(BaseModel):
    hour: str
    appointments: int

class ServiceOptionSchema(BaseModel):
    service_id: str
    name: str

class ServiceHourlyDistributionSchema(BaseModel):
    service_id: str
    service_name: str
    hourly_data: List[HourlyDataSchema]

class AnalyticsMetricsSchema(BaseModel):
    total_appointments: int
    total_workload: int
    no_show_rate: float
    avg_processing_time: str  # Mock for now, can be calculated later

class AnalyticsResponse(BaseModel):
    # Overall hourly distribution (all appointments)
    overall_hourly_distribution: List[HourlyDataSchema]
    
    # Hourly distribution for each service (for dropdown filtering)
    services_hourly_distribution: List[ServiceHourlyDistributionSchema]
    
    # Most popular services
    popular_services: List[ServicePopularitySchema]
    
    # Status distribution for pie chart
    status_distribution: List[StatusDistributionSchema]
    
    # Peak hour information
    peak_hour: PeakHourSchema
    
    # Available services for dropdown
    available_services: List[ServiceOptionSchema]
    
    # Key metrics
    metrics: AnalyticsMetricsSchema
    
    # Department info
    department_name: str
