// API configuration for the frontend
const config = {
    // Backend API base URL
    API_BASE_URL: "http://localhost:8000",

    // API endpoints
    endpoints: {
        // Admin authentication
        login: "/api/admins/login",
        register: "/api/admins/register",
        me: "/api/admins/me",

        // Admin management (for Head role only)
        adminsList: "/api/admins", // GET - list admins by department
        adminCreate: "/api/admins/register", // POST - create new admin (reuse existing endpoint)
        adminUpdate: "/api/admins", // PUT - update admin by ID
        adminDelete: "/api/admins", // DELETE - delete admin by ID

        // Appointment management (all admin roles)
        appointmentsList: "/api/appointments", // GET - list appointments by department
        appointmentById: "/api/appointments", // GET - get appointment by ID
        appointmentUpdate: "/api/appointments", // PUT - update appointment by ID
        appointmentDocuments: "/api/appointments", // GET - get appointment documents by appointment ID
        // TODO: Add message endpoint when messaging feature is integrated from separate branch
        // appointmentMessages: "/api/appointments/{id}/messages", // POST - send message for appointment

        // Other endpoints can be added here as needed
        appointments: "/api/appointments",
        analytics: "/api/analytics",
        feedback: "/api/feedback",

        // Department endpoints
        department_by_id: "/api/departments/",
    },

    // Request timeout in milliseconds
    timeout: 10000,

    // Default headers
    getAuthHeaders: (token) => ({
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
    }),
};

export default config;
