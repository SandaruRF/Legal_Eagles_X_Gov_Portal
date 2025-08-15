import React, { createContext, useState, useContext, useEffect } from "react";
import config from "../config/api";

const AuthContext = createContext();

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error("useAuth must be used within an AuthProvider");
    }
    return context;
};

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [token, setToken] = useState(localStorage.getItem("token"));

    // API base URL from config
    const { API_BASE_URL, endpoints } = config;

    useEffect(() => {
        // Check if user is logged in on app load
        if (token) {
            fetchCurrentUser();
        } else {
            setLoading(false);
        }
    }, [token]);

    const fetchCurrentUser = async () => {
        try {
            const response = await fetch(`${API_BASE_URL}${endpoints.me}`, {
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });

            if (response.ok) {
                const userData = await response.json();
                setUser(userData);
            } else {
                // Token is invalid
                localStorage.removeItem("token");
                setToken(null);
                setUser(null);
            }
        } catch (error) {
            console.error("Failed to fetch user:", error);
            localStorage.removeItem("token");
            setToken(null);
            setUser(null);
        } finally {
            setLoading(false);
        }
    };

    const login = async (email, password) => {
        try {
            const formData = new FormData();
            formData.append("username", email);
            formData.append("password", password);

            const response = await fetch(`${API_BASE_URL}${endpoints.login}`, {
                method: "POST",
                body: formData,
            });

            const data = await response.json();

            if (response.ok) {
                const { access_token } = data;
                localStorage.setItem("token", access_token);
                setToken(access_token);

                // Fetch user data after successful login
                const userResponse = await fetch(
                    `${API_BASE_URL}${endpoints.me}`,
                    {
                        headers: {
                            Authorization: `Bearer ${access_token}`,
                            "Content-Type": "application/json",
                        },
                    }
                );

                if (userResponse.ok) {
                    const userData = await userResponse.json();
                    setUser(userData);
                    return { success: true, user: userData };
                } else {
                    // Login was successful but failed to fetch user data
                    // Still return success since we have the token
                    console.warn(
                        "Failed to fetch user data, but login was successful"
                    );
                    setUser({ email: email }); // Set basic user info
                    return { success: true, user: { email: email } };
                }
            } else {
                return { success: false, error: data.detail || "Login failed" };
            }
        } catch (error) {
            console.error("Login error:", error);
            return {
                success: false,
                error: "Network error. Please try again.",
            };
        }
    };

    const register = async (adminData) => {
        try {
            const response = await fetch(
                `${API_BASE_URL}${endpoints.register}`,
                {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify(adminData),
                }
            );

            const data = await response.json();

            if (response.ok) {
                return { success: true, data };
            } else {
                return {
                    success: false,
                    error: data.detail || "Registration failed",
                };
            }
        } catch (error) {
            console.error("Registration error:", error);
            return {
                success: false,
                error: "Network error. Please try again.",
            };
        }
    };

    const logout = () => {
        localStorage.removeItem("token");
        setToken(null);
        setUser(null);
    };

    const value = {
        user,
        token,
        loading,
        login,
        register,
        logout,
        isAuthenticated: !!user,
    };

    return (
        <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
    );
};
