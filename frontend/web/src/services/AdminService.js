import config from "../config/api";

class AdminService {
    // Get all admins for a specific department (Head role only)
    static async getAdminsByDepartment(departmentId, token) {
        try {
            const response = await fetch(
                `${config.API_BASE_URL}${config.endpoints.adminsList}?department_id=${departmentId}`,
                {
                    method: "GET",
                    headers: config.getAuthHeaders(token),
                }
            );

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            return await response.json();
        } catch (error) {
            console.error("Error fetching admins:", error);
            throw error;
        }
    }

    // Create a new admin (Head role only)
    static async createAdmin(adminData, token) {
        try {
            const response = await fetch(
                `${config.API_BASE_URL}${config.endpoints.adminCreate}`,
                {
                    method: "POST",
                    headers: config.getAuthHeaders(token),
                    body: JSON.stringify(adminData),
                }
            );

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(
                    errorData.detail || `HTTP error! status: ${response.status}`
                );
            }

            return await response.json();
        } catch (error) {
            console.error("Error creating admin:", error);
            throw error;
        }
    }

    // Update an existing admin (Head role only)
    static async updateAdmin(adminId, adminData, token) {
        try {
            const response = await fetch(
                `${config.API_BASE_URL}${config.endpoints.adminUpdate}/${adminId}`,
                {
                    method: "PUT",
                    headers: config.getAuthHeaders(token),
                    body: JSON.stringify(adminData),
                }
            );

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(
                    errorData.detail || `HTTP error! status: ${response.status}`
                );
            }

            return await response.json();
        } catch (error) {
            console.error("Error updating admin:", error);
            throw error;
        }
    }

    // Delete an admin (Head role only)
    static async deleteAdmin(adminId, token) {
        try {
            const response = await fetch(
                `${config.API_BASE_URL}${config.endpoints.adminDelete}/${adminId}`,
                {
                    method: "DELETE",
                    headers: config.getAuthHeaders(token),
                }
            );

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(
                    errorData.detail || `HTTP error! status: ${response.status}`
                );
            }

            return { success: true };
        } catch (error) {
            console.error("Error deleting admin:", error);
            throw error;
        }
    }
}

export default AdminService;
