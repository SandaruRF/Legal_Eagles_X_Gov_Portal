import React, { useState, useEffect, useCallback } from "react";
import {
    MdDashboard,
    MdCalendarToday,
    MdAnalytics,
    MdFeedback,
    MdLogout,
    MdPeople,
    MdMenu,
    MdClose,
} from "react-icons/md";
import { useAuth } from "../contexts/AuthContext";
import config from "../config/api";
import Overview from "./Overview";
import Appointments from "./Appointments";
import Analytics from "./Analytics";
import Feedback from "./Feedback";
import AdminManagement from "./AdminManagement";
import KYCVerifications from "./KYCVerifications";
import govPortalLogo from "../images/gov-portal-logo.png";

const Dashboard = () => {
    const [activeTab, setActiveTab] = useState("overview");
    const [showLogoutModal, setShowLogoutModal] = useState(false);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
    const [department, setDepartment] = useState("Unknown Department");

    const { user, logout, token } = useAuth();
    const { API_BASE_URL, endpoints } = config;

    const currentUser = user;

    const fetchDepartment = useCallback(async () => {
        try {
            const response = await fetch(
                `${API_BASE_URL}${endpoints.department_by_id}${currentUser.department_id}`
            );
            const departmentData = await response.json();

            if (response.ok) {
                setDepartment(departmentData);
            }
        } catch (error) {
            console.error("Failed to fetch department:", error);
            logout();
        }
    }, [
        API_BASE_URL,
        endpoints.department_by_id,
        currentUser.department_id,
        logout,
    ]);

    // Get department name from departments data
    useEffect(() => {
        // Check if user is logged in on app load
        if (token) {
            fetchDepartment();
        }
    }, [token, fetchDepartment]);

    const handleLogout = () => {
        setShowLogoutModal(true);
    };

    const confirmLogout = () => {
        logout();
        setShowLogoutModal(false);
    };

    const cancelLogout = () => {
        setShowLogoutModal(false);
    };

    const toggleMobileMenu = () => {
        setIsMobileMenuOpen(!isMobileMenuOpen);
    };

    const handleNavClick = (tab) => {
        setActiveTab(tab);
        setIsMobileMenuOpen(false); // Close mobile menu when navigation item is clicked
    };

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
            case "admin-management":
                return (
                    <AdminManagement departmentId={currentUser.department_id} />
                );
            case "kyc verifications":
                return (
                    <KYCVerifications departmentId={currentUser.department_id} />
                );
            default:
                return <Overview departmentId={currentUser.department_id} />;
        }
    };

    return (
        <div className="dashboard">
            {/* Mobile Menu Toggle */}
            <button className="mobile-menu-toggle" onClick={toggleMobileMenu}>
                {isMobileMenuOpen ? <MdClose /> : <MdMenu />}
            </button>

            {/* Sidebar */}
            <div className={`sidebar ${isMobileMenuOpen ? "mobile-open" : ""}`}>
                <div className="sidebar-header">
                    <div style={{ textAlign: "center", marginBottom: "1rem" }}>
                        <img
                            src={govPortalLogo}
                            alt="Gov Portal Logo"
                            style={{
                                width: "90px",
                                height: "60px",
                                marginBottom: "0.5rem",
                            }}
                        />
                    </div>
                    <h1
                        style={{ textAlign: "center", marginBottom: "0.25rem" }}
                    >
                        Gov Portal
                    </h1>
                    <div
                        style={{
                            textAlign: "center",
                            fontSize: "0.9rem",
                            marginBottom: "0.5rem",
                            color: "#4E6E63",
                            fontWeight: "500",
                        }}
                    >
                        Admin Dashboard
                    </div>
                    <div className="department-name">
                        {department.name || department}
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
                        onClick={() => handleNavClick("overview")}
                    >
                        <MdDashboard style={{ marginRight: "0.5rem" }} />
                        Dashboard Overview
                    </button>
                    <button
                        className={`nav-item ${
                            activeTab === "appointments" ? "active" : ""
                        }`}
                        onClick={() => handleNavClick("appointments")}
                    >
                        <MdCalendarToday style={{ marginRight: "0.5rem" }} />
                        Appointments
                    </button>
                    <button
                        className={`nav-item ${
                            activeTab === "analytics" ? "active" : ""
                        }`}
                        onClick={() => handleNavClick("analytics")}
                    >
                        <MdAnalytics style={{ marginRight: "0.5rem" }} />
                        Analytics
                    </button>
                    <button
                        className={`nav-item ${
                            activeTab === "feedback" ? "active" : ""
                        }`}
                        onClick={() => handleNavClick("feedback")}
                    >
                        <MdFeedback style={{ marginRight: "0.5rem" }} />
                        Feedback
                    </button>
                    <button
                        className={`nav-item ${
                            activeTab === "kyc verifications" ? "active" : ""
                        }`}
                        onClick={() => handleNavClick("kyc verifications")}
                    >
                        <MdPeople style={{ marginRight: "0.5rem" }} />
                        KYC Verifications
                    </button>

                    {/* Admin Management - Only for Head role */}
                    {currentUser.role === "Head" && (
                        <button
                            className={`nav-item ${
                                activeTab === "admin-management" ? "active" : ""
                            }`}
                            onClick={() => handleNavClick("admin-management")}
                        >
                            <MdPeople style={{ marginRight: "0.5rem" }} />
                            Admin Management
                        </button>
                    )}

                    {/* Logout Button */}
                    <button
                        className="nav-item logout-btn"
                        onClick={handleLogout}
                        style={{
                            marginTop: "auto",
                            backgroundColor: "#dc3545",
                            borderColor: "#dc3545",
                        }}
                    >
                        <MdLogout style={{ marginRight: "0.5rem" }} />
                        Logout
                    </button>
                </nav>
            </div>

            {/* Main Content */}
            <div className="main-content">{renderContent()}</div>

            {/* Logout Confirmation Modal */}
            {showLogoutModal && (
                <div className="modal-overlay">
                    <div className="modal">
                        <div className="modal-header">
                            <h3>Confirm Logout</h3>
                        </div>
                        <div className="modal-body">
                            <p>
                                Are you sure you want to logout from the
                                Government Portal?
                            </p>
                            <p className="logout-warning">
                                You will need to login again to access the
                                system.
                            </p>
                        </div>
                        <div className="modal-footer">
                            <button
                                className="btn btn-secondary"
                                onClick={cancelLogout}
                            >
                                Cancel
                            </button>
                            <button
                                className="btn btn-danger"
                                onClick={confirmLogout}
                            >
                                <MdLogout style={{ marginRight: "0.5rem" }} />
                                Logout
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Dashboard;
