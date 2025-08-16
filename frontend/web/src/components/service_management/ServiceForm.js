import React, { useState } from 'react';

const ServiceForm = ({ data, onUpdate, onNext }) => {
  const [documents, setDocuments] = useState(
    data.requiredDocuments.length ? data.requiredDocuments : ['']
  );

  const addDocument = () => {
    setDocuments([...documents, '']);
  };

  const updateDocument = (index, value) => {
    const updated = [...documents];
    updated[index] = value;
    setDocuments(updated);
    onUpdate({ ...data, requiredDocuments: updated.filter(doc => doc.trim()) });
  };

  const removeDocument = (index) => {
    const updated = documents.filter((_, i) => i !== index);
    setDocuments(updated);
    onUpdate({ ...data, requiredDocuments: updated });
  };

  return (
    <div>
      {/* Service Information Section */}
      <div
        style={{
          background: "white",
          padding: "2rem",
          borderRadius: "8px",
          boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
          marginBottom: "2rem",
        }}
      >
        <div
          style={{
            borderBottom: "2px solid var(--primary-red)",
            paddingBottom: "1rem",
            marginBottom: "2rem",
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
            Service Information
          </h3>
        </div>
        
        <div className="form-grid">
          <div className="form-group">
            <label>Service Name *</label>
            <input
              type="text"
              className="form-input"
              value={data.serviceName || ''}
              onChange={(e) => onUpdate({ ...data, serviceName: e.target.value })}
              placeholder="Enter service name"
              style={{
                width: "100%",
                padding: "0.75rem",
                border: "2px solid #e9ecef",
                borderRadius: "6px",
                fontSize: "1rem",
                transition: "all 0.2s ease",
                background: "white",
              }}
            />
          </div>

          <div className="form-group">
            <label>Service Category</label>
            <select
              className="form-input"
              value={data.category || ''}
              onChange={(e) => onUpdate({ ...data, category: e.target.value })}
              style={{
                width: "100%",
                padding: "0.75rem",
                border: "2px solid #e9ecef",
                borderRadius: "6px",
                fontSize: "1rem",
                transition: "all 0.2s ease",
                background: "white",
              }}
            >
              <option value="">Select a category</option>
              <option value="registration">Registration Services</option>
              <option value="licensing">Licensing & Permits</option>
              <option value="certificates">Certificates</option>
              <option value="applications">Applications</option>
              <option value="other">Other</option>
            </select>
          </div>
        </div>

        <div className="form-group">
          <label>Service Description *</label>
          <textarea
            className="form-input"
            rows="4"
            value={data.description}
            onChange={(e) => onUpdate({ ...data, description: e.target.value })}
            placeholder="Describe the service and its purpose"
            style={{
              width: "100%",
              padding: "0.75rem",
              border: "2px solid #e9ecef",
              borderRadius: "6px",
              fontSize: "1rem",
              transition: "all 0.2s ease",
              background: "white",
              minHeight: "120px",
              resize: "vertical",
            }}
          />
        </div>

        <div className="form-group">
          <label>Form Name *</label>
          <input
            type="text"
            className="form-input"
            value={data.formName || ''}
            onChange={(e) => onUpdate({ ...data, formName: e.target.value })}
            placeholder="Enter form name"
            style={{
              width: "100%",
              padding: "0.75rem",
              border: "2px solid #e9ecef",
              borderRadius: "6px",
              fontSize: "1rem",
              transition: "all 0.2s ease",
              background: "white",
            }}
          />
        </div>
      </div>

      {/* Required Documents Section */}
      <div
        style={{
          background: "white",
          padding: "2rem",
          borderRadius: "8px",
          boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
          marginBottom: "2rem",
        }}
      >
        <div
          style={{
            borderBottom: "2px solid var(--primary-red)",
            paddingBottom: "1rem",
            marginBottom: "2rem",
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
            Required Documents
          </h3>
        </div>

        <div className="form-group">
          {documents.map((doc, index) => (
            <div 
              key={index} 
              style={{
                display: "flex",
                gap: "0.5rem",
                marginBottom: "1rem",
                alignItems: "center",
              }}
            >
              <input
                type="text"
                className="form-input"
                value={doc}
                onChange={(e) => updateDocument(index, e.target.value)}
                placeholder="Enter required document (e.g., National Identity Card copy)"
                style={{
                  flex: "1",
                  padding: "0.75rem",
                  border: "2px solid #e9ecef",
                  borderRadius: "6px",
                  fontSize: "1rem",
                  transition: "all 0.2s ease",
                  background: "white",
                }}
              />
              <button 
                type="button" 
                className="btn"
                onClick={() => removeDocument(index)}
                style={{
                  padding: "0.75rem 1rem",
                  backgroundColor: "var(--primary-red)",
                  color: "white",
                  border: "none",
                  borderRadius: "6px",
                  cursor: "pointer",
                  fontSize: "0.9rem",
                  fontWeight: "500",
                  transition: "all 0.2s ease",
                }}
                onMouseOver={(e) => {
                  e.target.style.backgroundColor = "#6b1a21";
                  e.target.style.transform = "translateY(-1px)";
                }}
                onMouseOut={(e) => {
                  e.target.style.backgroundColor = "var(--primary-red)";
                  e.target.style.transform = "translateY(0)";
                }}
              >
                Remove
              </button>
            </div>
          ))}
          
          <button 
            type="button" 
            className="btn btn-outline"
            onClick={addDocument}
            style={{
              display: "flex",
              alignItems: "center",
              gap: "0.5rem",
              padding: "0.75rem 1.5rem",
              backgroundColor: "white",
              color: "var(--accent-green)",
              border: "2px solid var(--accent-green)",
              borderRadius: "6px",
              cursor: "pointer",
              fontSize: "1rem",
              fontWeight: "500",
              transition: "all 0.2s ease",
            }}
            onMouseOver={(e) => {
              e.target.style.backgroundColor = "var(--accent-green)";
              e.target.style.color = "white";
              e.target.style.transform = "translateY(-1px)";
            }}
            onMouseOut={(e) => {
              e.target.style.backgroundColor = "white";
              e.target.style.color = "var(--accent-green)";
              e.target.style.transform = "translateY(0)";
            }}
          >
            <span style={{ fontSize: "1.2rem" }}>+</span>
            Add Document
          </button>
        </div>
      </div>

      {/* Form Actions */}
      <div
        style={{
          display: "flex",
          justifyContent: "flex-end",
          padding: "1.5rem",
          background: "white",
          borderRadius: "8px",
          boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
        }}
      >
        <button 
          className="btn btn-primary"
          onClick={onNext}
          disabled={!data.serviceName || !data.description || !data.formName}
          style={{
            padding: "0.75rem 2rem",
            backgroundColor: !data.serviceName || !data.description || !data.formName ? "#ccc" : "var(--accent-green)",
            color: "white",
            border: "none",
            borderRadius: "6px",
            fontSize: "1rem",
            fontWeight: "500",
            cursor: !data.serviceName || !data.description || !data.formName ? "not-allowed" : "pointer",
            transition: "all 0.2s ease",
            display: "flex",
            alignItems: "center",
            gap: "0.5rem",
          }}
          onMouseOver={(e) => {
            const isFormValid = data.formName && data.description && data.serviceName;
            if (isFormValid) {
              e.target.style.backgroundColor = "#3d564d";
              e.target.style.transform = "translateY(-1px)";
              e.target.style.boxShadow = "0 4px 8px rgba(0, 0, 0, 0.15)";
            }
          }}
          onMouseOut={(e) => {
            const isFormValid = data.formName && data.description && data.serviceName;
            if (isFormValid) {
              e.target.style.backgroundColor = "var(--accent-green)";
              e.target.style.transform = "translateY(0)";
              e.target.style.boxShadow = "none";
            }
          }}
        >
          Next: Build Form
          <span style={{ fontSize: "1.2rem" }}>→</span>
        </button>
      </div>

      <style jsx>{`
        .form-group {
          margin-bottom: 1.5rem;
        }

        .form-group label {
          display: block;
          margin-bottom: 0.5rem;
          font-weight: 600;
          color: var(--text-dark);
          font-size: 1rem;
        }

        .form-input:focus {
          border-color: var(--accent-green) !important;
          box-shadow: 0 0 0 3px rgba(78, 110, 99, 0.1) !important;
          outline: none !important;
        }

        .form-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 1.5rem;
          margin-bottom: 1.5rem;
        }

        @media (max-width: 768px) {
          .form-grid {
            grid-template-columns: 1fr;
            gap: 1rem;
          }
        }
      `}</style>
    </div>
  );
};

export default ServiceForm;
