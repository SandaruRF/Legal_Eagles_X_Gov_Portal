import React, { useState } from "react";
import appointmentDocuments from "../data/appointmentDocuments.json";

const DocumentViewer = ({ appointmentId, isOpen, onClose }) => {
    const [documents, setDocuments] = useState(
        appointmentDocuments.filter(
            (doc) => doc.appointment_id === appointmentId
        )
    );

    if (!isOpen) return null;

    const handleStatusChange = (docId, newStatus) => {
        setDocuments((prev) =>
            prev.map((doc) =>
                doc.appointment_doc_id === docId
                    ? { ...doc, status: newStatus }
                    : doc
            )
        );
        // In a real app, this would make an API call
        console.log(`Document ${docId} status changed to ${newStatus}`);
    };

    const getStatusClass = (status) => {
        const statusMap = {
            Verified: "status-verified",
            "Pending Review": "status-pending",
            Rejected: "status-rejected",
            "Requires Correction": "status-requires-correction",
        };
        return `document-status ${statusMap[status] || "status-pending"}`;
    };

    const handleViewDocument = (documentUrl) => {
        // In a real app, this would open the document in a new tab or viewer
        alert(`Would open document: ${documentUrl}`);
    };

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <div className="modal-header">
                    <h3>Appointment Documents</h3>
                    <button className="close-btn" onClick={onClose}>
                        ×
                    </button>
                </div>
                <div className="modal-body">
                    {documents.length > 0 ? (
                        <>
                            <p style={{ marginBottom: "1rem", color: "#666" }}>
                                Review and verify the documents submitted for
                                this appointment.
                            </p>
                            <div className="documents-grid">
                                {documents.map((doc) => (
                                    <div
                                        key={doc.appointment_doc_id}
                                        className="document-card"
                                    >
                                        <div className="document-header">
                                            <div>
                                                <div className="document-name">
                                                    {doc.document_name}
                                                </div>
                                                <div className="document-type">
                                                    {doc.document_type}
                                                </div>
                                            </div>
                                            <span
                                                className={getStatusClass(
                                                    doc.status
                                                )}
                                            >
                                                {doc.status}
                                            </span>
                                        </div>

                                        <div
                                            style={{
                                                fontSize: "0.85rem",
                                                color: "#666",
                                                marginBottom: "1rem",
                                            }}
                                        >
                                            Uploaded:{" "}
                                            {new Date(
                                                doc.uploaded_at
                                            ).toLocaleString()}
                                        </div>

                                        <div className="document-actions">
                                            <button
                                                className="btn-small btn-view"
                                                onClick={() =>
                                                    handleViewDocument(
                                                        doc.document_url
                                                    )
                                                }
                                            >
                                                📄 View
                                            </button>

                                            {doc.status !== "Verified" && (
                                                <button
                                                    className="btn-small btn-approve"
                                                    onClick={() =>
                                                        handleStatusChange(
                                                            doc.appointment_doc_id,
                                                            "Verified"
                                                        )
                                                    }
                                                >
                                                    ✓ Approve
                                                </button>
                                            )}

                                            {doc.status !==
                                                "Requires Correction" && (
                                                <button
                                                    className="btn-small btn-reject"
                                                    onClick={() =>
                                                        handleStatusChange(
                                                            doc.appointment_doc_id,
                                                            "Requires Correction"
                                                        )
                                                    }
                                                >
                                                    ✗ Request Correction
                                                </button>
                                            )}
                                        </div>
                                    </div>
                                ))}
                            </div>

                            <div
                                style={{
                                    marginTop: "2rem",
                                    padding: "1rem",
                                    background: "#f8f9fa",
                                    borderRadius: "8px",
                                    textAlign: "center",
                                }}
                            >
                                <h4
                                    style={{
                                        marginBottom: "1rem",
                                        color: "#8C1F28",
                                    }}
                                >
                                    Document Verification Summary
                                </h4>
                                <div
                                    style={{
                                        display: "flex",
                                        justifyContent: "space-around",
                                        flexWrap: "wrap",
                                    }}
                                >
                                    <div>
                                        <strong>Verified:</strong>{" "}
                                        {
                                            documents.filter(
                                                (d) => d.status === "Verified"
                                            ).length
                                        }
                                    </div>
                                    <div>
                                        <strong>Pending:</strong>{" "}
                                        {
                                            documents.filter(
                                                (d) =>
                                                    d.status ===
                                                    "Pending Review"
                                            ).length
                                        }
                                    </div>
                                    <div>
                                        <strong>Need Correction:</strong>{" "}
                                        {
                                            documents.filter(
                                                (d) =>
                                                    d.status ===
                                                    "Requires Correction"
                                            ).length
                                        }
                                    </div>
                                </div>
                            </div>
                        </>
                    ) : (
                        <div className="empty-state">
                            <h4>No Documents Found</h4>
                            <p>
                                No documents have been uploaded for this
                                appointment yet.
                            </p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

export default DocumentViewer;
