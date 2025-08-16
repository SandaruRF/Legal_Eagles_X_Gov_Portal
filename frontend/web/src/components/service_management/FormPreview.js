import React from 'react';
import { MdVisibilityOff } from 'react-icons/md';

const FormPreview = ({ fields }) => {
  const renderField = (field) => {
    switch (field.type) {
      case 'text':
      case 'email':
      case 'tel':
      case 'number':
        return (
          <input
            type={field.type}
            placeholder={field.placeholder || `Enter ${field.label.toLowerCase()}`}
            disabled
            style={{
              width: "100%",
              padding: "0.75rem",
              border: "2px solid #e9ecef",
              borderRadius: "6px",
              fontSize: "1rem",
              background: "#f8f9fa",
              color: "var(--text-light)",
              cursor: "not-allowed",
            }}
          />
        );
      
      case 'date':
        return (
          <input 
            type="date" 
            disabled 
            style={{
              width: "100%",
              padding: "0.75rem",
              border: "2px solid #e9ecef",
              borderRadius: "6px",
              fontSize: "1rem",
              background: "#f8f9fa",
              color: "var(--text-light)",
              cursor: "not-allowed",
            }}
          />
        );
      
      case 'textarea':
        return (
          <textarea
            rows="3"
            placeholder={field.placeholder || `Enter ${field.label.toLowerCase()}`}
            disabled
            style={{
              width: "100%",
              padding: "0.75rem",
              border: "2px solid #e9ecef",
              borderRadius: "6px",
              fontSize: "1rem",
              background: "#f8f9fa",
              color: "var(--text-light)",
              cursor: "not-allowed",
              minHeight: "100px",
              resize: "vertical",
            }}
          />
        );
      
      case 'select':
        return (
          <select 
            disabled
            style={{
              width: "100%",
              padding: "0.75rem",
              border: "2px solid #e9ecef",
              borderRadius: "6px",
              fontSize: "1rem",
              background: "#f8f9fa",
              color: "var(--text-light)",
              cursor: "not-allowed",
            }}
          >
            <option>Choose an option</option>
            {field.options?.map((option, index) => (
              <option key={index} value={option}>{option}</option>
            ))}
          </select>
        );
      
      case 'radio':
        return (
          <div style={{ display: "flex", flexDirection: "column", gap: "0.5rem" }}>
            {field.options?.map((option, index) => (
              <label 
                key={index} 
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "0.5rem",
                  cursor: "not-allowed",
                  color: "var(--text-light)",
                }}
              >
                <input 
                  type="radio" 
                  name={field.id} 
                  value={option} 
                  disabled 
                  style={{ cursor: "not-allowed" }}
                />
                {option}
              </label>
            ))}
          </div>
        );
      
      case 'checkbox':
        return (
          <div style={{ display: "flex", flexDirection: "column", gap: "0.5rem" }}>
            {field.options?.map((option, index) => (
              <label 
                key={index} 
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "0.5rem",
                  cursor: "not-allowed",
                  color: "var(--text-light)",
                }}
              >
                <input 
                  type="checkbox" 
                  value={option} 
                  disabled 
                  style={{ cursor: "not-allowed" }}
                />
                {option}
              </label>
            ))}
          </div>
        );
      
      case 'file':
        return (
          <input 
            type="file" 
            disabled 
            style={{
              width: "100%",
              padding: "0.75rem",
              border: "2px solid #e9ecef",
              borderRadius: "6px",
              fontSize: "1rem",
              background: "#f8f9fa",
              color: "var(--text-light)",
              cursor: "not-allowed",
            }}
          />
        );
      
      default:
        return (
          <input 
            type="text" 
            disabled 
            style={{
              width: "100%",
              padding: "0.75rem",
              border: "2px solid #e9ecef",
              borderRadius: "6px",
              fontSize: "1rem",
              background: "#f8f9fa",
              color: "var(--text-light)",
              cursor: "not-allowed",
            }}
          />
        );
    }
  };

  return (
    <div style={{ height: "100%" }}>
      {fields.length === 0 ? (
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            minHeight: "300px",
            textAlign: "center",
            color: "var(--text-light)",
            padding: "2rem",
            border: "2px dashed #e9ecef",
            borderRadius: "8px",
            background: "#f8f9fa",
          }}
        >
          <MdVisibilityOff
            style={{
              fontSize: "3rem",
              color: "var(--border-light)",
              marginBottom: "1rem",
              opacity: 0.5,
            }}
          />
          <h4
            style={{
              margin: "0 0 0.5rem 0",
              color: "var(--text-light)",
              fontSize: "1.1rem",
            }}
          >
            Form Preview
          </h4>
          <p style={{ margin: 0, fontSize: "0.9rem" }}>
            Form preview will appear here as you add fields
          </p>
        </div>
      ) : (
        <div
          style={{
            background: "white",
            border: "2px solid #e9ecef",
            borderRadius: "8px",
            padding: "1.5rem",
            position: "relative",
          }}
        >
          {/* Preview Header */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              marginBottom: "1.5rem",
              paddingBottom: "1rem",
              borderBottom: "2px solid var(--primary-red)",
            }}
          >
            <h4
              style={{
                margin: 0,
                color: "var(--text-dark)",
                fontSize: "1.2rem",
                fontWeight: "600",
              }}
            >
              Registration Form Preview
            </h4>
            <span
              style={{
                background: "var(--secondary-yellow)",
                color: "var(--text-dark)",
                padding: "0.25rem 0.75rem",
                borderRadius: "20px",
                fontSize: "0.8rem",
                fontWeight: "500",
              }}
            >
              Preview Mode
            </span>
          </div>

          {/* Form Fields */}
          <form style={{ display: "flex", flexDirection: "column", gap: "1.5rem" }}>
            {fields.map(field => (
              <div key={field.id} style={{ marginBottom: "0" }}>
                <label
                  style={{
                    display: "block",
                    marginBottom: "0.5rem",
                    fontWeight: "600",
                    color: "var(--text-dark)",
                    fontSize: "1rem",
                  }}
                >
                  {field.label}
                  {field.required && (
                    <span
                      style={{
                        color: "var(--primary-red)",
                        marginLeft: "0.25rem",
                        fontSize: "1.1rem",
                      }}
                    >
                      *
                    </span>
                  )}
                </label>
                {renderField(field)}
              </div>
            ))}
            
            {/* Submit Button */}
            <div
              style={{
                marginTop: "1rem",
                paddingTop: "1.5rem",
                borderTop: "1px solid #e9ecef",
              }}
            >
              <button
                type="button"
                disabled
                style={{
                  padding: "0.75rem 2rem",
                  backgroundColor: "#ccc",
                  color: "white",
                  border: "none",
                  borderRadius: "6px",
                  fontSize: "1rem",
                  fontWeight: "500",
                  cursor: "not-allowed",
                  display: "flex",
                  alignItems: "center",
                  gap: "0.5rem",
                }}
              >
                Submit Registration (Preview)
              </button>
            </div>
          </form>

          {/* Preview Overlay Indicator */}
          <div
            style={{
              position: "absolute",
              top: "0.5rem",
              right: "0.5rem",
              background: "rgba(255, 255, 255, 0.9)",
              border: "1px solid #e9ecef",
              borderRadius: "4px",
              padding: "0.25rem 0.5rem",
              fontSize: "0.7rem",
              color: "var(--text-light)",
              fontWeight: "500",
              textTransform: "uppercase",
              letterSpacing: "0.5px",
            }}
          >
            Preview Only
          </div>
        </div>
      )}

      {/* Field Statistics */}
      {fields.length > 0 && (
        <div
          style={{
            marginTop: "1rem",
            padding: "1rem",
            background: "#f8f9fa",
            borderRadius: "6px",
            border: "1px solid #e9ecef",
          }}
        >
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              flexWrap: "wrap",
              gap: "0.5rem",
            }}
          >
            <div style={{ display: "flex", gap: "1rem", flexWrap: "wrap" }}>
              <span style={{ fontSize: "0.8rem", color: "var(--text-light)" }}>
                <strong>Total Fields:</strong> {fields.length}
              </span>
              <span style={{ fontSize: "0.8rem", color: "var(--text-light)" }}>
                <strong>Required:</strong> {fields.filter(f => f.required).length}
              </span>
              <span style={{ fontSize: "0.8rem", color: "var(--text-light)" }}>
                <strong>Optional:</strong> {fields.filter(f => !f.required).length}
              </span>
            </div>
          </div>
        </div>
      )}

      <style jsx>{`
        @media (max-width: 768px) {
          .form-preview {
            padding: 1rem !important;
          }
          
          .preview-form {
            gap: 1rem !important;
          }
        }
      `}</style>
    </div>
  );
};

export default FormPreview;
