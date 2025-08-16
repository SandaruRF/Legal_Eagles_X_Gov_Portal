import config from "../config/api";

  // KYC Verification
  export async function getPendingKYCVerifications(token) {
    try {
      const response = await fetch(
        `${config.API_BASE_URL}${config.endpoints.pending_kycs}`,
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
      console.error("Error fetching pending KYC verifications:", error);
      throw error;
    }
  }

  export async function verifyKYC(kycId, token, status) {
    try {
      const response = await fetch(
        `${config.API_BASE_URL}${config.endpoints.verify_kyc.replace(
          "{kyc_id}",
          kycId
        )}`,
        {
          method: "PATCH",
          headers: config.getAuthHeaders(token),
          body: JSON.stringify({
            status: status,
          }),
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
      console.error("Error verifying KYC:", error);
      throw error;
    }
  }

  export async function getKYCById(kycId, token) {
    try {
      const response = await fetch(
        `${config.API_BASE_URL}${config.endpoints.kyc_by_id.replace(
          "{kyc_id}",
          kycId
        )}`,
        {
          method: "GET",
          headers: config.getAuthHeaders(token),
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
      console.error("Error fetching KYC by ID:", error);
      throw error;
    }
  }

