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
    PieChart,
    Pie,
    Cell,
} from "recharts";
import { MdTrendingUp, MdWarning, MdRocket, MdRefresh } from "react-icons/md";
import { useAuth } from "../contexts/AuthContext";
import config from "../config/api";

const Analytics = ({ departmentId }) => {
    const [analyticsData, setAnalyticsData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [selectedService, setSelectedService] = useState("all");

    const { token } = useAuth();
    const { API_BASE_URL, endpoints } = config;

    useEffect(() => {
        fetchAnalyticsData();
    }, [departmentId]);

    const fetchAnalyticsData = async () => {
        try {
            setLoading(true);
            setError("");

            const response = await fetch(
                `${API_BASE_URL}/api/admin/analytics`,
                {
                    headers: config.getAuthHeaders(token),
                }
            );

            if (!response.ok) {
                throw new Error(
                    `Failed to fetch analytics: ${response.status}`
                );
            }

            const data = await response.json();
            setAnalyticsData(data);
        } catch (error) {
            console.error("Error fetching analytics:", error);
            setError(error.message || "Failed to fetch analytics data");
        } finally {
            setLoading(false);
        }
    };

    // Loading state
    if (loading) {
        return (
            <div className="content-header">
                <h2>Department Analytics</h2>
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
                        Loading analytics data...
                    </p>
                </div>
            </div>
        );
    }

    // Error state
    if (error) {
        return (
            <div className="content-header">
                <h2>Department Analytics</h2>
                <div className="error-container">
                    <p className="error-message">
                        Error loading analytics: {error}
                    </p>
                    <button
                        onClick={fetchAnalyticsData}
                        className="retry-button"
                        style={{
                            padding: "0.5rem 1rem",
                            backgroundColor: "#4E6E63",
                            color: "white",
                            border: "none",
                            borderRadius: "4px",
                            cursor: "pointer",
                            marginTop: "1rem",
                        }}
                    >
                        Retry
                    </button>
                </div>
            </div>
        );
    }

    if (!analyticsData) return null;

    const {
        overall_hourly_distribution,
        services_hourly_distribution,
        popular_services,
        status_distribution,
        peak_hour,
        available_services,
        metrics,
        department_name,
    } = analyticsData;

    // Get current hourly data based on service selection
    const getCurrentHourlyData = () => {
        if (selectedService === "all") {
            return overall_hourly_distribution;
        }

        const serviceData = services_hourly_distribution.find(
            (service) => service.service_id === selectedService
        );
        return serviceData ? serviceData.hourly_data : [];
    };

    const currentHourlyData = getCurrentHourlyData();

    return (
        <div>
            <div className="content-header">
                <h2>Department Analytics</h2>
                <p className="content-subtitle">
                    Data insights to optimize {department_name}'s operations
                </p>
            </div>

            {/* Key Metrics */}
            <div className="stats-grid">
                <div className="stat-card">
                    <h3>Peak Booking Hour</h3>
                    <div className="stat-value" style={{ color: "#8C1F28" }}>
                        {peak_hour.hour}
                    </div>
                    <p className="stat-description">
                        {peak_hour.appointments} appointments
                    </p>
                </div>

                <div className="stat-card">
                    <h3>Total Daily Load</h3>
                    <div className="stat-value" style={{ color: "#FEB600" }}>
                        {metrics.total_workload}
                    </div>
                    <p className="stat-description">Appointments scheduled</p>
                </div>

                <div className="stat-card">
                    <h3>No-Show Rate</h3>
                    <div className="stat-value" style={{ color: "#8C1F28" }}>
                        {metrics.no_show_rate}%
                    </div>
                    <p className="stat-description">Optimization opportunity</p>
                </div>

                <div className="stat-card">
                    <h3>Avg Processing Time</h3>
                    <div className="stat-value" style={{ color: "#28a745" }}>
                        {metrics.avg_processing_time}
                    </div>
                    <p className="stat-description">Per appointment</p>
                </div>
            </div>

            {/* Charts Grid */}
            <div className="charts-section">
                {/* Hourly Distribution with Service Filter */}
                <div className="chart-card">
                    <div
                        style={{
                            display: "flex",
                            justifyContent: "space-between",
                            alignItems: "center",
                            marginBottom: "1rem",
                        }}
                    >
                        <h3>Hourly Appointment Distribution</h3>
                        <select
                            value={selectedService}
                            onChange={(e) => setSelectedService(e.target.value)}
                            style={{
                                padding: "0.5rem",
                                borderRadius: "4px",
                                border: "1px solid #ddd",
                                backgroundColor: "white",
                                cursor: "pointer",
                                minWidth: "150px",
                            }}
                        >
                            <option value="all">All Services</option>
                            {available_services.map((service) => (
                                <option
                                    key={service.service_id}
                                    value={service.service_id}
                                >
                                    {service.name}
                                </option>
                            ))}
                        </select>
                    </div>
                    <ResponsiveContainer width="100%" height={300}>
                        <LineChart data={currentHourlyData}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="hour" />
                            <YAxis />
                            <Tooltip
                                formatter={(value) => [value, "Appointments"]}
                                labelStyle={{ color: "#333" }}
                            />
                            <Line
                                type="monotone"
                                dataKey="appointments"
                                stroke="#8C1F28"
                                strokeWidth={3}
                                dot={{ fill: "#8C1F28", strokeWidth: 2, r: 4 }}
                                activeDot={{
                                    r: 6,
                                    stroke: "#8C1F28",
                                    strokeWidth: 2,
                                }}
                            />
                        </LineChart>
                    </ResponsiveContainer>
                </div>

                {/* Status Distribution */}
                <div className="chart-card">
                    <h3>Appointment Status Distribution</h3>
                    <ResponsiveContainer width="100%" height={300}>
                        <PieChart>
                            <Pie
                                data={status_distribution}
                                cx="50%"
                                cy="50%"
                                outerRadius={80}
                                dataKey="value"
                                label={({ name, value, percent }) =>
                                    `${name}: ${(percent * 100).toFixed(0)}%`
                                }
                            >
                                {status_distribution.map((entry, index) => (
                                    <Cell
                                        key={`cell-${index}`}
                                        fill={entry.color}
                                    />
                                ))}
                            </Pie>
                            <Tooltip />
                        </PieChart>
                    </ResponsiveContainer>
                </div>
            </div>

            {/* Service Popularity and Recommendations */}
            <div className="charts-section">
                {/* Service Popularity */}
                <div className="chart-card">
                    <h3>Most Popular Services</h3>
                    <ResponsiveContainer width="100%" height={300}>
                        <BarChart data={popular_services}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="name" />
                            <YAxis />
                            <Tooltip />
                            <Bar dataKey="appointments" fill="#8C1F28" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>

                {/* Optimization Insights */}
                <div className="chart-card">
                    <h3>Optimization Insights</h3>
                    <div style={{ padding: "1rem 0" }}>
                        <div style={{ marginBottom: "1.5rem" }}>
                            <h4
                                style={{
                                    color: "#4E6E63",
                                    marginBottom: "0.5rem",
                                    display: "flex",
                                    alignItems: "center",
                                    gap: "0.5rem",
                                }}
                            >
                                <MdTrendingUp /> Peak Hours
                            </h4>
                            <p
                                style={{
                                    color: "#666",
                                    marginBottom: "0.5rem",
                                }}
                            >
                                Highest demand at {peak_hour.hour} with{" "}
                                {peak_hour.appointments} appointments
                            </p>
                            <p style={{ color: "#666", fontSize: "0.9rem" }}>
                                Consider allocating more staff during this
                                period
                            </p>
                        </div>

                        <div style={{ marginBottom: "1.5rem" }}>
                            <h4
                                style={{
                                    color: "#FEB600",
                                    marginBottom: "0.5rem",
                                    display: "flex",
                                    alignItems: "center",
                                    gap: "0.5rem",
                                }}
                            >
                                <MdWarning /> No-Show Rate Analysis
                            </h4>
                            <p
                                style={{
                                    color: "#666",
                                    marginBottom: "0.5rem",
                                }}
                            >
                                {metrics.no_show_rate}% no-show rate detected
                            </p>
                            <p style={{ color: "#666", fontSize: "0.9rem" }}>
                                Calculated as: (No-Show appointments ÷ Total
                                appointments) × 100
                            </p>
                        </div>

                        <div>
                            <h4
                                style={{
                                    color: "#28a745",
                                    marginBottom: "0.5rem",
                                    display: "flex",
                                    alignItems: "center",
                                    gap: "0.5rem",
                                }}
                            >
                                <MdRocket /> Processing Time Metrics
                            </h4>
                            <p
                                style={{
                                    color: "#666",
                                    marginBottom: "0.5rem",
                                }}
                            >
                                Average processing time:{" "}
                                {metrics.avg_processing_time}
                            </p>
                            <p style={{ color: "#666", fontSize: "0.9rem" }}>
                                Based on historical data analysis of completed
                                appointments and service duration patterns
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Analytics;
