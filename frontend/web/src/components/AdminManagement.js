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
import departmentsData from "../data/departments.json";

const AdminManagement = ({ departmentId }) => {
    const [admins, setAdmins] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");
    const [editingAdmin, setEditingAdmin] = useState(null);
    const [showAddForm, setShowAddForm] = useState(false);
    const [newAdmin, setNewAdmin] = useState({
        full_name: "",
        email: "",
        password: "",
        role: "Officer",
        department_id: departmentId,
    });

    const { user, token } = useAuth();

    useEffect(() => {
        fetchAdmins();
    }, [departmentId]);

    const fetchAdmins = async () => {
        try {
            setLoading(true);
            // Fetch admins by department from backend API
            const response = await fetch(`/api/admins?department_id=${departmentId}`, {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (!response.ok) throw new Error("Failed to fetch admins");
            const data = await response.json();
            setAdmins(data);
            setLoading(false);
            setTimeout(() => {
                const departmentAdmins = mockAdmins.filter(
                    (admin) => admin.department_id === departmentId
                );
                setAdmins(departmentAdmins);
                setLoading(false);
            }, 500);
        } catch (error) {
            setError("Failed to fetch admins");
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

            // TODO: Replace with actual API call to your existing register endpoint
            // const response = await fetch('/api/admins/register', {
            //     method: 'POST',
            //     headers: {
            //         'Content-Type': 'application/json',
            //         'Authorization': `Bearer ${token}`
            //     },
            //     body: JSON.stringify(newAdmin)
            // });

            // Mock implementation
            const newAdminWithId = {
                ...newAdmin,
                admin_id: `admin_${Date.now()}`,
            };

            setAdmins([...admins, newAdminWithId]);
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
            setError("Failed to add admin");
        }
    };

    const handleEditAdmin = async (adminId, updatedData) => {
        try {
            setError("");
            setSuccess("");

            // TODO: Replace with actual API call
            // const response = await fetch(`/api/admins/${adminId}`, {
            //     method: 'PUT',
            //     headers: {
            //         'Content-Type': 'application/json',
            //         'Authorization': `Bearer ${token}`
            //     },
            //     body: JSON.stringify(updatedData)
            // });

            // Mock implementation
            setAdmins(
                admins.map((admin) =>
                    admin.admin_id === adminId
                        ? { ...admin, ...updatedData }
                        : admin
                )
            );
            setEditingAdmin(null);
            setSuccess("Admin updated successfully");
        } catch (error) {
            setError("Failed to update admin");
        }
    };

    const handleDeleteAdmin = async (adminId) => {
        if (!window.confirm("Are you sure you want to delete this admin?")) {
            return;
        }

        try {
            setError("");
            setSuccess("");

            // TODO: Replace with actual API call
            // const response = await fetch(`/api/admins/${adminId}`, {
            //     method: 'DELETE',
            //     headers: { 'Authorization': `Bearer ${token}` }
            // });

            // Mock implementation
            setAdmins(admins.filter((admin) => admin.admin_id !== adminId));
            setSuccess("Admin deleted successfully");
        } catch (error) {
            setError("Failed to delete admin");
        }
    };

    const getDepartmentName = (deptId) => {
        const dept = departmentsData.find((d) => d.department_id === deptId);
        return dept ? dept.name : "Unknown Department";
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
                    onClick={() => setShowAddForm(true)}
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
                                    onDelete={() =>
                                        handleDeleteAdmin(admin.admin_id)
                                    }
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
