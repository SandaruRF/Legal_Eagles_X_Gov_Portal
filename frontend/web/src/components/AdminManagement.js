import React, { useState, useEffect } from "react";
import {
    MdAdd,
    MdEdit,
    MdDelete,
    MdSave,
    MdCancel,
    MdPerson,
    MdEmail,
    MdBusiness,
} from "react-icons/md";
import { useAuth } from "../contexts/AuthContext";
import config from "../config/api";
import departmentsData from "../data/departments.json";

const AdminManagement = ({ departmentId }) => {
    const [admins, setAdmins] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");
    const [editingAdmin, setEditingAdmin] = useState(null);
    const [showAddForm, setShowAddForm] = useState(false);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [adminToDelete, setAdminToDelete] = useState(null);
    const [department, setDepartment] = useState(null);
    const [newAdmin, setNewAdmin] = useState({
        full_name: "",
        email: "",
        password: "",
        role: "Officer",
        department_id: departmentId,
    });

    const { user, token } = useAuth();
    const { API_BASE_URL, endpoints } = config;

    useEffect(() => {
        fetchAdmins();
        fetchDepartment();
    }, [departmentId]);

    const fetchDepartment = async () => {
        try {
            const response = await fetch(
                `${API_BASE_URL}${endpoints.department_by_id}${departmentId}`,
                {
                    headers: config.getAuthHeaders(token),
                }
            );

            if (response.ok) {
                const departmentData = await response.json();
                setDepartment(departmentData);
            }
        } catch (error) {
            console.error("Error fetching department:", error);
        }
    };

    const fetchAdmins = async () => {
        try {
            setLoading(true);
            setError("");

            // Fetch admins by department from backend API
            const response = await fetch(
                `${API_BASE_URL}${endpoints.adminsList}?department_id=${departmentId}`,
                {
                    headers: config.getAuthHeaders(token),
                }
            );

            if (!response.ok) {
                throw new Error(`Failed to fetch admins: ${response.status}`);
            }

            const data = await response.json();
            setAdmins(data);
        } catch (error) {
            console.error("Error fetching admins:", error);
            setError("Failed to fetch admins. Please try again.");
        } finally {
            setLoading(false);
        }
    };

    const handleAddAdmin = async () => {
        try {
            setError("");
            setSuccess("");

            // Validation
            if (!newAdmin.full_name || !newAdmin.email || !newAdmin.password) {
                setError("Please fill in all required fields");
                return;
            }

            // Email validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(newAdmin.email)) {
                setError("Please enter a valid email address");
                return;
            }

            // API call to register new admin
            const response = await fetch(
                `${API_BASE_URL}${endpoints.adminCreate}`,
                {
                    method: "POST",
                    headers: config.getAuthHeaders(token),
                    body: JSON.stringify(newAdmin),
                }
            );

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.detail || "Failed to add admin");
            }

            const newAdminData = await response.json();

            // Update local state
            setAdmins([...admins, newAdminData]);
            setNewAdmin({
                full_name: "",
                email: "",
                password: "",
                role: "Officer",
                department_id: departmentId,
            });
            setShowAddForm(false);
            setSuccess("Admin added successfully");
        } catch (error) {
            console.error("Error adding admin:", error);
            setError(error.message || "Failed to add admin");
        }
    };

    const handleEditAdmin = async (adminId, updatedData) => {
        try {
            setError("");
            setSuccess("");

            // Validation
            if (!updatedData.full_name || !updatedData.email) {
                setError("Name and email are required");
                return;
            }

            // Email validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(updatedData.email)) {
                setError("Please enter a valid email address");
                return;
            }

            // API call to update admin
            const response = await fetch(
                `${API_BASE_URL}${endpoints.adminUpdate}/${adminId}`,
                {
                    method: "PUT",
                    headers: config.getAuthHeaders(token),
                    body: JSON.stringify(updatedData),
                }
            );

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.detail || "Failed to update admin");
            }

            const updatedAdmin = await response.json();

            // Update local state
            setAdmins(
                admins.map((admin) =>
                    admin.admin_id === adminId ? updatedAdmin : admin
                )
            );
            setEditingAdmin(null);
            setSuccess("Admin updated successfully");
        } catch (error) {
            console.error("Error updating admin:", error);
            setError(error.message || "Failed to update admin");
        }
    };

    const handleDeleteAdmin = async (adminId) => {
        try {
            setError("");
            setSuccess("");

            // API call to delete admin
            const response = await fetch(
                `${API_BASE_URL}${endpoints.adminDelete}/${adminId}`,
                {
                    method: "DELETE",
                    headers: config.getAuthHeaders(token),
                }
            );

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.detail || "Failed to delete admin");
            }

            // Update local state
            setAdmins(admins.filter((admin) => admin.admin_id !== adminId));
            setSuccess("Admin deleted successfully");
            setShowDeleteModal(false);
            setAdminToDelete(null);
        } catch (error) {
            console.error("Error deleting admin:", error);
            setError(error.message || "Failed to delete admin");
            setShowDeleteModal(false);
            setAdminToDelete(null);
        }
    };

    const confirmDelete = (admin) => {
        setError("");
        setSuccess("");
        setAdminToDelete(admin);
        setShowDeleteModal(true);
    };

    const getDepartmentName = (deptId) => {
        if (department && department.department_id === deptId) {
            return department.name;
        }
        // Fallback to JSON data if API data not available yet
        const dept = departmentsData.find((d) => d.department_id === deptId);
        return dept ? dept.name : "Loading...";
    };

    if (user?.role !== "Head") {
        return (
            <div style={{ padding: "2rem", textAlign: "center" }}>
                <h3 style={{ color: "#8C1F28" }}>Access Denied</h3>
                <p>Only Head role can access admin management.</p>
            </div>
        );
    }

    return (
        <div style={{ padding: "2rem" }}>
            <div
                style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    marginBottom: "2rem",
                }}
            >
                <h2 style={{ color: "#4E6E63" }}>Admin Management</h2>
                <button
                    className="btn btn-primary"
                    onClick={() => {
                        setError("");
                        setSuccess("");
                        setShowAddForm(true);
                    }}
                    style={{
                        display: "flex",
                        alignItems: "center",
                        gap: "0.5rem",
                    }}
                >
                    <MdAdd /> Add New Admin
                </button>
            </div>

            {error && (
                <div
                    style={{
                        background: "#fff5f5",
                        border: "1px solid #fed7d7",
                        color: "#c53030",
                        padding: "1rem",
                        borderRadius: "8px",
                        marginBottom: "1rem",
                    }}
                >
                    {error}
                </div>
            )}

            {success && (
                <div
                    style={{
                        background: "#f0fff4",
                        border: "1px solid #9ae6b4",
                        color: "#2f855a",
                        padding: "1rem",
                        borderRadius: "8px",
                        marginBottom: "1rem",
                    }}
                >
                    {success}
                </div>
            )}

            {/* Add Admin Modal */}
            {showAddForm && (
                <div className="modal-overlay">
                    <div className="modal admin-modal">
                        <div className="modal-header">
                            <h3>Add New Admin</h3>
                            <button
                                className="modal-close-btn"
                                onClick={() => setShowAddForm(false)}
                            >
                                <MdCancel />
                            </button>
                        </div>
                        <div className="modal-body">
                            <div className="form-grid">
                                <div className="form-group">
                                    <label>
                                        <MdPerson
                                            style={{ marginRight: "0.5rem" }}
                                        />
                                        Full Name *
                                    </label>
                                    <input
                                        type="text"
                                        value={newAdmin.full_name}
                                        onChange={(e) =>
                                            setNewAdmin({
                                                ...newAdmin,
                                                full_name: e.target.value,
                                            })
                                        }
                                        className="form-input"
                                        placeholder="Enter full name"
                                    />
                                </div>

                                <div className="form-group">
                                    <label>
                                        <MdEmail
                                            style={{ marginRight: "0.5rem" }}
                                        />
                                        Email *
                                    </label>
                                    <input
                                        type="email"
                                        value={newAdmin.email}
                                        onChange={(e) =>
                                            setNewAdmin({
                                                ...newAdmin,
                                                email: e.target.value,
                                            })
                                        }
                                        className="form-input"
                                        placeholder="Enter email"
                                    />
                                </div>

                                <div className="form-group">
                                    <label>Password *</label>
                                    <input
                                        type="password"
                                        value={newAdmin.password}
                                        onChange={(e) =>
                                            setNewAdmin({
                                                ...newAdmin,
                                                password: e.target.value,
                                            })
                                        }
                                        className="form-input"
                                        placeholder="Enter password"
                                    />
                                </div>

                                <div className="form-group">
                                    <label>
                                        <MdBusiness
                                            style={{ marginRight: "0.5rem" }}
                                        />
                                        Role
                                    </label>
                                    <select
                                        value={newAdmin.role}
                                        onChange={(e) =>
                                            setNewAdmin({
                                                ...newAdmin,
                                                role: e.target.value,
                                            })
                                        }
                                        className="form-input"
                                    >
                                        <option value="Officer">Officer</option>
                                        <option value="Manager">Manager</option>
                                        <option value="Head">Head</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div className="modal-footer">
                            <button
                                className="btn btn-secondary"
                                onClick={() => setShowAddForm(false)}
                            >
                                <MdCancel style={{ marginRight: "0.5rem" }} />
                                Cancel
                            </button>
                            <button
                                className="btn btn-success"
                                onClick={handleAddAdmin}
                            >
                                <MdSave style={{ marginRight: "0.5rem" }} />
                                Save Admin
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Admins Table */}
            <div
                style={{
                    background: "white",
                    borderRadius: "8px",
                    boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                    overflow: "hidden",
                }}
            >
                {loading ? (
                    <div style={{ padding: "2rem", textAlign: "center" }}>
                        Loading admins...
                    </div>
                ) : (
                    <table
                        style={{ width: "100%", borderCollapse: "collapse" }}
                    >
                        <thead style={{ background: "#f8f9fa" }}>
                            <tr>
                                <th
                                    style={{
                                        padding: "1rem",
                                        textAlign: "left",
                                        borderBottom: "1px solid #dee2e6",
                                    }}
                                >
                                    Name
                                </th>
                                <th
                                    style={{
                                        padding: "1rem",
                                        textAlign: "left",
                                        borderBottom: "1px solid #dee2e6",
                                    }}
                                >
                                    Email
                                </th>
                                <th
                                    style={{
                                        padding: "1rem",
                                        textAlign: "left",
                                        borderBottom: "1px solid #dee2e6",
                                    }}
                                >
                                    Role
                                </th>
                                <th
                                    style={{
                                        padding: "1rem",
                                        textAlign: "left",
                                        borderBottom: "1px solid #dee2e6",
                                    }}
                                >
                                    Department
                                </th>
                                <th
                                    style={{
                                        padding: "1rem",
                                        textAlign: "center",
                                        borderBottom: "1px solid #dee2e6",
                                    }}
                                >
                                    Actions
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            {admins.map((admin) => (
                                <AdminRow
                                    key={admin.admin_id}
                                    admin={admin}
                                    isEditing={editingAdmin === admin.admin_id}
                                    onEdit={(updatedData) =>
                                        handleEditAdmin(
                                            admin.admin_id,
                                            updatedData
                                        )
                                    }
                                    onDelete={() => confirmDelete(admin)}
                                    onStartEdit={() =>
                                        setEditingAdmin(admin.admin_id)
                                    }
                                    onCancelEdit={() => setEditingAdmin(null)}
                                    getDepartmentName={getDepartmentName}
                                />
                            ))}
                        </tbody>
                    </table>
                )}
            </div>

            {/* Delete Confirmation Modal */}
            {showDeleteModal && (
                <div className="modal-overlay">
                    <div className="modal admin-modal">
                        <div className="modal-header">
                            <h3>Confirm Deletion</h3>
                            <button
                                className="modal-close-btn"
                                onClick={() => {
                                    setShowDeleteModal(false);
                                    setAdminToDelete(null);
                                }}
                            >
                                <MdCancel />
                            </button>
                        </div>
                        <div className="modal-body">
                            <div
                                style={{
                                    textAlign: "center",
                                    padding: "1rem 0",
                                }}
                            >
                                <div
                                    style={{
                                        fontSize: "3rem",
                                        color: "#dc3545",
                                        marginBottom: "1rem",
                                    }}
                                >
                                    <MdDelete />
                                </div>
                                <p
                                    style={{
                                        fontSize: "1.1rem",
                                        color: "#495057",
                                        marginBottom: "0.5rem",
                                    }}
                                >
                                    Are you sure you want to delete admin
                                </p>
                                <p
                                    style={{
                                        fontSize: "1.2rem",
                                        fontWeight: "bold",
                                        color: "#8C1F28",
                                        marginBottom: "1rem",
                                    }}
                                >
                                    "{adminToDelete?.full_name}"?
                                </p>
                                <p
                                    style={{
                                        fontSize: "0.9rem",
                                        color: "#6c757d",
                                        fontStyle: "italic",
                                    }}
                                >
                                    This action cannot be undone.
                                </p>
                            </div>
                        </div>
                        <div className="modal-footer">
                            <button
                                className="btn btn-secondary"
                                onClick={() => {
                                    setShowDeleteModal(false);
                                    setAdminToDelete(null);
                                }}
                            >
                                <MdCancel style={{ marginRight: "0.5rem" }} />
                                Cancel
                            </button>
                            <button
                                className="btn btn-danger"
                                onClick={() =>
                                    handleDeleteAdmin(adminToDelete.admin_id)
                                }
                            >
                                <MdDelete style={{ marginRight: "0.5rem" }} />
                                Delete Admin
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

// Individual admin row component
const AdminRow = ({
    admin,
    isEditing,
    onEdit,
    onDelete,
    onStartEdit,
    onCancelEdit,
    getDepartmentName,
}) => {
    const [editData, setEditData] = useState({
        full_name: admin.full_name,
        email: admin.email,
        role: admin.role,
    });

    const handleSave = () => {
        onEdit(editData);
    };

    if (isEditing) {
        return (
            <tr>
                <td
                    style={{
                        padding: "1rem",
                        borderBottom: "1px solid #dee2e6",
                    }}
                >
                    <input
                        type="text"
                        value={editData.full_name}
                        onChange={(e) =>
                            setEditData({
                                ...editData,
                                full_name: e.target.value,
                            })
                        }
                        style={{
                            width: "100%",
                            padding: "0.5rem",
                            border: "1px solid #ddd",
                            borderRadius: "4px",
                        }}
                    />
                </td>
                <td
                    style={{
                        padding: "1rem",
                        borderBottom: "1px solid #dee2e6",
                    }}
                >
                    <input
                        type="email"
                        value={editData.email}
                        onChange={(e) =>
                            setEditData({ ...editData, email: e.target.value })
                        }
                        style={{
                            width: "100%",
                            padding: "0.5rem",
                            border: "1px solid #ddd",
                            borderRadius: "4px",
                        }}
                    />
                </td>
                <td
                    style={{
                        padding: "1rem",
                        borderBottom: "1px solid #dee2e6",
                    }}
                >
                    <select
                        value={editData.role}
                        onChange={(e) =>
                            setEditData({ ...editData, role: e.target.value })
                        }
                        style={{
                            width: "100%",
                            padding: "0.5rem",
                            border: "1px solid #ddd",
                            borderRadius: "4px",
                        }}
                    >
                        <option value="Officer">Officer</option>
                        <option value="Manager">Manager</option>
                        <option value="Head">Head</option>
                    </select>
                </td>
                <td
                    style={{
                        padding: "1rem",
                        borderBottom: "1px solid #dee2e6",
                    }}
                >
                    {getDepartmentName(admin.department_id)}
                </td>
                <td
                    style={{
                        padding: "1rem",
                        borderBottom: "1px solid #dee2e6",
                        textAlign: "center",
                    }}
                >
                    <div
                        style={{
                            display: "flex",
                            gap: "0.5rem",
                            justifyContent: "center",
                        }}
                    >
                        <button
                            onClick={handleSave}
                            style={{
                                background: "#28a745",
                                color: "white",
                                border: "none",
                                padding: "0.5rem",
                                borderRadius: "4px",
                                cursor: "pointer",
                            }}
                        >
                            <MdSave />
                        </button>
                        <button
                            onClick={onCancelEdit}
                            style={{
                                background: "#6c757d",
                                color: "white",
                                border: "none",
                                padding: "0.5rem",
                                borderRadius: "4px",
                                cursor: "pointer",
                            }}
                        >
                            <MdCancel />
                        </button>
                    </div>
                </td>
            </tr>
        );
    }

    return (
        <tr>
            <td style={{ padding: "1rem", borderBottom: "1px solid #dee2e6" }}>
                {admin.full_name}
            </td>
            <td style={{ padding: "1rem", borderBottom: "1px solid #dee2e6" }}>
                {admin.email}
            </td>
            <td style={{ padding: "1rem", borderBottom: "1px solid #dee2e6" }}>
                <span
                    style={{
                        background:
                            admin.role === "Head"
                                ? "#8C1F28"
                                : admin.role === "Manager"
                                ? "#FEB600"
                                : "#4E6E63",
                        color: "white",
                        padding: "0.25rem 0.75rem",
                        borderRadius: "12px",
                        fontSize: "0.85rem",
                    }}
                >
                    {admin.role}
                </span>
            </td>
            <td style={{ padding: "1rem", borderBottom: "1px solid #dee2e6" }}>
                {getDepartmentName(admin.department_id)}
            </td>
            <td
                style={{
                    padding: "1rem",
                    borderBottom: "1px solid #dee2e6",
                    textAlign: "center",
                }}
            >
                <div
                    style={{
                        display: "flex",
                        gap: "0.5rem",
                        justifyContent: "center",
                    }}
                >
                    <button
                        onClick={onStartEdit}
                        style={{
                            background: "#FEB600",
                            color: "white",
                            border: "none",
                            padding: "0.5rem",
                            borderRadius: "4px",
                            cursor: "pointer",
                        }}
                    >
                        <MdEdit />
                    </button>
                    <button
                        onClick={onDelete}
                        style={{
                            background: "#dc3545",
                            color: "white",
                            border: "none",
                            padding: "0.5rem",
                            borderRadius: "4px",
                            cursor: "pointer",
                        }}
                    >
                        <MdDelete />
                    </button>
                </div>
            </td>
        </tr>
    );
};

export default AdminManagement;
