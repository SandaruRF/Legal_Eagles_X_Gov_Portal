import React from "react";
import {
    LineChart,
    Line,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    ResponsiveContainer,
    BarChart,
    Bar,
} from "recharts";
import appointmentsData from "../data/appointments.json";
import analyticsData from "../data/analytics.json";
import feedbackData from "../data/feedback.json";

const Overview = ({ departmentId }) => {
    // Filter data for current department
    const departmentAppointments = appointmentsData.filter(
        (apt) => apt.department_id === departmentId
    );
    const departmentAnalytics = analyticsData.filter(
        (data) => data.department_id === departmentId
    );
    const departmentFeedback = feedbackData.filter(
        (fb) => fb.department_id === departmentId
    );

    // Calculate stats
    const totalAppointments = departmentAppointments.length;
    const confirmedAppointments = departmentAppointments.filter(
        (apt) => apt.status === "Confirmed"
    ).length;
    const completedAppointments = departmentAppointments.filter(
        (apt) => apt.status === "Completed"
    ).length;
    const noShowAppointments = departmentAppointments.filter(
        (apt) => apt.status === "NoShow"
    ).length;

    // Calculate average rating
    const avgRating =
        departmentFeedback.length > 0
            ? (
                  departmentFeedback.reduce((sum, fb) => sum + fb.rating, 0) /
                  departmentFeedback.length
              ).toFixed(1)
            : 0;

    // Prepare hourly chart data
    const hourlyData = departmentAnalytics.map((data) => ({
        hour: data.hour,
        appointments: data.appointments,
    }));

    // Get recent appointments
    const recentAppointments = departmentAppointments
        .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
        .slice(0, 5);

    const getStatusBadgeClass = (status) => {
        return `status-badge status-${status.toLowerCase().replace(" ", "")}`;
    };

    return (
        <div>
            <div className="content-header">
                <h2>Dashboard Overview</h2>
                <p className="content-subtitle">
                    Welcome back! Here's what's happening in your department
                    today.
                </p>
            </div>

            {/* Stats Grid */}
            <div className="stats-grid">
                <div className="stat-card appointments">
                    <h3>Total Appointments</h3>
                    <div className="stat-value">{totalAppointments}</div>
                    <p className="stat-description">All time appointments</p>
                </div>

                <div className="stat-card confirmed">
                    <h3>Confirmed Today</h3>
                    <div className="stat-value">{confirmedAppointments}</div>
                    <p className="stat-description">Ready for processing</p>
                </div>

                <div className="stat-card completed">
                    <h3>Completed</h3>
                    <div className="stat-value">{completedAppointments}</div>
                    <p className="stat-description">Successfully processed</p>
                </div>

                <div className="stat-card no-show">
                    <h3>No Shows</h3>
                    <div className="stat-value">{noShowAppointments}</div>
                    <p className="stat-description">Missed appointments</p>
                </div>
            </div>

            {/* Charts Section */}
            <div className="charts-section">
                {/* Hourly Appointments Chart */}
                <div className="chart-card">
                    <h3>Today's Appointment Distribution</h3>
                    <ResponsiveContainer width="100%" height={300}>
                        <BarChart data={hourlyData}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="hour" />
                            <YAxis />
                            <Tooltip />
                            <Bar dataKey="appointments" fill="#8C1F28" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>

                {/* Recent Activity */}
                <div className="chart-card">
                    <h3>Recent Appointments</h3>
                    <div style={{ maxHeight: "300px", overflowY: "auto" }}>
                        {recentAppointments.map((appointment) => (
                            <div
                                key={appointment.appointment_id}
                                style={{
                                    padding: "0.75rem",
                                    borderBottom: "1px solid #e9ecef",
                                    display: "flex",
                                    justifyContent: "space-between",
                                    alignItems: "center",
                                }}
                            >
                                <div>
                                    <div style={{ fontWeight: "500" }}>
                                        {appointment.citizen_name}
                                    </div>
                                    <div
                                        style={{
                                            fontSize: "0.9rem",
                                            color: "#666",
                                        }}
                                    >
                                        {appointment.service_name}
                                    </div>
                                    <div
                                        style={{
                                            fontSize: "0.8rem",
                                            color: "#999",
                                        }}
                                    >
                                        {new Date(
                                            appointment.appointment_datetime
                                        ).toLocaleDateString()}
                                    </div>
                                </div>
                                <span
                                    className={getStatusBadgeClass(
                                        appointment.status
                                    )}
                                >
                                    {appointment.status}
                                </span>
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            {/* Quick Stats */}
            <div className="feedback-section">
                <h3>Department Performance</h3>
                <div className="feedback-stats">
                    <div className="stat-card">
                        <h3>Average Rating</h3>
                        <div
                            className="stat-value"
                            style={{ color: "#8C1F28" }}
                        >
                            {avgRating}/5.0
                        </div>
                        <p className="stat-description">
                            Based on {departmentFeedback.length} reviews
                        </p>
                    </div>

                    <div className="stat-card">
                        <h3>Processing Efficiency</h3>
                        <div
                            className="stat-value"
                            style={{ color: "#28a745" }}
                        >
                            {totalAppointments > 0
                                ? Math.round(
                                      (completedAppointments /
                                          totalAppointments) *
                                          100
                                  )
                                : 0}
                            %
                        </div>
                        <p className="stat-description">Completion rate</p>
                    </div>

                    <div className="stat-card">
                        <h3>No-Show Rate</h3>
                        <div
                            className="stat-value"
                            style={{ color: "#8C1F28" }}
                        >
                            {totalAppointments > 0
                                ? Math.round(
                                      (noShowAppointments / totalAppointments) *
                                          100
                                  )
                                : 0}
                            %
                        </div>
                        <p className="stat-description">Missed appointments</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Overview;
