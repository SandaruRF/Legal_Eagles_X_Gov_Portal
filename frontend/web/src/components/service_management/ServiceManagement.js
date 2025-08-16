import React, { useState } from 'react';
import { MdCheckCircle, MdClose, MdRefresh } from "react-icons/md";
import ServiceForm from './ServiceForm';
import FormBuilder from './FormBuilder';
import PreviewAndSave from './PreviewAndSave';

const ServiceManagement = ({ departmentId, department }) => {
  const [currentStep, setCurrentStep] = useState(1);
  const [loading, setLoading] = useState(false);
  const [showConfirmPopup, setShowConfirmPopup] = useState(false);
  const [confirmMessage, setConfirmMessage] = useState("");
  const [isSuccess, setIsSuccess] = useState(false);
  const [serviceData, setServiceData] = useState({
    departmentID: departmentId,
    name: '',
    description: '',
    requiredDocuments: [],
    formFields: []
  });

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

  const handleSave = async () => {
    try {
      setLoading(true);
      // TODO: Implement API call to save the service
      console.log('Saving service:', serviceData);
      
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      showConfirmation('Service created successfully!');
      
      // Reset form after successful save
      setTimeout(() => {
        setServiceData({
          name: '',
          description: '',
          requiredDocuments: [],
          formFields: []
        });
        setCurrentStep(1);
      }, 3000);
      
    } catch (error) {
      console.error('Error saving service:', error);
      showConfirmation('Failed to create service. Please try again.', false);
    } finally {
      setLoading(false);
    }
  };

  const getStepContent = () => {
    switch (currentStep) {
      case 1:
        return (
          <ServiceForm 
            data={serviceData}
            onUpdate={setServiceData}
            onNext={() => setCurrentStep(2)}
          />
        );
      case 2:
        return (
          <FormBuilder 
            data={serviceData}
            onUpdate={setServiceData}
            onNext={() => setCurrentStep(3)}
            onPrev={() => setCurrentStep(1)}
          />
        );
      case 3:
        return (
          <PreviewAndSave 
            data={serviceData}
            departmentId={departmentId}
            department={department}
            onPrev={() => setCurrentStep(2)}
            onSave={handleSave}
            loading={loading}
          />
        );
      default:
        return null;
    }
  };

  if (loading) {
    return (
      <div>
        <div className="content-header">
          <h2>Create New Government Service</h2>
          <p className="content-subtitle">
            Set up a new government service with custom registration forms
          </p>
        </div>
        <div className="loading service-loading">
          <MdRefresh className="loading-spinner" />
          <p>Creating your service...</p>
        </div>
      </div>
    );
  }

  return (
    <div>
      {/* Header Section */}
      <div className="content-header">
        <h2>Create New Government Service</h2>
        <p className="content-subtitle">
          Set up a new government service with custom registration forms
        </p>
      </div>

      {/* Step Indicator */}
      <div className="step-indicator-container">
        <div className="step-indicator">
          <div className={`step-item ${currentStep >= 1 ? 'active' : ''}`}>
            <span className="step-number">1</span>
            <span className="step-label">Service Details</span>
          </div>

          <div className={`step-connector ${currentStep >= 2 ? 'active' : ''}`} />

          <div className={`step-item ${currentStep >= 2 ? 'active' : ''}`}>
            <span className="step-number">2</span>
            <span className="step-label">Build Registration Form</span>
          </div>

          <div className={`step-connector ${currentStep >= 3 ? 'active' : ''}`} />

          <div className={`step-item ${currentStep >= 3 ? 'active' : ''}`}>
            <span className="step-number">3</span>
            <span className="step-label">Preview & Save</span>
          </div>
        </div>
      </div>

      {/* Main Content Area */}
      <div className="service-management-content">
        {getStepContent()}
      </div>

      {/* Confirmation Popup */}
      {showConfirmPopup && (
        <>
          <div className="confirmation-popup-overlay" />
          <div className={`confirmation-popup ${isSuccess ? 'success' : 'error'}`}>
            <div className="popup-header">
              {isSuccess ? (
                <MdCheckCircle className="popup-icon success-icon" />
              ) : (
                <MdClose className="popup-icon error-icon" />
              )}
              <h3 className="popup-title">
                {isSuccess ? "Success!" : "Error"}
              </h3>
            </div>
            <p className="popup-message">
              {confirmMessage}
            </p>
            <button
              onClick={() => setShowConfirmPopup(false)}
              className="btn btn-primary popup-button"
            >
              OK
            </button>
          </div>
        </>
      )}

      {/* No inline styles needed - they are now in app.css */}
    </div>
  );
};

export default ServiceManagement;
