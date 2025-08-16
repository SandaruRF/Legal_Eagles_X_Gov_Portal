import React from 'react';
import { MdArrowBack, MdSave, MdInfo, MdDescription, MdDynamicForm } from 'react-icons/md';

const PreviewAndSave = ({ data, departmentId, department, onPrev, onSave, loading }) => {
  
  const generateFormStructureJSON = () => {
    const formStructure = {
      departmentID: departmentId,
      departmentName: department.name,
      serviceName: data.serviceName,
      formName: data.formName,
      description: data.description,
      category: data.category,
      processingTime: data.processingTime,
      requiredDocuments: data.requiredDocuments,
      formFields: data.formFields.map(field => {
        const baseField = {
          type: field.type,
          label: field.label,
          required: field.required
        };

        // Add placeholder if exists
        if (field.placeholder) {
          baseField.placeholder = field.placeholder;
        }

        // Add field-specific properties based on type
        switch (field.type) {
          case 'text':
            if (field.maxLength) {
              baseField.maxLength = field.maxLength;
            }
            break;
          
          case 'number':
            if (field.min !== undefined) {
              baseField.minValue = field.min;
            }
            if (field.max !== undefined) {
              baseField.maxValue = field.max;
            }
            break;
          
          case 'select':
          case 'radio':
          case 'checkbox':
            if (field.options && Array.isArray(field.options)) {
              baseField.options = field.options;
            }
            break;
          
          default:
            // For other field types (email, tel, date, textarea, file)
            // no additional properties needed
            break;
        }

        return baseField;
      })
    };

    return formStructure;
  };

  const downloadJSONFile = (data, filename) => {
    const jsonString = JSON.stringify(data, null, 2);
    const blob = new Blob([jsonString], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    // Clean up the URL object
    URL.revokeObjectURL(url);
  };

  const handleSaveService = async () => {
    try {
      // Generate the form structure JSON
      const formStructureJSON = generateFormStructureJSON();
      
      // Make API call to save the service
      const response = await fetch('http://localhost:8000/api/admin/services', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formStructureJSON)
      });

      if (!response.ok) {
        throw new Error('Failed to save service');
      }

      const result = await response.json();
      console.log('Service saved successfully:', result);
      
      // Call the original onSave function if provided
      if (onSave) {
        onSave();
      }
      
    } catch (error) {
      console.error('Error saving form structure:', error);
      // You might want to show an error message to the user here
      throw error;
    }
  };

  return (
    <div>
      {/* Header Section */}
      <div
          style={{
            borderBottom: "2px solid var(--primary-red)",
            paddingBottom: "1rem",
            marginBottom: "2rem",
            margin: "1.5rem",
            paddingTop: "1.5rem",
            paddingBottom: "1.5rem",
          }}
        >
          <h3
            style={{
              color: "var(--primary-red)",
              margin: 0,
              fontSize: "1.5rem",
              fontWeight: "600",
            }}
          >
            Service Preview & Summary
          </h3>
        </div>

      {/* Compact Summary Cards */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "2fr 1fr",
          gap: "1.5rem",
          marginBottom: "1.5rem",
        }}
      >
        {/* Service Details Card */}
        <div
          style={{
            background: "white",
            padding: "1.5rem",
            borderRadius: "8px",
            boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "0.5rem",
              marginBottom: "1rem",
              paddingBottom: "0.75rem",
              borderBottom: "2px solid var(--primary-red)",
            }}
          >
            <h4
              style={{
                color: "var(--text-dark)",
                margin: 0,
                fontSize: "1.2rem",
                fontWeight: "600",
              }}
            >
              Service Details
            </h4>
          </div>

          <div style={{ display: "grid", gap: "0.75rem" }}>
            <div style={{ display: "flex", flexDirection: "column" }}>
              <span style={{ fontSize: "0.85rem", color: "var(--text-light)", fontWeight: "500" }}>
                Service Name
              </span>
              <span style={{ fontSize: "1rem", color: "var(--text-dark)", fontWeight: "600" }}>
                {data.serviceName}
              </span>
            </div>

            <div style={{ display: "flex", flexDirection: "column" }}>
              <span style={{ fontSize: "0.85rem", color: "var(--text-light)", fontWeight: "500" }}>
                Description
              </span>
              <span style={{ fontSize: "0.9rem", color: "var(--text-dark)", lineHeight: "1.4" }}>
                {data.description}
              </span>
            </div>

            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "0.75rem" }}>
              {data.category && (
                <div>
                  <span style={{ fontSize: "0.85rem", color: "var(--text-light)", fontWeight: "500" }}>
                    Category
                  </span>
                  <div style={{ fontSize: "0.9rem", color: "var(--text-dark)" }}>
                    {data.category}
                  </div>
                </div>
              )}
            </div>
            <div style={{ display: "flex", flexDirection: "column" }}>
              <span style={{ fontSize: "0.85rem", color: "var(--text-light)", fontWeight: "500" }}>
                Form Name
              </span>
              <span style={{ fontSize: "0.9rem", color: "var(--text-dark)", lineHeight: "1.4" }}>
                {data.formName}
              </span>
            </div>
          </div>
        </div>

        {/* Quick Stats Card */}
        <div
          style={{
            background: "white",
            padding: "1.5rem",
            borderRadius: "8px",
            boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
          }}
        >
          <h4
            style={{
              color: "var(--text-dark)",
              margin: "0 0 1rem 0",
              fontSize: "1.2rem",
              fontWeight: "600",
              paddingBottom: "0.75rem",
              borderBottom: "2px solid var(--primary-red)",
            }}
          >
            Quick Stats
          </h4>

          <div style={{ display: "grid", gap: "1rem" }}>
            <div style={{ textAlign: "center" }}>
              <div
                style={{
                  fontSize: "2rem",
                  fontWeight: "700",
                  color: "var(--primary-red)",
                  lineHeight: "1",
                }}
              >
                {data.formFields.length}
              </div>
              <div style={{ fontSize: "0.85rem", color: "var(--text-light)" }}>
                Form Fields
              </div>
            </div>

            <div style={{ textAlign: "center" }}>
              <div
                style={{
                  fontSize: "2rem",
                  fontWeight: "700",
                  color: "var(--accent-green)",
                  lineHeight: "1",
                }}
              >
                {data.formFields.filter(f => f.required).length}
              </div>
              <div style={{ fontSize: "0.85rem", color: "var(--text-light)" }}>
                Required Fields
              </div>
            </div>

            <div style={{ textAlign: "center" }}>
              <div
                style={{
                  fontSize: "2rem",
                  fontWeight: "700",
                  color: "var(--secondary-yellow)",
                  lineHeight: "1",
                }}
              >
                {data.requiredDocuments.length}
              </div>
              <div style={{ fontSize: "0.85rem", color: "var(--text-light)" }}>
                Documents
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Compact Sections */}
      <div style={{ display: "grid", gap: "1rem", marginBottom: "1.5rem" }}>
        {/* Required Documents - Compact */}
        {data.requiredDocuments.length > 0 && (
          <div
            style={{
              background: "white",
              padding: "1.5rem",
              borderRadius: "6px",
              boxShadow: "0 1px 3px rgba(0, 0, 0, 0.1)",
            }}
          >
            <div style={{
                borderBottom: "2px solid var(--primary-red)",
                 display: "flex", 
                 alignItems: "center", 
                 gap: "0.5rem", 
                 marginBottom: "0.75rem" ,
                 paddingBottom: "0.75rem",
                 }}>
              <span
                style={{
                  fontSize: "1.2rem",
                  fontWeight: "600",
                  color: "var(--text-dark)",
                }}
              >
                Required Documents ({data.requiredDocuments.length})
              </span>
            </div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: "0.5rem" }}>
              {data.requiredDocuments.map((doc, index) => (
                <span
                  key={index}
                  style={{
                    background: "#f8f9fa",
                    color: "var(--text-dark)",
                    padding: "0.25rem 0.75rem",
                    borderRadius: "20px",
                    fontSize: "0.85rem",
                    border: "1px solid #e9ecef",
                  }}
                >
                  {doc}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Form Fields - Compact */}
        {data.formFields.length > 0 && (
          <div
            style={{
              background: "white",
              padding: "1.5rem",
              borderRadius: "6px",
              boxShadow: "0 1px 3px rgba(0, 0, 0, 0.1)",
            }}
          >
            <div
              style={{
                borderBottom: "2px solid var(--primary-red)",
                display: "flex",
                alignItems: "center",
                gap: "0.5rem",
                marginBottom: "0.75rem",
                paddingBottom: "0.75rem", 
              }}
            >
              <span
                style={{
                  fontSize: "1.2rem",
                  fontWeight: "600",
                  color: "var(--text-dark)",
                }}
              >
                Form Fields ({data.formFields.length})
              </span>
            </div>
            <div style={{ display: "grid", gap: "0.5rem" }}>
              {data.formFields.map((field, index) => (
                <div
                  key={index}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: "0.75rem",
                    padding: "0.5rem",
                    background: "#f8f9fa",
                    borderRadius: "4px",
                    border: "1px solid #e9ecef",
                  }}
                >
                  <span
                    style={{
                      fontSize: "0.9rem",
                      fontWeight: "500",
                      color: "var(--text-dark)",
                      flex: 1,
                    }}
                  >
                    {field.label}
                  </span>
                  <span
                    style={{
                      background: "var(--accent-green)",
                      color: "white",
                      padding: "0.2rem 0.5rem",
                      borderRadius: "3px",
                      fontSize: "0.7rem",
                      fontWeight: "600",
                      textTransform: "uppercase",
                    }}
                  >
                    {field.type}
                  </span>
                  {field.required && (
                    <span
                      style={{
                        background: "var(--primary-red)",
                        color: "white",
                        padding: "0.2rem 0.4rem",
                        borderRadius: "3px",
                        fontSize: "0.7rem",
                        fontWeight: "500",
                      }}
                    >
                      Required
                    </span>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Action Buttons */}
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          padding: "1.5rem",
          background: "white",
          borderRadius: "8px",
          boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
        }}
      >
        <button 
          type="button" 
          onClick={onPrev}
          disabled={loading}
          style={{
            padding: "0.75rem 1.5rem",
            backgroundColor: "#6c757d",
            color: "white",
            border: "none",
            borderRadius: "6px",
            fontSize: "1rem",
            fontWeight: "500",
            cursor: loading ? "not-allowed" : "pointer",
            transition: "all 0.2s ease",
            display: "flex",
            alignItems: "center",
            gap: "0.5rem",
            opacity: loading ? 0.6 : 1,
          }}
          onMouseOver={(e) => {
            if (!loading) {
              e.target.style.backgroundColor = "#545b62";
              e.target.style.transform = "translateY(-1px)";
            }
          }}
          onMouseOut={(e) => {
            if (!loading) {
              e.target.style.backgroundColor = "#6c757d";
              e.target.style.transform = "translateY(0)";
            }
          }}
        >
          <MdArrowBack />
          Back
        </button>
        
        <button 
          type="button" 
          onClick={handleSaveService}
          disabled={loading}
          style={{
            padding: "0.75rem 2rem",
            backgroundColor: loading ? "#ccc" : "var(--accent-green)",
            color: "white",
            border: "none",
            borderRadius: "6px",
            fontSize: "1rem",
            fontWeight: "500",
            cursor: loading ? "not-allowed" : "pointer",
            transition: "all 0.2s ease",
            display: "flex",
            alignItems: "center",
            gap: "0.5rem",
          }}
          onMouseOver={(e) => {
            if (!loading) {
              e.target.style.backgroundColor = "#3d564d";
              e.target.style.transform = "translateY(-1px)";
            }
          }}
          onMouseOut={(e) => {
            if (!loading) {
              e.target.style.backgroundColor = "var(--accent-green)";
              e.target.style.transform = "translateY(0)";
            }
          }}
        >
          <MdSave />
          {loading ? "Saving..." : "Save Service"}
        </button>
      </div>

      <style jsx>{`
        @media (max-width: 768px) {
          .preview-grid {
            grid-template-columns: 1fr !important;
          }
          
          .preview-actions {
            flex-direction: column !important;
            gap: 1rem !important;
          }

          .preview-actions button {
            width: 100% !important;
            justify-content: center !important;
          }
        }
      `}</style>
    </div>
  );
};

export default PreviewAndSave;
