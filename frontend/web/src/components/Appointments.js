import React, { useState, useEffect } from "react";
import {
    MdDescription,
    MdCheck,
    MdEmail,
    MdVisibility,
    MdRefresh,
    MdClose,
    MdCheckCircle,
} from "react-icons/md";
import { useAuth } from "../contexts/AuthContext";
import config from "../config/api";

const Appointments = ({ departmentId }) => {
    const { user, token } = useAuth();
    const [appointments, setAppointments] = useState([]);
    const [statusFilter, setStatusFilter] = useState("all");
    const [searchTerm, setSearchTerm] = useState("");
    const [assignedToMeOnly, setAssignedToMeOnly] = useState(false);
    const [loading, setLoading] = useState(true);
    const [showConfirmPopup, setShowConfirmPopup] = useState(false);
    const [confirmMessage, setConfirmMessage] = useState("");
    const [isSuccess, setIsSuccess] = useState(false);

    useEffect(() => {
        const fetchAppointments = async () => {
            setLoading(true);
            try {
                console.log(
                    "Fetching appointments from:",
                    config.API_BASE_URL + config.endpoints.appointmentsList
                );
                console.log(
                    "Using token:",
                    token ? "Token available" : "No token"
                );

                const res = await fetch(
                    config.API_BASE_URL + config.endpoints.appointmentsList,
                    {
                        headers: {
                            Authorization: `Bearer ${token}`,
                        },
                    }
                );

                console.log("Response received:", {
                    status: res.status,
                    ok: res.ok,
                    redirected: res.redirected,
                    url: res.url,
                    bodyUsed: res.bodyUsed,
                });

                if (res.ok) {
                    const data = await res.json();
                    console.log("Fetched appointments data:", data);

                    // Extract appointments array from the response object
                    const appointmentsArray = data.appointments || data;
                    console.log("Appointments array:", appointmentsArray);
                    console.log("Is array:", Array.isArray(appointmentsArray));

                    // Ensure data is an array
                    setAppointments(
                        Array.isArray(appointmentsArray)
                            ? appointmentsArray
                            : []
                    );
                } else {
                    console.error("Failed to fetch appointments:", res.status);
                    setAppointments([]);
                }
            } catch (err) {
                console.error("Error fetching appointments:", err);
                setAppointments([]);
            } finally {
                setLoading(false);
            }
        };
        if (token) fetchAppointments();
    }, [token]);

    // Function to show confirmation popup
    const showConfirmation = (message, success = true) => {
        setConfirmMessage(message);
        setIsSuccess(success);
        setShowConfirmPopup(true);
        // Auto hide after 3 seconds
        setTimeout(() => {
            setShowConfirmPopup(false);
        }, 3000);
    };

    // Backend already filters by department, so we start with all appointments
    let departmentAppointments = appointments || [];

    // Assigned to me filter
    if (assignedToMeOnly && user?.admin_id) {
        departmentAppointments = departmentAppointments.filter(
            (apt) => apt.assigned_admin_id === user.admin_id
        );
    }

    // Apply status filter
    if (statusFilter !== "all") {
        departmentAppointments = departmentAppointments.filter(
            (apt) => apt.status === statusFilter
        );
    }

    // Apply search filter
    if (searchTerm) {
        departmentAppointments = departmentAppointments.filter(
            (apt) =>
                apt.citizen_name
                    .toLowerCase()
                    .includes(searchTerm.toLowerCase()) ||
                apt.reference_number
                    .toLowerCase()
                    .includes(searchTerm.toLowerCase()) ||
                apt.service_name
                    .toLowerCase()
                    .includes(searchTerm.toLowerCase())
        );
    }

    // Sort by appointment date
    departmentAppointments.sort(
        (a, b) =>
            new Date(a.appointment_datetime) - new Date(b.appointment_datetime)
    );

    const getStatusBadgeClass = (status) => {
        return `status-badge status-${status.toLowerCase().replace(" ", "")}`;
    };

    const formatDateTime = (dateTime) => {
        const date = new Date(dateTime);
        return {
            date: date.toLocaleDateString(),
            time: date.toLocaleTimeString([], {
                hour: "2-digit",
                minute: "2-digit",
            }),
        };
    };

    const handleStatusChange = async (appointmentId, newStatus) => {
        try {
            const response = await fetch(
                `${config.API_BASE_URL}${config.endpoints.appointmentUpdate}/${appointmentId}`,
                {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json",
                        Authorization: `Bearer ${token}`,
                    },
                    body: JSON.stringify({
                        status: newStatus,
                    }),
                }
            );

            if (response.ok) {
                await response.json(); // Wait for response but don't store it
                // Update the appointments list with the new status
                setAppointments((prev) =>
                    prev.map((apt) =>
                        apt.appointment_id === appointmentId
                            ? { ...apt, status: newStatus }
                            : apt
                    )
                );
                showConfirmation(
                    `Appointment status updated to ${newStatus} successfully!`
                );
            } else {
                console.error(
                    "Failed to update appointment status:",
                    response.status
                );
                showConfirmation(
                    "Failed to update appointment status. Please try again.",
                    false
                );
            }
        } catch (error) {
            console.error("Error updating appointment status:", error);
            showConfirmation(
                "Error updating appointment status. Please try again.",
                false
            );
        }
    };

    const handleCommunicateWithCitizen = (
        appointmentId,
        citizenEmail,
        citizenName
    ) => {
        // TODO: Implement backend API call to send communication to citizen
        // Backend endpoint: POST /api/appointments/{appointmentId}/communicate
        // Headers: Authorization: Bearer {token}, Content-Type: application/json
        // Body: {
        //   recipient_email: citizenEmail,
        //   subject: "Regarding your upcoming appointment",
        //   message: message,
        //   appointment_id: appointmentId,
        //   sender_admin_id: admin_id
        // }
        // Response: { success: true, message_sent: true, message_id: string }

        // TODO: Implement messaging feature when available
        showConfirmation(
            "Messaging feature will be available in future updates.",
            false
        );
    };

    const statusOptions = [
        "Booked",
        "Confirmed",
        "Completed",
        "Cancelled",
        "NoShow",
    ];

    const [documents, setDocuments] = useState([]);
    const [isDocumentModalOpen, setIsDocumentModalOpen] = useState(false);
    const [selectedAppointmentForDocs, setSelectedAppointmentForDocs] =
        useState(null);
    const [documentLoading, setDocumentLoading] = useState(false);

    const handleViewDocuments = async (appointmentId) => {
        try {
            setSelectedAppointmentForDocs(appointmentId);
            setIsDocumentModalOpen(true);
            setDocumentLoading(true);
            setDocuments([]); // Clear previous documents

            const response = await fetch(
                `${config.API_BASE_URL}${config.endpoints.appointmentDocuments}/${appointmentId}/documents`,
                {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                }
            );

            if (response.ok) {
                const docs = await response.json();
                setDocuments(docs);
                console.log("Fetched documents:", docs);
            } else {
                console.error("Failed to fetch documents:", response.status);
                setDocuments([]);
                showConfirmation(
                    "Failed to load documents. Please try again.",
                    false
                );
            }
        } catch (error) {
            console.error("Error fetching documents:", error);
            setDocuments([]);
            showConfirmation(
                "Error loading documents. Please try again.",
                false
            );
        } finally {
            setDocumentLoading(false);
        }
    };

    return (
        <div>
            <div className="content-header">
                <h2>Appointment Management</h2>
                <p className="content-subtitle">
                    Manage and track appointments for your department
                </p>
            </div>
            {/* Filters */}
            <div
                style={{
                    background: "white",
                    padding: "1.5rem",
                    borderRadius: "8px",
                    boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
                    marginBottom: "2rem",
                    display: "flex",
                    gap: "1rem",
                    flexWrap: "wrap",
                    alignItems: "center",
                }}
            >
                <div style={{ flex: "1", minWidth: "200px" }}>
                    <label
                        style={{
                            display: "block",
                            marginBottom: "0.5rem",
                            fontWeight: "500",
                        }}
                    >
                        Search Appointments
                    </label>
                    <input
                        type="text"
                        placeholder="Search by name, reference, or service..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        style={{
                            width: "100%",
                            padding: "0.75rem",
                            border: "1px solid #e9ecef",
                            borderRadius: "4px",
                            fontSize: "0.9rem",
                        }}
                    />
                </div>
                <div style={{ minWidth: "150px" }}>
                    <label
                        style={{
                            display: "block",
                            marginBottom: "0.5rem",
                            fontWeight: "500",
                        }}
                    >
                        Filter by Status
                    </label>
                    <select
                        value={statusFilter}
                        onChange={(e) => setStatusFilter(e.target.value)}
                        style={{
                            width: "100%",
                            padding: "0.75rem",
                            border: "1px solid #e9ecef",
                            borderRadius: "4px",
                            fontSize: "0.9rem",
                        }}
                    >
                        <option value="all">All Statuses</option>
                        <option value="Booked">Booked</option>
                        <option value="Confirmed">Confirmed</option>
                        <option value="Completed">Completed</option>
                        <option value="Cancelled">Cancelled</option>
                        <option value="NoShow">No Show</option>
                    </select>
                </div>
                <div style={{ minWidth: "180px" }}>
                    <label
                        style={{
                            display: "block",
                            marginBottom: "0.5rem",
                            fontWeight: "500",
                        }}
                    >
                        Assigned Appointments to Me
                    </label>
                    <button
                        className={
                            assignedToMeOnly
                                ? "btn btn-primary"
                                : "btn btn-outline"
                        }
                        style={{
                            width: "100%",
                            padding: "0.75rem",
                            borderRadius: "4px",
                            fontWeight: "500",
                        }}
                        onClick={() => setAssignedToMeOnly((v) => !v)}
                    >
                        {assignedToMeOnly
                            ? "Showing Only Mine"
                            : "Show Only Mine"}
                    </button>
                </div>
            </div>

            {/* Appointments Table */}
            <div className="appointments-section">
                <div className="appointments-header">
                    <h3>Appointments ({departmentAppointments.length})</h3>
                </div>

                {loading ? (
                    <div
                        style={{
                            display: "flex",
                            justifyContent: "center",
                            alignItems: "center",
                            minHeight: "200px",
                            flexDirection: "column",
                            gap: "1rem",
                        }}
                    >
                        <MdRefresh
                            style={{
                                fontSize: "3rem",
                                color: "#4E6E63",
                                animation: "spin 1s linear infinite",
                            }}
                        />
                        <p style={{ color: "#6c757d", fontSize: "1.1rem" }}>
                            Loading appointments...
                        </p>
                    </div>
                ) : (
                    <div style={{ overflowX: "auto" }}>
                        <table className="appointments-table">
                            <thead>
                                <tr>
                                    <th>Reference</th>
                                    <th>Citizen Details</th>
                                    <th>Service</th>
                                    <th>Date & Time</th>
                                    <th>Status</th>
                                    <th>Documents</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {departmentAppointments.length > 0 ? (
                                    departmentAppointments.map(
                                        (appointment) => {
                                            const { date, time } =
                                                formatDateTime(
                                                    appointment.appointment_datetime
                                                );
                                            return (
                                                <tr
                                                    key={
                                                        appointment.appointment_id
                                                    }
                                                >
                                                    <td>
                                                        <div
                                                            style={{
                                                                fontWeight:
                                                                    "500",
                                                            }}
                                                        >
                                                            {
                                                                appointment.reference_number
                                                            }
                                                        </div>
                                                        <div
                                                            style={{
                                                                fontSize:
                                                                    "0.8rem",
                                                                color: "#666",
                                                            }}
                                                        >
                                                            ID:{" "}
                                                            {appointment.appointment_id.slice(
                                                                -8
                                                            )}
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div
                                                            style={{
                                                                fontWeight:
                                                                    "500",
                                                            }}
                                                        >
                                                            {
                                                                appointment.citizen_name
                                                            }
                                                        </div>
                                                        <div
                                                            style={{
                                                                fontSize:
                                                                    "0.9rem",
                                                                color: "#666",
                                                            }}
                                                        >
                                                            NIC:{" "}
                                                            {
                                                                appointment.citizen_nic
                                                            }
                                                        </div>
                                                        <div
                                                            style={{
                                                                fontSize:
                                                                    "0.9rem",
                                                                color: "#666",
                                                            }}
                                                        >
                                                            {
                                                                appointment.citizen_phone
                                                            }
                                                        </div>
                                                    </td>
                                                    <td>
                                                        {
                                                            appointment.service_name
                                                        }
                                                    </td>
                                                    <td>
                                                        <div
                                                            style={{
                                                                fontWeight:
                                                                    "500",
                                                            }}
                                                        >
                                                            {date}
                                                        </div>
                                                        <div
                                                            style={{
                                                                color: "#666",
                                                            }}
                                                        >
                                                            {time}
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <span
                                                            className={getStatusBadgeClass(
                                                                appointment.status
                                                            )}
                                                        >
                                                            {appointment.status}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <button
                                                            onClick={() =>
                                                                handleViewDocuments(
                                                                    appointment.appointment_id
                                                                )
                                                            }
                                                            style={{
                                                                padding:
                                                                    "0.5rem 1rem",
                                                                border: "1px solid #4E6E63",
                                                                borderRadius:
                                                                    "4px",
                                                                fontSize:
                                                                    "0.8rem",
                                                                background:
                                                                    "white",
                                                                color: "#4E6E63",
                                                                cursor: "pointer",
                                                                transition:
                                                                    "all 0.2s",
                                                            }}
                                                            onMouseOver={(
                                                                e
                                                            ) => {
                                                                e.target.style.background =
                                                                    "#4E6E63";
                                                                e.target.style.color =
                                                                    "white";
                                                            }}
                                                            onMouseOut={(e) => {
                                                                e.target.style.background =
                                                                    "white";
                                                                e.target.style.color =
                                                                    "#4E6E63";
                                                            }}
                                                        >
                                                            <MdDescription
                                                                style={{
                                                                    marginRight:
                                                                        "0.25rem",
                                                                }}
                                                            />
                                                            View Documents
                                                        </button>
                                                    </td>
                                                    <td>
                                                        <div
                                                            style={{
                                                                display: "flex",
                                                                flexDirection:
                                                                    "column",
                                                                gap: "0.5rem",
                                                            }}
                                                        >
                                                            {appointment.status ===
                                                                "Booked" && (
                                                                <button
                                                                    onClick={() =>
                                                                        handleStatusChange(
                                                                            appointment.appointment_id,
                                                                            "Confirmed"
                                                                        )
                                                                    }
                                                                    style={{
                                                                        padding:
                                                                            "0.4rem 0.8rem",
                                                                        border: "none",
                                                                        borderRadius:
                                                                            "4px",
                                                                        fontSize:
                                                                            "0.75rem",
                                                                        background:
                                                                            "#28a745",
                                                                        color: "white",
                                                                        cursor: "pointer",
                                                                        transition:
                                                                            "background-color 0.2s",
                                                                    }}
                                                                    onMouseOver={(
                                                                        e
                                                                    ) => {
                                                                        e.target.style.background =
                                                                            "#218838";
                                                                    }}
                                                                    onMouseOut={(
                                                                        e
                                                                    ) => {
                                                                        e.target.style.background =
                                                                            "#28a745";
                                                                    }}
                                                                >
                                                                    <MdCheck
                                                                        style={{
                                                                            marginRight:
                                                                                "0.25rem",
                                                                        }}
                                                                    />
                                                                    Confirm
                                                                </button>
                                                            )}

                                                            <button
                                                                onClick={() =>
                                                                    handleCommunicateWithCitizen(
                                                                        appointment.appointment_id,
                                                                        appointment.citizen_email ||
                                                                            "citizen@email.com",
                                                                        appointment.citizen_name
                                                                    )
                                                                }
                                                                style={{
                                                                    padding:
                                                                        "0.4rem 0.8rem",
                                                                    border: "1px solid #007bff",
                                                                    borderRadius:
                                                                        "4px",
                                                                    fontSize:
                                                                        "0.75rem",
                                                                    background:
                                                                        "white",
                                                                    color: "#007bff",
                                                                    cursor: "pointer",
                                                                    transition:
                                                                        "all 0.2s",
                                                                }}
                                                                onMouseOver={(
                                                                    e
                                                                ) => {
                                                                    e.target.style.background =
                                                                        "#007bff";
                                                                    e.target.style.color =
                                                                        "white";
                                                                }}
                                                                onMouseOut={(
                                                                    e
                                                                ) => {
                                                                    e.target.style.background =
                                                                        "white";
                                                                    e.target.style.color =
                                                                        "#007bff";
                                                                }}
                                                            >
                                                                <MdEmail
                                                                    style={{
                                                                        marginRight:
                                                                            "0.25rem",
                                                                    }}
                                                                />
                                                                Message
                                                            </button>

                                                            <select
                                                                value={
                                                                    appointment.status
                                                                }
                                                                onChange={(e) =>
                                                                    handleStatusChange(
                                                                        appointment.appointment_id,
                                                                        e.target
                                                                            .value
                                                                    )
                                                                }
                                                                className="status-dropdown"
                                                                title="Change appointment status"
                                                            >
                                                                {statusOptions.map(
                                                                    (
                                                                        status
                                                                    ) => (
                                                                        <option
                                                                            key={
                                                                                status
                                                                            }
                                                                            value={
                                                                                status
                                                                            }
                                                                        >
                                                                            {
                                                                                status
                                                                            }
                                                                        </option>
                                                                    )
                                                                )}
                                                            </select>
                                                        </div>
                                                    </td>
                                                </tr>
                                            );
                                        }
                                    )
                                ) : (
                                    <tr>
                                        <td colSpan="7" className="empty-state">
                                            <h4>No appointments found</h4>
                                            <p>
                                                Try adjusting your search
                                                criteria or status filter.
                                            </p>
                                        </td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>

            {/* Document Viewer Modal */}
            {isDocumentModalOpen && (
                <div
                    style={{
                        position: "fixed",
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        backgroundColor: "rgba(0, 0, 0, 0.5)",
                        display: "flex",
                        justifyContent: "center",
                        alignItems: "center",
                        zIndex: 1000,
                    }}
                >
                    <div
                        style={{
                            backgroundColor: "white",
                            borderRadius: "8px",
                            padding: "2rem",
                            maxWidth: "800px",
                            maxHeight: "80vh",
                            overflow: "auto",
                            width: "90%",
                        }}
                    >
                        <div
                            style={{
                                display: "flex",
                                justifyContent: "space-between",
                                alignItems: "center",
                                marginBottom: "1rem",
                            }}
                        >
                            <div>
                                <h3 style={{ margin: 0 }}>
                                    Appointment Documents
                                </h3>
                                {selectedAppointmentForDocs && (
                                    <p
                                        style={{
                                            margin: "0.5rem 0 0 0",
                                            fontSize: "0.9rem",
                                            color: "#6c757d",
                                        }}
                                    >
                                        Appointment ID:{" "}
                                        {selectedAppointmentForDocs}
                                    </p>
                                )}
                            </div>
                            <button
                                onClick={() => {
                                    setIsDocumentModalOpen(false);
                                    setSelectedAppointmentForDocs(null);
                                    setDocuments([]);
                                    setDocumentLoading(false);
                                }}
                                style={{
                                    background: "none",
                                    border: "none",
                                    fontSize: "1.5rem",
                                    cursor: "pointer",
                                    color: "#6c757d",
                                }}
                            >
                                ×
                            </button>
                        </div>

                        {documentLoading ? (
                            <div
                                style={{
                                    display: "flex",
                                    justifyContent: "center",
                                    alignItems: "center",
                                    minHeight: "150px",
                                    flexDirection: "column",
                                    gap: "1rem",
                                }}
                            >
                                <MdRefresh
                                    style={{
                                        fontSize: "2rem",
                                        color: "#4E6E63",
                                        animation: "spin 1s linear infinite",
                                    }}
                                />
                                <p
                                    style={{
                                        color: "#6c757d",
                                        fontSize: "1rem",
                                    }}
                                >
                                    Loading documents...
                                </p>
                            </div>
                        ) : documents.length === 0 ? (
                            <p
                                style={{
                                    textAlign: "center",
                                    color: "#6c757d",
                                }}
                            >
                                No documents found for this appointment.
                            </p>
                        ) : (
                            <div style={{ display: "grid", gap: "1rem" }}>
                                {documents.map((doc) => (
                                    <div
                                        key={doc.appointment_doc_id}
                                        style={{
                                            border: "1px solid #dee2e6",
                                            borderRadius: "8px",
                                            padding: "1rem",
                                            display: "flex",
                                            justifyContent: "space-between",
                                            alignItems: "center",
                                        }}
                                    >
                                        <div>
                                            <h4
                                                style={{
                                                    margin: "0 0 0.5rem 0",
                                                    color: "#4E6E63",
                                                }}
                                            >
                                                {doc.document_name}
                                            </h4>
                                            <p
                                                style={{
                                                    margin: 0,
                                                    fontSize: "0.9rem",
                                                    color: "#6c757d",
                                                }}
                                            >
                                                Uploaded:{" "}
                                                {new Date(
                                                    doc.uploaded_at
                                                ).toLocaleDateString()}
                                            </p>
                                        </div>
                                        <div
                                            style={{
                                                display: "flex",
                                                gap: "0.5rem",
                                            }}
                                        >
                                            {/* View button - opens PDF in new tab */}
                                            <button
                                                onClick={() =>
                                                    window.open(
                                                        doc.document_url,
                                                        "_blank"
                                                    )
                                                }
                                                style={{
                                                    background: "#007bff",
                                                    color: "white",
                                                    border: "none",
                                                    padding: "0.5rem 1rem",
                                                    borderRadius: "4px",
                                                    cursor: "pointer",
                                                    display: "flex",
                                                    alignItems: "center",
                                                    gap: "0.5rem",
                                                }}
                                            >
                                                <MdVisibility />
                                                View
                                            </button>
                                            {/* Download button */}
                                            <a
                                                href={doc.document_url}
                                                download={doc.document_name}
                                                style={{
                                                    background: "#28a745",
                                                    color: "white",
                                                    border: "none",
                                                    padding: "0.5rem 1rem",
                                                    borderRadius: "4px",
                                                    cursor: "pointer",
                                                    display: "flex",
                                                    alignItems: "center",
                                                    gap: "0.5rem",
                                                    textDecoration: "none",
                                                }}
                                            >
                                                <MdDescription />
                                                Download
                                            </a>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            )}

            {/* Confirmation Popup */}
            {showConfirmPopup && (
                <>
                    <div className="confirmation-popup-overlay" />
                    <div
                        className={`confirmation-popup ${
                            isSuccess ? "success" : "error"
                        }`}
                    >
                        <div
                            style={{
                                display: "flex",
                                alignItems: "center",
                                justifyContent: "center",
                                gap: "0.5rem",
                                marginBottom: "1rem",
                            }}
                        >
                            {isSuccess ? (
                                <MdCheckCircle
                                    style={{
                                        color: "var(--accent-green)",
                                        fontSize: "1.5rem",
                                    }}
                                />
                            ) : (
                                <MdClose
                                    style={{
                                        color: "var(--primary-red)",
                                        fontSize: "1.5rem",
                                    }}
                                />
                            )}
                            <h3
                                style={{
                                    margin: 0,
                                    color: isSuccess
                                        ? "var(--accent-green)"
                                        : "var(--primary-red)",
                                }}
                            >
                                {isSuccess ? "Success!" : "Error"}
                            </h3>
                        </div>
                        <p
                            style={{
                                margin: "0 0 1.5rem 0",
                                color: "var(--text-dark)",
                            }}
                        >
                            {confirmMessage}
                        </p>
                        <button
                            onClick={() => setShowConfirmPopup(false)}
                            className="btn btn-primary"
                            style={{ minWidth: "100px" }}
                        >
                            OK
                        </button>
                    </div>
                </>
            )}
        </div>
    );
};

export default Appointments;
