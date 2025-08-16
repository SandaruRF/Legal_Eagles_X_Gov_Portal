import React, { useState, useEffect } from "react";
import {
  getPendingKYCVerifications,
  verifyKYC,
  getKYCById,
} from "../services/AdminKYCService";

// --- SVG ICON COMPONENTS ---
const RefreshIcon = ({ style }) => (
  <svg
    style={style}
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke="currentColor"
  >
    <path
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={2}
      d="M4 4v5h5M20 20v-5h-5M4 4a8 8 0 0114.24 5.21M20 20a8 8 0 01-14.24-5.21"
    />
  </svg>
);

// --- MAIN COMPONENT ---
function KYCVerifications() {
  const [verifications, setVerifications] = useState([]);
  const [selectedVerification, setSelectedVerification] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchPendingVerifications = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("No authentication token found");
      }

      const data = await getPendingKYCVerifications(token);
      setVerifications(data);
      console.log("Pending KYC Verifications:", data);
    } catch (err) {
      setError(err.message || "Failed to fetch pending verifications.");
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchPendingVerifications();
  }, []);

  const handleViewDetails = async (id) => {
    setIsLoading(true);
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("No authentication token found");
      }

      const data = await getKYCById(id, token);
      setSelectedVerification(data);
      console.log("Selected KYC: ", data);
    } catch (err) {
      setError(err.message || "Failed to fetch verification details.");
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerificationAction = async (id, status) => {
    setIsLoading(true);
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("No authentication token found");
      }
      await verifyKYC(id, token, status);
      console.log(`KYC ID: ${id} has been ${status.toLowerCase()}`);

      setVerifications(verifications.filter((v) => v.kyc_id !== id));
      setSelectedVerification(null);
    } catch (err) {
      console.error(`Failed to ${status} verification.`, err);
    }
    finally {
        setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="content-header">
        <h2>KYC Verifications</h2>
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            minHeight: "300px",
            flexDirection: "column",
            gap: "1rem",
          }}
        >
          <RefreshIcon
            style={{
              fontSize: "3rem",
              color: "#4E6E63",
              animation: "spin 1s linear infinite",
              width: "3rem",
              height: "3rem",
            }}
          />
          <p style={{ color: "#6c757d", fontSize: "1.1rem" }}>
            Loading verification data...
          </p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="content-header">
        <h2>KYC Verifications</h2>
        <div className="error-container p-4 mt-4 text-center bg-red-50 rounded-lg">
          <p className="error-message text-red-700">
            Error loading verifications: {error}
          </p>
          <button
            onClick={fetchPendingVerifications}
            className="retry-button mt-4 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  if (selectedVerification) {
    const { citizen, status, nic_front_url, nic_back_url, selfie_url } =
      selectedVerification;

    return (
      <div className="content-header">
        <h2>KYC Verifications</h2>
        <button onClick={() => setSelectedVerification(null)}
            className="back-kyc-pending">
            Back to List
          </button>
        <div className="verification-details">
          <h3>User Information</h3>
          <p>
            <strong>Full Name:</strong> {citizen.full_name}
          </p>
          <p>
            <strong>NIC Number:</strong> {citizen.nic_no}
          </p>
          <p>
            <strong>Phone:</strong> {citizen.phone_no}
          </p>
          <p>
            <strong>Email:</strong> {citizen.email}
          </p>
          <p>
            <strong>Status:</strong> {status}
          </p>

          <h3>Documents</h3>
          <div className="document-grid">
            {nic_front_url ? (
              <div className="document-item">
                <h4>NIC Front</h4>
                <img src={nic_front_url.trim()} alt="NIC Front" width="300" />
              </div>
            ) : (
              <p>NIC Front not provided.</p>
            )}

            {nic_back_url ? (
              <div className="document-item">
                <h4>NIC Back</h4>
                <img src={nic_back_url.trim()} alt="NIC Back" width="300" />
              </div>
            ) : (
              <p>NIC Back not provided.</p>
            )}

            {selfie_url ? (
              <div className="document-item">
                <h4>Selfie</h4>
                <img src={selfie_url.trim()} alt="Selfie" width="300" />
              </div>
            ) : (
              <p>Selfie not provided.</p>
            )}
          </div>

          
          <div className="verification-actions">
            <button
              onClick={() =>
                handleVerificationAction(selectedVerification.kyc_id, "Verified")
              }
              className="approve-button"
            >
              Approve
            </button>
            <button
              onClick={() =>
                handleVerificationAction(selectedVerification.kyc_id, "Rejected")
              }
              className="reject-button"
            >
              Reject
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (verifications.length > 0) {
    return (
      <div className="content-header">
        <h2>KYC Verifications</h2>
        <div className="verification-table-container">
          <table className="verification-table">
            <thead>
              <tr>
                <th>KYC ID</th>
                <th>Full Name</th>
                <th>NIC Number</th>
                <th>Phone</th>
                <th>Email</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {verifications.map((verification) => {
                const { citizen } = verification;

                return (
                  <tr key={verification.kyc_id}>
                    <td>{verification.kyc_id}</td>
                    <td>{citizen.full_name}</td>
                    <td>{citizen.nic_no}</td>
                    <td>{citizen.phone_no}</td>
                    <td>{citizen.email}</td>
                    <td>{verification.status}</td>
                    <td>
                      <button
                        onClick={() => handleViewDetails(verification.kyc_id)}
                      >
                        View Details
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    );
  }

  if (verifications.length === 0) {
    return (
      <div className="content-header">
        <h2>KYC Verifications</h2>
        <p>No pending verifications found.</p>
      </div>
    );
  }
}

export default KYCVerifications;
