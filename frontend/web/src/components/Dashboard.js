import React, { useState } from "react";
import Overview from "./Overview";
import Appointments from "./Appointments";
import Analytics from "./Analytics";
import Feedback from "./Feedback";
import currentUserData from "../data/currentUser.json";

const Dashboard = () => {
    const [activeTab, setActiveTab] = useState("overview");
    const currentUser = currentUserData[0]; // For demo purposes, using first user

    const renderContent = () => {
        switch (activeTab) {
            case "overview":
                return <Overview departmentId={currentUser.department_id} />;
            case "appointments":
                return (
                    <Appointments departmentId={currentUser.department_id} />
                );
            case "analytics":
                return <Analytics departmentId={currentUser.department_id} />;
            case "feedback":
                return <Feedback departmentId={currentUser.department_id} />;
            default:
                return <Overview departmentId={currentUser.department_id} />;
        }
    };

    return (
        <div className="dashboard">
            {/* Sidebar */}
            <div className="sidebar">
                <div className="sidebar-header">
                    <h1>Gov Portal</h1>
                    <div className="department-name">
                        {currentUser.department_name}
                    </div>
                    <div
                        style={{
                            fontSize: "0.8rem",
                            marginTop: "0.5rem",
                            opacity: 0.7,
                        }}
                    >
                        {currentUser.full_name}
                    </div>
                </div>
                <nav className="sidebar-nav">
                    <button
                        className={`nav-item ${
                            activeTab === "overview" ? "active" : ""
                        }`}
                        onClick={() => setActiveTab("overview")}
                    >
                        📊 Dashboard Overview
                    </button>
                    <button
                        className={`nav-item ${
                            activeTab === "appointments" ? "active" : ""
                        }`}
                        onClick={() => setActiveTab("appointments")}
                    >
                        📅 Appointments
                    </button>
                    <button
                        className={`nav-item ${
                            activeTab === "analytics" ? "active" : ""
                        }`}
                        onClick={() => setActiveTab("analytics")}
                    >
                        📈 Analytics
                    </button>
                    <button
                        className={`nav-item ${
                            activeTab === "feedback" ? "active" : ""
                        }`}
                        onClick={() => setActiveTab("feedback")}
                    >
                        💬 Feedback
                    </button>
                </nav>
            </div>

            {/* Main Content */}
            <div className="main-content">{renderContent()}</div>
        </div>
    );
};

export default Dashboard;
