from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class AppointmentStatsSchema(BaseModel):
    total_appointments: int
    confirmed_appointments: int
    completed_appointments: int
    cancelled_appointments: int
    no_show_appointments: int
    booked_appointments: int


class HourlyDataSchema(BaseModel):
    hour: str
    appointments: int


class RecentAppointmentSchema(BaseModel):
    appointment_id: str
    citizen_name: str
    service_name: str
    appointment_datetime: datetime
    status: str
    reference_number: str


class FeedbackStatsSchema(BaseModel):
    total_feedback: int
    average_rating: float
    rating_distribution: dict  # {"1": count, "2": count, ...}


class PerformanceMetricsSchema(BaseModel):
    processing_efficiency: float  # completed/total * 100
    no_show_rate: float  # no_show/total * 100
    confirmation_rate: float  # confirmed/total * 100


class DashboardOverviewResponse(BaseModel):
    appointment_stats: AppointmentStatsSchema
    hourly_distribution: List[HourlyDataSchema]
    recent_appointments: List[RecentAppointmentSchema]
    feedback_stats: FeedbackStatsSchema
    performance_metrics: PerformanceMetricsSchema
    department_name: str
