import React, { useState, useEffect } from "react";
import { MdRefresh } from "react-icons/md";
import {
    BarChart,
    Bar,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    ResponsiveContainer,
} from "recharts";
import config from "../config/api";

const Feedback = ({ departmentId }) => {
    const [feedbackData, setFeedbackData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [serviceRatings, setServiceRatings] = useState(null);

    const { API_BASE_URL } = config;

    // Fetch feedback data from backend
    useEffect(() => {
        fetchFeedbackData();
    }, [departmentId]);

    const fetchFeedbackData = async () => {
        try {
            setLoading(true);
            setError(null);

            const token = localStorage.getItem("token");
            if (!token) {
                throw new Error("No authentication token found");
            }

            // Build basic query parameters
            const params = new URLSearchParams();
            params.append("page", 1);
            params.append("page_size", 50);

            // Fetch feedback list and stats first
            const [feedbackResponse, statsResponse] = await Promise.all([
                fetch(`${API_BASE_URL}/api/admin/feedback?${params}`, {
                    method: "GET",
                    headers: {
                        "Content-Type": "application/json",
                        Authorization: `Bearer ${token}`,
                    },
                }),
                fetch(`${API_BASE_URL}/api/admin/feedback/stats`, {
                    method: "GET",
                    headers: {
                        "Content-Type": "application/json",
                        Authorization: `Bearer ${token}`,
                    },
                }),
            ]);

            if (!feedbackResponse.ok || !statsResponse.ok) {
                throw new Error(
                    `HTTP error! status: ${feedbackResponse.status}`
                );
            }

            const feedbackData = await feedbackResponse.json();
            const statsData = await statsResponse.json();

            // Combine the data
            setFeedbackData({
                ...feedbackData,
                ...statsData,
            });

            // Try to fetch service ratings separately (optional)
            try {
                const serviceRatingsResponse = await fetch(
                    `${API_BASE_URL}/api/admin/feedback/rating-by-service`,
                    {
                        method: "GET",
                        headers: {
                            "Content-Type": "application/json",
                            Authorization: `Bearer ${token}`,
                        },
                    }
                );

                if (serviceRatingsResponse.ok) {
                    const serviceRatingsData =
                        await serviceRatingsResponse.json();
                    setServiceRatings(serviceRatingsData);
                } else {
                    console.warn(
                        "Service ratings not available:",
                        serviceRatingsResponse.status
                    );
                    setServiceRatings({ service_ratings: [] });
                }
            } catch (serviceError) {
                console.warn("Failed to fetch service ratings:", serviceError);
                setServiceRatings({ service_ratings: [] });
            }
        } catch (err) {
            console.error("Error fetching feedback data:", err);
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    // Loading state
    if (loading) {
        return (
            <div className="content-header">
                <h2>Citizen Feedback</h2>
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
                        Loading feedback data...
                    </p>
                </div>
            </div>
        );
    }

    // Error state
    if (error) {
        return (
            <div className="content-header">
                <h2>Citizen Feedback</h2>
                <div className="error-container">
                    <p className="error-message">
                        Error loading feedback: {error}
                    </p>
                    <button
                        onClick={fetchFeedbackData}
                        className="retry-button"
                    >
                        Retry
                    </button>
                </div>
            </div>
        );
    }

    // No data state
    if (!feedbackData) {
        return (
            <div className="content-header">
                <h2>Citizen Feedback</h2>
                <p>No feedback data available.</p>
            </div>
        );
    }

    // Extract data from API responses
    const {
        feedback,
        total,
        average_rating,
        rating_distribution,
        satisfaction_rate,
    } = feedbackData;
    const recentFeedback = feedback ? feedback.slice(0, 10) : [];

    // Prepare chart data
    const chartData = Object.entries(rating_distribution || {}).map(
        ([rating, count]) => ({
            rating: `${rating} Stars`,
            count,
            percentage: total > 0 ? ((count / total) * 100).toFixed(1) : 0,
        })
    );

    const getRatingStarsColored = (rating) => {
        const stars = [];
        const filledColor = getRatingColor(rating);
        const emptyColor = "#ddd";

        for (let i = 1; i <= 5; i++) {
            stars.push(
                <span
                    key={i}
                    style={{
                        color: i <= rating ? filledColor : emptyColor,
                        fontSize: "inherit",
                    }}
                >
                    {i <= rating ? "★" : "☆"}
                </span>
            );
        }
        return <span>{stars}</span>;
    };

    const getRatingColor = (rating) => {
        if (rating >= 4.5) return "#4caf50"; // Green for excellent
        if (rating >= 4) return "#8bc34a"; // Light green for very good
        if (rating >= 3) return "#FEB600"; // Yellow for good
        if (rating >= 2) return "#ff9800"; // Orange for fair
        return "#8C1F28"; // Red for poor
    };

    return (
        <div>
            <div className="content-header">
                <h2>Citizen Feedback</h2>
                <p className="content-subtitle">
                    Monitor citizen satisfaction and service quality
                </p>
            </div>

            {/* Summary Stats */}
            <div className="stats-grid">
                <div className="stat-card">
                    <h3>Total Reviews</h3>
                    <div className="stat-value" style={{ color: "#8C1F28" }}>
                        {total || 0}
                    </div>
                    <p className="stat-description">
                        All time feedback received
                    </p>
                </div>

                <div className="stat-card">
                    <h3>Average Rating</h3>
                    <div className="stat-value" style={{ color: "#FEB600" }}>
                        {average_rating ? average_rating.toFixed(1) : "0.0"}/5.0
                    </div>
                    <p className="stat-description">
                        {getRatingStarsColored(Math.round(average_rating || 0))}
                    </p>
                </div>

                <div className="stat-card">
                    <h3>Satisfaction Rate</h3>
                    <div className="stat-value" style={{ color: "#28a745" }}>
                        {satisfaction_rate
                            ? satisfaction_rate.toFixed(1)
                            : "0.0"}
                        %
                    </div>
                    <p className="stat-description">4+ star ratings</p>
                </div>

                <div className="stat-card">
                    <h3>Latest Review</h3>
                    <div className="stat-value" style={{ fontSize: "1.5rem" }}>
                        {recentFeedback.length > 0
                            ? getRatingStarsColored(recentFeedback[0].rating)
                            : "N/A"}
                    </div>
                    <p className="stat-description">
                        {recentFeedback.length > 0
                            ? new Date(
                                  recentFeedback[0].submitted_at
                              ).toLocaleDateString()
                            : "No reviews yet"}
                    </p>
                </div>
            </div>

            {/* Charts Section */}
            <div className="charts-section">
                {/* Rating Distribution Chart */}
                <div className="chart-card">
                    <h3>Rating Distribution</h3>
                    <ResponsiveContainer width="100%" height={300}>
                        <BarChart data={chartData}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="rating" />
                            <YAxis />
                            <Tooltip
                                formatter={(value, name) => [
                                    value,
                                    name === "count" ? "Reviews" : name,
                                ]}
                            />
                            <Bar dataKey="count" fill="#4E6E63" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>

                {/* Rating Breakdown */}
                <div className="chart-card">
                    <h3>Detailed Breakdown</h3>
                    <div style={{ padding: "1rem 0" }}>
                        {[5, 4, 3, 2, 1].map((rating) => {
                            const count = rating_distribution
                                ? rating_distribution[rating] || 0
                                : 0;
                            const percentage =
                                total > 0 ? (count / total) * 100 : 0;

                            return (
                                <div
                                    key={rating}
                                    className="rating-distribution"
                                >
                                    <span style={{ minWidth: "60px" }}>
                                        {rating} {getRatingStarsColored(rating)}
                                    </span>
                                    <div
                                        className={`rating-bar rating-${rating}`}
                                    >
                                        <div
                                            className="rating-fill"
                                            style={{ width: `${percentage}%` }}
                                        ></div>
                                    </div>
                                    <span
                                        style={{
                                            minWidth: "40px",
                                            textAlign: "right",
                                        }}
                                    >
                                        {count}
                                    </span>
                                </div>
                            );
                        })}
                    </div>
                </div>
            </div>

            {/* Service Ratings Section */}
            {serviceRatings &&
                serviceRatings.service_ratings &&
                serviceRatings.service_ratings.length > 0 && (
                    <div
                        className="service-ratings-section"
                        style={{ marginBottom: "2rem" }}
                    >
                        <h3>Ratings by Service Type</h3>
                        <div
                            className="service-ratings-grid"
                            style={{
                                display: "grid",
                                gridTemplateColumns:
                                    "repeat(auto-fit, minmax(300px, 1fr))",
                                gap: "1rem",
                                marginTop: "1rem",
                            }}
                        >
                            {serviceRatings.service_ratings.map(
                                (service, index) => (
                                    <div
                                        key={index}
                                        className="service-rating-card"
                                        style={{
                                            padding: "1rem",
                                            backgroundColor: "#f8f9fa",
                                            borderRadius: "8px",
                                            border: "1px solid #e9ecef",
                                        }}
                                    >
                                        <div
                                            style={{
                                                display: "flex",
                                                justifyContent: "space-between",
                                                alignItems: "start",
                                                marginBottom: "0.5rem",
                                            }}
                                        >
                                            <h4
                                                style={{
                                                    margin: "0",
                                                    fontSize: "1rem",
                                                    fontWeight: "600",
                                                }}
                                            >
                                                {service.service_name}
                                            </h4>
                                            <div style={{ textAlign: "right" }}>
                                                <div
                                                    style={{
                                                        fontSize: "1.2rem",
                                                        fontWeight: "bold",
                                                        color: getRatingColor(
                                                            service.average_rating
                                                        ),
                                                    }}
                                                >
                                                    {service.average_rating.toFixed(
                                                        1
                                                    )}
                                                    /5.0
                                                </div>
                                                <div>
                                                    {getRatingStarsColored(
                                                        Math.round(
                                                            service.average_rating
                                                        )
                                                    )}
                                                </div>
                                            </div>
                                        </div>

                                        <div
                                            style={{
                                                display: "flex",
                                                justifyContent: "space-between",
                                                fontSize: "0.9rem",
                                                color: "#666",
                                            }}
                                        >
                                            <span>
                                                {service.total_feedback} reviews
                                            </span>
                                            <span>
                                                {service.satisfaction_rate}%
                                                satisfaction
                                            </span>
                                        </div>

                                        <div style={{ marginTop: "0.5rem" }}>
                                            <div
                                                style={{
                                                    display: "flex",
                                                    gap: "0.25rem",
                                                    alignItems: "center",
                                                }}
                                            >
                                                {[5, 4, 3, 2, 1].map(
                                                    (rating) => {
                                                        const count =
                                                            service
                                                                .rating_distribution[
                                                                rating
                                                            ] || 0;
                                                        const percentage =
                                                            service.total_feedback >
                                                            0
                                                                ? (count /
                                                                      service.total_feedback) *
                                                                  100
                                                                : 0;
                                                        return (
                                                            <div
                                                                key={rating}
                                                                style={{
                                                                    flex: 1,
                                                                    textAlign:
                                                                        "center",
                                                                    fontSize:
                                                                        "0.8rem",
                                                                }}
                                                            >
                                                                <div
                                                                    style={{
                                                                        height: "20px",
                                                                        backgroundColor:
                                                                            getRatingColor(
                                                                                rating
                                                                            ),
                                                                        opacity:
                                                                            percentage >
                                                                            0
                                                                                ? 0.8
                                                                                : 0.2,
                                                                        borderRadius:
                                                                            "2px",
                                                                        marginBottom:
                                                                            "2px",
                                                                    }}
                                                                ></div>
                                                                <div>
                                                                    {rating}★
                                                                </div>
                                                                <div
                                                                    style={{
                                                                        fontSize:
                                                                            "0.7rem",
                                                                        color: "#999",
                                                                    }}
                                                                >
                                                                    {count}
                                                                </div>
                                                            </div>
                                                        );
                                                    }
                                                )}
                                            </div>
                                        </div>
                                    </div>
                                )
                            )}
                        </div>
                    </div>
                )}

            {/* Recent Feedback */}
            <div className="feedback-section">
                <h3>Recent Feedback Comments</h3>
                <div style={{ maxHeight: "500px", overflowY: "auto" }}>
                    {recentFeedback.length > 0 ? (
                        recentFeedback.map((feedback) => (
                            <div
                                key={feedback.feedback_id}
                                style={{
                                    padding: "1.5rem",
                                    borderBottom: "1px solid #e9ecef",
                                    background:
                                        feedback.rating >= 4
                                            ? "#f8fff8"
                                            : feedback.rating >= 3
                                            ? "#fffdf8"
                                            : "#fff8f8",
                                }}
                            >
                                <div
                                    style={{
                                        display: "flex",
                                        justifyContent: "space-between",
                                        alignItems: "start",
                                        marginBottom: "0.5rem",
                                    }}
                                >
                                    <div>
                                        <div
                                            style={{
                                                fontWeight: "500",
                                                marginBottom: "0.25rem",
                                            }}
                                        >
                                            {feedback.citizen_name}
                                        </div>
                                        <div
                                            style={{
                                                fontSize: "0.9rem",
                                                color: "#666",
                                            }}
                                        >
                                            {feedback.service_name}
                                        </div>
                                    </div>
                                    <div style={{ textAlign: "right" }}>
                                        <div
                                            style={{
                                                fontSize: "1.1rem",
                                                marginBottom: "0.25rem",
                                            }}
                                        >
                                            {getRatingStarsColored(
                                                feedback.rating
                                            )}
                                        </div>
                                        <div
                                            style={{
                                                fontSize: "0.8rem",
                                                color: "#999",
                                            }}
                                        >
                                            {new Date(
                                                feedback.submitted_at
                                            ).toLocaleDateString()}
                                        </div>
                                    </div>
                                </div>

                                {feedback.comment && (
                                    <div
                                        style={{
                                            fontSize: "0.95rem",
                                            lineHeight: "1.5",
                                            color: "#333",
                                            fontStyle: "italic",
                                            padding: "0.5rem",
                                            background:
                                                "rgba(255, 255, 255, 0.7)",
                                            borderRadius: "4px",
                                            marginTop: "0.5rem",
                                        }}
                                    >
                                        "{feedback.comment}"
                                    </div>
                                )}
                            </div>
                        ))
                    ) : (
                        <div className="empty-state">
                            <h4>No feedback received yet</h4>
                            <p>
                                Feedback will appear here once citizens start
                                rating your services.
                            </p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

export default Feedback;
