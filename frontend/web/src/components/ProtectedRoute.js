import React from "react";
import { useAuth } from "../contexts/AuthContext";
import AuthPage from "./AuthPage";

const ProtectedRoute = ({ children }) => {
    const { isAuthenticated, loading } = useAuth();

    if (loading) {
        return (
            <div
                style={{
                    display: "flex",
                    justifyContent: "center",
                    alignItems: "center",
                    height: "100vh",
                    background:
                        "linear-gradient(135deg, #8C1F28 0%, #4E6E63 100%)",
                    color: "white",
                    fontSize: "1.2rem",
                }}
            >
                Loading...
            </div>
        );
    }

    return isAuthenticated ? children : <AuthPage />;
};

export default ProtectedRoute;
