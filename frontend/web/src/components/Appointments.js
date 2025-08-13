import React, { useState } from "react";
import { MdDescription, MdCheck, MdEmail } from "react-icons/md";
import appointmentsData from "../data/appointments.json";
import DocumentViewer from "./DocumentViewer";

const Appointments = ({ departmentId }) => {
    const [statusFilter, setStatusFilter] = useState("all");
    const [searchTerm, setSearchTerm] = useState("");
    const [selectedAppointmentId, setSelectedAppointmentId] = useState(null);
    const [isDocumentViewerOpen, setIsDocumentViewerOpen] = useState(false);

    // Filter appointments for current department
    let departmentAppointments = appointmentsData.filter(
        (apt) => apt.department_id === departmentId
    );

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

    const handleStatusChange = (appointmentId, newStatus) => {
        // In a real application, this would make an API call
        console.log(
            `Changing appointment ${appointmentId} status to ${newStatus}`
        );
        alert(`Status would be changed to ${newStatus} in a real application`);
    };

    const handleConfirmAppointment = (appointmentId) => {
        // TODO: Implement backend API call to confirm appointment
        // Backend endpoint: PUT /api/appointments/{appointmentId}/confirm
        // Headers: Authorization: Bearer {token}
        // Body: { confirmed_by: admin_id, confirmed_at: timestamp }
        // Response: { success: true, appointment: updatedAppointment }
        console.log(`Confirming appointment ${appointmentId}`);
        alert(
            "Appointment confirmed! In real application, this would update the database."
        );
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

        const message = prompt(
            `Send a message to ${citizenName} regarding their appointment.\n\nEnter your message:`
        );

        if (message && message.trim()) {
            console.log(`Sending message to ${citizenEmail}: ${message}`);
            alert(
                `Message would be sent to ${citizenName} in real application:\n\n"${message}"`
            );
        }
    };

    const statusOptions = [
        "Booked",
        "Confirmed",
        "Completed",
        "Cancelled",
        "NoShow",
    ];

    const handleViewDocuments = (appointmentId) => {
        setSelectedAppointmentId(appointmentId);
        setIsDocumentViewerOpen(true);
    };

    const closeDocumentViewer = () => {
        setIsDocumentViewerOpen(false);
        setSelectedAppointmentId(null);
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
            </div>

            {/* Appointments Table */}
            <div className="appointments-section">
                <div className="appointments-header">
                    <h3>Appointments ({departmentAppointments.length})</h3>
                </div>

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
                                departmentAppointments.map((appointment) => {
                                    const { date, time } = formatDateTime(
                                        appointment.appointment_datetime
                                    );
                                    return (
                                        <tr key={appointment.appointment_id}>
                                            <td>
                                                <div
                                                    style={{
                                                        fontWeight: "500",
                                                    }}
                                                >
                                                    {
                                                        appointment.reference_number
                                                    }
                                                </div>
                                                <div
                                                    style={{
                                                        fontSize: "0.8rem",
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
                                                        fontWeight: "500",
                                                    }}
                                                >
                                                    {appointment.citizen_name}
                                                </div>
                                                <div
                                                    style={{
                                                        fontSize: "0.9rem",
                                                        color: "#666",
                                                    }}
                                                >
                                                    NIC:{" "}
                                                    {appointment.citizen_nic}
                                                </div>
                                                <div
                                                    style={{
                                                        fontSize: "0.9rem",
                                                        color: "#666",
                                                    }}
                                                >
                                                    {appointment.citizen_phone}
                                                </div>
                                            </td>
                                            <td>{appointment.service_name}</td>
                                            <td>
                                                <div
                                                    style={{
                                                        fontWeight: "500",
                                                    }}
                                                >
                                                    {date}
                                                </div>
                                                <div style={{ color: "#666" }}>
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
                                                        padding: "0.5rem 1rem",
                                                        border: "1px solid #4E6E63",
                                                        borderRadius: "4px",
                                                        fontSize: "0.8rem",
                                                        background: "white",
                                                        color: "#4E6E63",
                                                        cursor: "pointer",
                                                        transition: "all 0.2s",
                                                    }}
                                                    onMouseOver={(e) => {
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
                                                        flexDirection: "column",
                                                        gap: "0.5rem",
                                                    }}
                                                >
                                                    {appointment.status ===
                                                        "Booked" && (
                                                        <button
                                                            onClick={() =>
                                                                handleConfirmAppointment(
                                                                    appointment.appointment_id
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
                                                            onMouseOut={(e) => {
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
                                                            borderRadius: "4px",
                                                            fontSize: "0.75rem",
                                                            background: "white",
                                                            color: "#007bff",
                                                            cursor: "pointer",
                                                            transition:
                                                                "all 0.2s",
                                                        }}
                                                        onMouseOver={(e) => {
                                                            e.target.style.background =
                                                                "#007bff";
                                                            e.target.style.color =
                                                                "white";
                                                        }}
                                                        onMouseOut={(e) => {
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
                                                                e.target.value
                                                            )
                                                        }
                                                        style={{
                                                            padding: "0.4rem",
                                                            border: "1px solid #e9ecef",
                                                            borderRadius: "4px",
                                                            fontSize: "0.75rem",
                                                            background: "white",
                                                        }}
                                                    >
                                                        {statusOptions.map(
                                                            (status) => (
                                                                <option
                                                                    key={status}
                                                                    value={
                                                                        status
                                                                    }
                                                                >
                                                                    {status}
                                                                </option>
                                                            )
                                                        )}
                                                    </select>
                                                </div>
                                            </td>
                                        </tr>
                                    );
                                })
                            ) : (
                                <tr>
                                    <td colSpan="7" className="empty-state">
                                        <h4>No appointments found</h4>
                                        <p>
                                            Try adjusting your search criteria
                                            or status filter.
                                        </p>
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Document Viewer Modal */}
            <DocumentViewer
                appointmentId={selectedAppointmentId}
                isOpen={isDocumentViewerOpen}
                onClose={closeDocumentViewer}
            />
        </div>
    );
};

export default Appointments;
