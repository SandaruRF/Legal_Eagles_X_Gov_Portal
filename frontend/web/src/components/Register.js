import React, { useState, useEffect } from "react";
import {
    MdEmail,
    MdLock,
    MdPerson,
    MdBusiness,
    MdVisibility,
    MdVisibilityOff,
} from "react-icons/md";
import { useAuth } from "../contexts/AuthContext";
import departmentsData from "../data/departments.json";
import "../styles/Auth.css";

const Register = ({ onSwitchToLogin }) => {
    const [formData, setFormData] = useState({
        full_name: "",
        email: "",
        password: "",
        confirmPassword: "",
        role: "Officer",
        department_id: "",
    });
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirmPassword, setShowConfirmPassword] = useState(false);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");
    const [loading, setLoading] = useState(false);

    const { register } = useAuth();

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData((prev) => ({
            ...prev,
            [name]: value,
        }));
        // Clear messages when user starts typing
        if (error) setError("");
        if (success) setSuccess("");
    };

    const validateForm = () => {
        if (!formData.full_name.trim()) {
            return "Full name is required";
        }
        if (!formData.email) {
            return "Email is required";
        }
        if (!formData.password) {
            return "Password is required";
        }
        if (formData.password.length < 8) {
            return "Password must be at least 8 characters long";
        }
        if (formData.password !== formData.confirmPassword) {
            return "Passwords do not match";
        }
        if (!formData.department_id) {
            return "Please select a department";
        }
        return null;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError("");
        setSuccess("");

        const validationError = validateForm();
        if (validationError) {
            setError(validationError);
            setLoading(false);
            return;
        }

        try {
            // Prepare data for API (exclude confirmPassword)
            const { confirmPassword, ...adminData } = formData;

            const result = await register(adminData);

            if (result.success) {
                setSuccess("Admin registered successfully! You can now login.");
                setFormData({
                    full_name: "",
                    email: "",
                    password: "",
                    confirmPassword: "",
                    role: "Officer",
                    department_id: "",
                });
                // Auto-switch to login after 2 seconds
                setTimeout(() => {
                    onSwitchToLogin();
                }, 2000);
            } else {
                setError(result.error);
            }
        } catch (error) {
            setError("An unexpected error occurred. Please try again.");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="auth-container">
            <div className="auth-card register-card">
                <div className="auth-header">
                    <h1>Government Portal</h1>
                    <h2>Register New Admin</h2>
                    <p>Create a new admin account for ministry access</p>
                </div>

                {error && <div className="error-message">{error}</div>}

                {success && <div className="success-message">{success}</div>}

                <form onSubmit={handleSubmit} className="auth-form">
                    <div className="form-group">
                        <label htmlFor="full_name">Full Name</label>
                        <div className="input-with-icon">
                            <MdPerson className="input-icon" />
                            <input
                                type="text"
                                id="full_name"
                                name="full_name"
                                value={formData.full_name}
                                onChange={handleChange}
                                placeholder="Enter full name"
                                required
                                disabled={loading}
                            />
                        </div>
                    </div>

                    <div className="form-group">
                        <label htmlFor="email">Official Email Address</label>
                        <div className="input-with-icon">
                            <MdEmail className="input-icon" />
                            <input
                                type="email"
                                id="email"
                                name="email"
                                value={formData.email}
                                onChange={handleChange}
                                placeholder="Enter official email"
                                required
                                disabled={loading}
                            />
                        </div>
                    </div>

                    <div className="form-group">
                        <label htmlFor="department_id">Department</label>
                        <div className="input-with-icon">
                            <MdBusiness className="input-icon" />
                            <select
                                id="department_id"
                                name="department_id"
                                value={formData.department_id}
                                onChange={handleChange}
                                required
                                disabled={loading}
                            >
                                <option value="">Select Department</option>
                                {departmentsData.map((dept) => (
                                    <option
                                        key={dept.department_id}
                                        value={dept.department_id}
                                    >
                                        {dept.name}
                                    </option>
                                ))}
                            </select>
                        </div>
                    </div>

                    <div className="form-group">
                        <label htmlFor="role">Role</label>
                        <div className="input-with-icon">
                            <MdBusiness className="input-icon" />
                            <select
                                id="role"
                                name="role"
                                value={formData.role}
                                onChange={handleChange}
                                required
                                disabled={loading}
                            >
                                <option value="Officer">Officer</option>
                                <option value="Manager">Manager</option>
                                <option value="Director">Director</option>
                            </select>
                        </div>
                    </div>

                    <div className="form-group">
                        <label htmlFor="password">Password</label>
                        <div className="input-with-icon">
                            <MdLock className="input-icon" />
                            <input
                                type={showPassword ? "text" : "password"}
                                id="password"
                                name="password"
                                value={formData.password}
                                onChange={handleChange}
                                placeholder="Enter password (min 8 characters)"
                                required
                                minLength={8}
                                disabled={loading}
                            />
                            <button
                                type="button"
                                className="password-toggle"
                                onClick={() => setShowPassword(!showPassword)}
                                disabled={loading}
                            >
                                {showPassword ? (
                                    <MdVisibilityOff />
                                ) : (
                                    <MdVisibility />
                                )}
                            </button>
                        </div>
                    </div>

                    <div className="form-group">
                        <label htmlFor="confirmPassword">
                            Confirm Password
                        </label>
                        <div className="input-with-icon">
                            <MdLock className="input-icon" />
                            <input
                                type={showConfirmPassword ? "text" : "password"}
                                id="confirmPassword"
                                name="confirmPassword"
                                value={formData.confirmPassword}
                                onChange={handleChange}
                                placeholder="Confirm your password"
                                required
                                disabled={loading}
                            />
                            <button
                                type="button"
                                className="password-toggle"
                                onClick={() =>
                                    setShowConfirmPassword(!showConfirmPassword)
                                }
                                disabled={loading}
                            >
                                {showConfirmPassword ? (
                                    <MdVisibilityOff />
                                ) : (
                                    <MdVisibility />
                                )}
                            </button>
                        </div>
                    </div>

                    <button
                        type="submit"
                        className="auth-button"
                        disabled={loading}
                    >
                        {loading ? "Registering..." : "Register Admin"}
                    </button>
                </form>

                <div className="auth-footer">
                    <p>
                        Already have an account?{" "}
                        <button
                            type="button"
                            className="link-button"
                            onClick={onSwitchToLogin}
                            disabled={loading}
                        >
                            Sign in here
                        </button>
                    </p>
                </div>
            </div>
        </div>
    );
};

export default Register;
