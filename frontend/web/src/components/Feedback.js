import React from "react";
import {
    BarChart,
    Bar,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    ResponsiveContainer,
} from "recharts";
import feedbackData from "../data/feedback.json";

const Feedback = ({ departmentId }) => {
    // Filter feedback for current department
    const departmentFeedback = feedbackData.filter(
        (fb) => fb.department_id === departmentId
    );

    // Calculate overall stats
    const totalFeedback = departmentFeedback.length;
    const averageRating =
        totalFeedback > 0
            ? (
                  departmentFeedback.reduce((sum, fb) => sum + fb.rating, 0) /
                  totalFeedback
              ).toFixed(1)
            : 0;

    // Calculate rating distribution
    const ratingDistribution = {
        5: departmentFeedback.filter((fb) => fb.rating === 5).length,
        4: departmentFeedback.filter((fb) => fb.rating === 4).length,
        3: departmentFeedback.filter((fb) => fb.rating === 3).length,
        2: departmentFeedback.filter((fb) => fb.rating === 2).length,
        1: departmentFeedback.filter((fb) => fb.rating === 1).length,
    };

    // Prepare chart data
    const chartData = Object.entries(ratingDistribution).map(
        ([rating, count]) => ({
            rating: `${rating} Stars`,
            count,
            percentage:
                totalFeedback > 0
                    ? ((count / totalFeedback) * 100).toFixed(1)
                    : 0,
        })
    );

    // Calculate satisfaction rate (4-5 stars)
    const satisfactionRate =
        totalFeedback > 0
            ? (
                  ((ratingDistribution[4] + ratingDistribution[5]) /
                      totalFeedback) *
                  100
              ).toFixed(1)
            : 0;

    // Get recent feedback
    const recentFeedback = departmentFeedback
        .sort((a, b) => new Date(b.submitted_at) - new Date(a.submitted_at))
        .slice(0, 10);

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
                        {totalFeedback}
                    </div>
                    <p className="stat-description">
                        All time feedback received
                    </p>
                </div>

                <div className="stat-card">
                    <h3>Average Rating</h3>
                    <div className="stat-value" style={{ color: "#FEB600" }}>
                        {averageRating}/5.0
                    </div>
                    <p className="stat-description">
                        {getRatingStarsColored(Math.round(averageRating))}
                    </p>
                </div>

                <div className="stat-card">
                    <h3>Satisfaction Rate</h3>
                    <div className="stat-value" style={{ color: "#28a745" }}>
                        {satisfactionRate}%
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
                            const count = ratingDistribution[rating];
                            const percentage =
                                totalFeedback > 0
                                    ? (count / totalFeedback) * 100
                                    : 0;

                            return (
                                <div
                                    key={rating}
                                    className="rating-distribution"
                                >
                                    <span style={{ minWidth: "60px" }}>
                                        {rating} {getRatingStarsColored(1)}
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
