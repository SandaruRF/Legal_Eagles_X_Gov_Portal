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
    PieChart,
    Pie,
    Cell,
} from "recharts";
import { MdTrendingUp, MdWarning, MdRocket } from "react-icons/md";
import appointmentsData from "../data/appointments.json";
import analyticsData from "../data/analytics.json";

const Analytics = ({ departmentId }) => {
    // Filter data for current department
    const departmentAppointments = appointmentsData.filter(
        (apt) => apt.department_id === departmentId
    );
    const departmentAnalytics = analyticsData.filter(
        (data) => data.department_id === departmentId
    );

    // Prepare hourly data for line chart
    const hourlyData = departmentAnalytics.map((data) => ({
        hour: data.hour,
        appointments: data.appointments,
    }));

    // Calculate peak hours
    const peakHour =
        departmentAnalytics.length > 0
            ? departmentAnalytics.reduce((max, current) =>
                  current.appointments > max.appointments ? current : max
              )
            : { hour: "9:00 AM", appointments: 0 };

    // Prepare status distribution data
    const statusData = [
        {
            name: "Completed",
            value: departmentAppointments.filter(
                (apt) => apt.status === "Completed"
            ).length,
            color: "#28a745",
        },
        {
            name: "Confirmed",
            value: departmentAppointments.filter(
                (apt) => apt.status === "Confirmed"
            ).length,
            color: "#FEB600",
        },
        {
            name: "Booked",
            value: departmentAppointments.filter(
                (apt) => apt.status === "Booked"
            ).length,
            color: "#1976d2",
        },
        {
            name: "No Show",
            value: departmentAppointments.filter(
                (apt) => apt.status === "NoShow"
            ).length,
            color: "#8C1F28",
        },
        {
            name: "Cancelled",
            value: departmentAppointments.filter(
                (apt) => apt.status === "Cancelled"
            ).length,
            color: "#d32f2f",
        },
    ].filter((item) => item.value > 0);

    // Calculate metrics
    const totalAppointments = departmentAppointments.length;
    const avgProcessingTime = "45 min"; // Mock data
    const totalWorkload =
        departmentAnalytics.length > 0
            ? departmentAnalytics.reduce(
                  (sum, data) => sum + data.appointments,
                  0
              )
            : 0;
    const noShowRate =
        totalAppointments > 0
            ? (
                  (departmentAppointments.filter(
                      (apt) => apt.status === "NoShow"
                  ).length /
                      totalAppointments) *
                  100
              ).toFixed(1)
            : 0;

    // Service popularity data
    const serviceStats = {};
    departmentAppointments.forEach((apt) => {
        serviceStats[apt.service_name] =
            (serviceStats[apt.service_name] || 0) + 1;
    });

    const serviceData = Object.entries(serviceStats)
        .map(([name, count]) => ({ name, appointments: count }))
        .sort((a, b) => b.appointments - a.appointments)
        .slice(0, 5);

    return (
        <div>
            <div className="content-header">
                <h2>Department Analytics</h2>
                <p className="content-subtitle">
                    Data insights to optimize your department's operations
                </p>
            </div>

            {/* Key Metrics */}
            <div className="stats-grid">
                <div className="stat-card">
                    <h3>Peak Booking Hour</h3>
                    <div className="stat-value" style={{ color: "#8C1F28" }}>
                        {peakHour.hour}
                    </div>
                    <p className="stat-description">
                        {peakHour.appointments} appointments
                    </p>
                </div>

                <div className="stat-card">
                    <h3>Total Daily Load</h3>
                    <div className="stat-value" style={{ color: "#FEB600" }}>
                        {totalWorkload}
                    </div>
                    <p className="stat-description">Appointments scheduled</p>
                </div>

                <div className="stat-card">
                    <h3>No-Show Rate</h3>
                    <div className="stat-value" style={{ color: "#8C1F28" }}>
                        {noShowRate}%
                    </div>
                    <p className="stat-description">Optimization opportunity</p>
                </div>

                <div className="stat-card">
                    <h3>Avg Processing Time</h3>
                    <div className="stat-value" style={{ color: "#28a745" }}>
                        {avgProcessingTime}
                    </div>
                    <p className="stat-description">Per appointment</p>
                </div>
            </div>

            {/* Charts Grid */}
            <div className="charts-section">
                {/* Hourly Distribution */}
                <div className="chart-card">
                    <h3>Hourly Appointment Distribution</h3>
                    <ResponsiveContainer width="100%" height={300}>
                        <LineChart data={hourlyData}>
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
                                data={statusData}
                                cx="50%"
                                cy="50%"
                                outerRadius={80}
                                dataKey="value"
                                label={({ name, value, percent }) =>
                                    `${name}: ${(percent * 100).toFixed(0)}%`
                                }
                            >
                                {statusData.map((entry, index) => (
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
                        <BarChart data={serviceData} layout="horizontal">
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis type="number" />
                            <YAxis dataKey="name" type="category" width={80} />
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
                                Highest demand at {peakHour.hour} with{" "}
                                {peakHour.appointments} appointments
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
                                <MdWarning /> No-Show Analysis
                            </h4>
                            <p
                                style={{
                                    color: "#666",
                                    marginBottom: "0.5rem",
                                }}
                            >
                                {noShowRate}% no-show rate detected
                            </p>
                            <p style={{ color: "#666", fontSize: "0.9rem" }}>
                                {parseFloat(noShowRate) > 10
                                    ? "Consider implementing reminder systems"
                                    : "No-show rate is within acceptable range"}
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
                                <MdRocket /> Efficiency Tips
                            </h4>
                            <ul
                                style={{
                                    color: "#666",
                                    fontSize: "0.9rem",
                                    paddingLeft: "1.5rem",
                                }}
                            >
                                <li>Schedule buffer time during peak hours</li>
                                <li>Implement digital document verification</li>
                                <li>
                                    Consider extending hours for popular
                                    services
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Analytics;
