import React, { useState, useEffect } from "react";
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
import { MdRefresh } from "react-icons/md";
import { useAuth } from "../contexts/AuthContext";
import config from "../config/api";

const Overview = ({ departmentId }) => {
    const [dashboardData, setDashboardData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");

    const { token } = useAuth();
    const { API_BASE_URL } = config;

    useEffect(() => {
        const fetchDashboardData = async () => {
            try {
                setLoading(true);
                setError("");

                const response = await fetch(
                    `${API_BASE_URL}/api/admin/dashboard/overview`,
                    {
                        headers: config.getAuthHeaders(token),
                    }
                );

                if (!response.ok) {
                    throw new Error(
                        `Failed to fetch dashboard data: ${response.status}`
                    );
                }

                const data = await response.json();
                setDashboardData(data);
            } catch (error) {
                console.error("Error fetching dashboard data:", error);
                setError("Failed to load dashboard data. Please try again.");
            } finally {
                setLoading(false);
            }
        };

        fetchDashboardData();
    }, [departmentId, token, API_BASE_URL]);

    // Loading state
    if (loading) {
        return (
            <div>
                <div className="content-header">
                    <h2>Dashboard Overview</h2>
                    <p className="content-subtitle">
                        Welcome back! Here's what's happening in your department
                        today.
                    </p>
                </div>
                <div
                    style={{
                        display: "flex",
                        justifyContent: "center",
                        alignItems: "center",
                        minHeight: "300px",
                        flexDirection: "column",
                        gap: "1rem",
                    }}
                >
                    <MdRefresh
                        style={{
                            fontSize: "3rem",
                            color: "#4E6E63",
                            animation: "spin 1s linear infinite",
                        }}
                    />
                    <p style={{ color: "#6c757d", fontSize: "1.1rem" }}>
                        Loading dashboard data...
                    </p>
                </div>
            </div>
        );
    }

    // Error state
    if (error) {
        return (
            <div>
                <div className="content-header">
                    <h2>Dashboard Overview</h2>
                    <p className="content-subtitle">
                        Welcome back! Here's what's happening in your department
                        today.
                    </p>
                </div>
                <div className="error-container">
                    <p className="error-message">
                        Error loading dashboard: {error}
                    </p>
                    <button
                        onClick={() => window.location.reload()}
                        className="retry-btn"
                    >
                        Retry
                    </button>
                </div>
            </div>
        );
    }

    // Extract data from API response
    const {
        appointment_stats,
        hourly_distribution,
        recent_appointments,
        feedback_stats,
        performance_metrics,
        department_name,
    } = dashboardData;

    const getStatusBadgeClass = (status) => {
        return `status-badge status-${status.toLowerCase().replace(" ", "")}`;
    };

    return (
        <div>
            <div className="content-header">
                <h2>Dashboard Overview</h2>
                <p className="content-subtitle">
                    Welcome back! Here's what's happening in {department_name}{" "}
                    today.
                </p>
            </div>

            {/* Stats Grid */}
            <div className="stats-grid">
                <div className="stat-card appointments">
                    <h3>Total Appointments</h3>
                    <div className="stat-value">
                        {appointment_stats.total_appointments}
                    </div>
                    <p className="stat-description">All time appointments</p>
                </div>

                <div className="stat-card confirmed">
                    <h3>Confirmed Today</h3>
                    <div className="stat-value">
                        {appointment_stats.confirmed_appointments}
                    </div>
                    <p className="stat-description">Ready for processing</p>
                </div>

                <div className="stat-card completed">
                    <h3>Completed</h3>
                    <div className="stat-value">
                        {appointment_stats.completed_appointments}
                    </div>
                    <p className="stat-description">Successfully processed</p>
                </div>

                <div className="stat-card no-show">
                    <h3>No Shows</h3>
                    <div className="stat-value">
                        {appointment_stats.no_show_appointments}
                    </div>
                    <p className="stat-description">Missed appointments</p>
                </div>
            </div>

            {/* Charts Section */}
            <div className="charts-section">
                {/* Hourly Appointments Chart */}
                <div className="chart-card">
                    <h3>Today's Appointment Distribution</h3>
                    <ResponsiveContainer width="100%" height={300}>
                        <BarChart data={hourly_distribution}>
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
                        {recent_appointments.map((appointment) => (
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
                        {recent_appointments.length === 0 && (
                            <div
                                style={{
                                    padding: "2rem",
                                    textAlign: "center",
                                    color: "#666",
                                }}
                            >
                                No recent appointments found
                            </div>
                        )}
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
                            {feedback_stats.average_rating}/5.0
                        </div>
                        <p className="stat-description">
                            Based on {feedback_stats.total_feedback} reviews
                        </p>
                    </div>

                    <div className="stat-card">
                        <h3>Processing Efficiency</h3>
                        <div
                            className="stat-value"
                            style={{ color: "#28a745" }}
                        >
                            {performance_metrics.processing_efficiency}%
                        </div>
                        <p className="stat-description">Completion rate</p>
                    </div>

                    <div className="stat-card">
                        <h3>No-Show Rate</h3>
                        <div
                            className="stat-value"
                            style={{ color: "#8C1F28" }}
                        >
                            {performance_metrics.no_show_rate}%
                        </div>
                        <p className="stat-description">Missed appointments</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Overview;
