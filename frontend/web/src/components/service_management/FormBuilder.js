import React, { useState } from 'react';
import { MdEdit, MdDelete, MdArrowUpward, MdArrowDownward, MdAdd } from 'react-icons/md';
import FieldEditor from './FieldEditor';
import FormPreview from './FormPreview';

const FormBuilder = ({ data, onUpdate, onNext, onPrev }) => {
  const [selectedField, setSelectedField] = useState(null);
  const [showFieldEditor, setShowFieldEditor] = useState(false);

  const fieldTypes = [
    { type: 'text', label: 'Text Input', icon: '📝', color: '#007bff' },
    { type: 'email', label: 'Email', icon: '📧', color: '#28a745' },
    { type: 'tel', label: 'Phone Number', icon: '📞', color: '#ffc107' },
    { type: 'number', label: 'Number', icon: '#️⃣', color: '#17a2b8' },
    { type: 'date', label: 'Date', icon: '📅', color: '#6f42c1' },
    { type: 'select', label: 'Dropdown', icon: '🔽', color: '#fd7e14' },
    { type: 'radio', label: 'Radio Buttons', icon: '🔘', color: '#e83e8c' },
    { type: 'checkbox', label: 'Checkboxes', icon: '☑️', color: '#20c997' },
    { type: 'textarea', label: 'Text Area', icon: '📄', color: '#6c757d' },
    { type: 'file', label: 'File Upload', icon: '📎', color: '#dc3545' }
  ];

  const addField = (fieldType) => {
    const newField = {
      id: Date.now(),
      type: fieldType,
      label: `New ${fieldType} field`,
      required: false,
      placeholder: '',
      options: fieldType === 'select' || fieldType === 'radio' || fieldType === 'checkbox' ? ['Option 1'] : null
    };

    onUpdate({
      ...data,
      formFields: [...data.formFields, newField]
    });
  };

  const updateField = (fieldId, updatedField) => {
    const updatedFields = data.formFields.map(field => 
      field.id === fieldId ? updatedField : field
    );
    onUpdate({ ...data, formFields: updatedFields });
  };

  const deleteField = (fieldId) => {
    const updatedFields = data.formFields.filter(field => field.id !== fieldId);
    onUpdate({ ...data, formFields: updatedFields });
  };

  const moveField = (fieldId, direction) => {
    const fields = [...data.formFields];
    const currentIndex = fields.findIndex(f => f.id === fieldId);
    const newIndex = direction === 'up' ? currentIndex - 1 : currentIndex + 1;
    
    if (newIndex >= 0 && newIndex < fields.length) {
      [fields[currentIndex], fields[newIndex]] = [fields[newIndex], fields[currentIndex]];
      onUpdate({ ...data, formFields: fields });
    }
  };

  return (
    <div>
      {/* Form Builder Header */}
      <div
        style={{
          background: "white",
          padding: "1.5rem",
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
            Registration Form Builder
          </h3>
        </div>

        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            flexWrap: "wrap",
            gap: "1rem",
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "0.5rem",
            }}
          >
            <span
              style={{
                background: "var(--accent-green)",
                color: "white",
                padding: "0.25rem 0.75rem",
                borderRadius: "20px",
                fontSize: "0.8rem",
                fontWeight: "500",
              }}
            >
              {data.formFields.length} Fields Added
            </span>
          </div>
        </div>
      </div>

      {/* Main Form Builder Layout */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "280px 1fr 320px",
          gap: "1.5rem",
          minHeight: "600px",
        }}
      >
        {/* Field Types Palette */}
        <div
          style={{
            background: "white",
            padding: "1.5rem",
            borderRadius: "8px",
            boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
            height: "fit-content",
          }}
        >
          <h4
            style={{
              color: "var(--text-dark)",
              margin: "0 0 1rem 0",
              fontSize: "1.2rem",
              fontWeight: "600",
              borderBottom: "2px solid var(--primary-red)",
              paddingBottom: "0.5rem",
            }}
          >
            Form Fields
          </h4>
          
          <div
            style={{
              display: "grid",
              gap: "0.75rem",
            }}
          >
            {fieldTypes.map(field => (
              <div 
                key={field.type}
                onClick={() => addField(field.type)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "0.75rem",
                  padding: "0.75rem",
                  border: `2px solid ${field.color}20`,
                  borderRadius: "6px",
                  cursor: "pointer",
                  transition: "all 0.2s ease",
                  backgroundColor: "white",
                }}
                onMouseOver={(e) => {
                  e.currentTarget.style.borderColor = field.color;
                  e.currentTarget.style.backgroundColor = `${field.color}10`;
                  e.currentTarget.style.transform = "translateY(-1px)";
                }}
                onMouseOut={(e) => {
                  e.currentTarget.style.borderColor = `${field.color}20`;
                  e.currentTarget.style.backgroundColor = "white";
                  e.currentTarget.style.transform = "translateY(0)";
                }}
              >
                <span style={{ fontSize: "1.2rem" }}>{field.icon}</span>
                <span
                  style={{
                    fontSize: "0.9rem",
                    fontWeight: "500",
                    color: "var(--text-dark)",
                  }}
                >
                  {field.label}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Form Builder Area */}
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
              borderBottom: "1px solid var(--border-light)",
              paddingBottom: "1rem",
              marginBottom: "1.5rem",
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
              Form Structure
            </h4>
          </div>

          <div
            style={{
              minHeight: "400px",
            }}
          >
            {data.formFields.length === 0 ? (
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
                }}
              >
                <MdAdd
                  style={{
                    fontSize: "3rem",
                    color: "var(--border-light)",
                    marginBottom: "1rem",
                  }}
                />
                <h4
                  style={{
                    margin: "0 0 0.5rem 0",
                    color: "var(--text-light)",
                  }}
                >
                  No fields added yet
                </h4>
                <p style={{ margin: 0 }}>
                  Select field types from the left panel to start building your form
                </p>
              </div>
            ) : (
              <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
                {data.formFields.map((field, index) => (
                  <div 
                    key={field.id}
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                      padding: "1rem",
                      border: "1px solid var(--border-light)",
                      borderRadius: "6px",
                      backgroundColor: "white",
                      transition: "all 0.2s ease",
                    }}
                    onMouseOver={(e) => {
                      e.currentTarget.style.borderColor = "var(--accent-green)";
                      e.currentTarget.style.boxShadow = "0 2px 8px rgba(0, 0, 0, 0.1)";
                    }}
                    onMouseOut={(e) => {
                      e.currentTarget.style.borderColor = "var(--border-light)";
                      e.currentTarget.style.boxShadow = "none";
                    }}
                  >
                    <div style={{ display: "flex", alignItems: "center", gap: "0.75rem" }}>
                      <span
                        style={{
                          background: "var(--accent-green)",
                          color: "white",
                          padding: "0.25rem 0.5rem",
                          borderRadius: "4px",
                          fontSize: "0.75rem",
                          fontWeight: "600",
                          textTransform: "uppercase",
                        }}
                      >
                        {field.type}
                      </span>
                      <span
                        style={{
                          fontWeight: "500",
                          color: "var(--text-dark)",
                        }}
                      >
                        {field.label}
                      </span>
                      {field.required && (
                        <span
                          style={{
                            background: "var(--primary-red)",
                            color: "white",
                            padding: "0.2rem 0.4rem",
                            borderRadius: "4px",
                            fontSize: "0.7rem",
                            fontWeight: "500",
                          }}
                        >
                          Required
                        </span>
                      )}
                    </div>
                    
                    <div style={{ display: "flex", gap: "0.25rem" }}>
                      <button 
                        onClick={() => {
                          setSelectedField(field);
                          setShowFieldEditor(true);
                        }}
                        style={{
                          padding: "0.5rem",
                          border: "1px solid var(--accent-green)",
                          borderRadius: "4px",
                          fontSize: "0.8rem",
                          background: "white",
                          color: "var(--accent-green)",
                          cursor: "pointer",
                          transition: "all 0.2s",
                          display: "flex",
                          alignItems: "center",
                        }}
                        onMouseOver={(e) => {
                          e.target.style.background = "var(--accent-green)";
                          e.target.style.color = "white";
                        }}
                        onMouseOut={(e) => {
                          e.target.style.background = "white";
                          e.target.style.color = "var(--accent-green)";
                        }}
                      >
                        <MdEdit />
                      </button>
                      
                      <button 
                        onClick={() => moveField(field.id, 'up')}
                        disabled={index === 0}
                        style={{
                          padding: "0.5rem",
                          border: "1px solid #6c757d",
                          borderRadius: "4px",
                          fontSize: "0.8rem",
                          background: "white",
                          color: "#6c757d",
                          cursor: index === 0 ? "not-allowed" : "pointer",
                          transition: "all 0.2s",
                          opacity: index === 0 ? 0.5 : 1,
                          display: "flex",
                          alignItems: "center",
                        }}
                        onMouseOver={(e) => {
                          if (index !== 0) {
                            e.target.style.background = "#6c757d";
                            e.target.style.color = "white";
                          }
                        }}
                        onMouseOut={(e) => {
                          if (index !== 0) {
                            e.target.style.background = "white";
                            e.target.style.color = "#6c757d";
                          }
                        }}
                      >
                        <MdArrowUpward />
                      </button>
                      
                      <button 
                        onClick={() => moveField(field.id, 'down')}
                        disabled={index === data.formFields.length - 1}
                        style={{
                          padding: "0.5rem",
                          border: "1px solid #6c757d",
                          borderRadius: "4px",
                          fontSize: "0.8rem",
                          background: "white",
                          color: "#6c757d",
                          cursor: index === data.formFields.length - 1 ? "not-allowed" : "pointer",
                          transition: "all 0.2s",
                          opacity: index === data.formFields.length - 1 ? 0.5 : 1,
                          display: "flex",
                          alignItems: "center",
                        }}
                        onMouseOver={(e) => {
                          if (index !== data.formFields.length - 1) {
                            e.target.style.background = "#6c757d";
                            e.target.style.color = "white";
                          }
                        }}
                        onMouseOut={(e) => {
                          if (index !== data.formFields.length - 1) {
                            e.target.style.background = "white";
                            e.target.style.color = "#6c757d";
                          }
                        }}
                      >
                        <MdArrowDownward />
                      </button>
                      
                      <button 
                        onClick={() => deleteField(field.id)}
                        style={{
                          padding: "0.5rem",
                          border: "1px solid var(--primary-red)",
                          borderRadius: "4px",
                          fontSize: "0.8rem",
                          background: "white",
                          color: "var(--primary-red)",
                          cursor: "pointer",
                          transition: "all 0.2s",
                          display: "flex",
                          alignItems: "center",
                        }}
                        onMouseOver={(e) => {
                          e.target.style.background = "var(--primary-red)";
                          e.target.style.color = "white";
                        }}
                        onMouseOut={(e) => {
                          e.target.style.background = "white";
                          e.target.style.color = "var(--primary-red)";
                        }}
                      >
                        <MdDelete />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Live Preview */}
        <div
          style={{
            background: "white",
            padding: "1.5rem",
            borderRadius: "8px",
            boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
            height: "fit-content",
            maxHeight: "600px",
            overflowY: "auto",
          }}
        >
          <h4
            style={{
              color: "var(--text-dark)",
              margin: "0 0 1rem 0",
              fontSize: "1.2rem",
              fontWeight: "600",
              borderBottom: "2px solid var(--primary-red)",
              paddingBottom: "0.5rem",
            }}
          >
            Live Preview
          </h4>
          <FormPreview fields={data.formFields} />
        </div>
      </div>

      {/* Field Editor Modal */}
      {showFieldEditor && selectedField && (
        <FieldEditor
          field={selectedField}
          onSave={(updatedField) => {
            updateField(selectedField.id, updatedField);
            setShowFieldEditor(false);
            setSelectedField(null);
          }}
          onCancel={() => {
            setShowFieldEditor(false);
            setSelectedField(null);
          }}
        />
      )}

      {/* Form Actions */}
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          padding: "1.5rem",
          background: "white",
          borderRadius: "8px",
          boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
          marginTop: "2rem",
        }}
      >
        <button 
          onClick={onPrev}
          style={{
            padding: "0.75rem 2rem",
            backgroundColor: "#6c757d",
            color: "white",
            border: "none",
            borderRadius: "6px",
            fontSize: "1rem",
            fontWeight: "500",
            cursor: "pointer",
            transition: "all 0.2s ease",
            display: "flex",
            alignItems: "center",
            gap: "0.5rem",
          }}
          onMouseOver={(e) => {
            e.target.style.backgroundColor = "#545b62";
            e.target.style.transform = "translateY(-1px)";
            e.target.style.boxShadow = "0 4px 8px rgba(0, 0, 0, 0.15)";
          }}
          onMouseOut={(e) => {
            e.target.style.backgroundColor = "#6c757d";
            e.target.style.transform = "translateY(0)";
            e.target.style.boxShadow = "none";
          }}
        >
          <span style={{ fontSize: "1.2rem" }}>←</span>
          Previous: Service Details
        </button>
        
        <button 
          onClick={onNext}
          disabled={data.formFields.length === 0}
          style={{
            padding: "0.75rem 2rem",
            backgroundColor: data.formFields.length === 0 ? "#ccc" : "var(--accent-green)",
            color: "white",
            border: "none",
            borderRadius: "6px",
            fontSize: "1rem",
            fontWeight: "500",
            cursor: data.formFields.length === 0 ? "not-allowed" : "pointer",
            transition: "all 0.2s ease",
            display: "flex",
            alignItems: "center",
            gap: "0.5rem",
          }}
          onMouseOver={(e) => {
            if (data.formFields.length > 0) {
              e.target.style.backgroundColor = "#3d564d";
              e.target.style.transform = "translateY(-1px)";
              e.target.style.boxShadow = "0 4px 8px rgba(0, 0, 0, 0.15)";
            }
          }}
          onMouseOut={(e) => {
            if (data.formFields.length > 0) {
              e.target.style.backgroundColor = "var(--accent-green)";
              e.target.style.transform = "translateY(0)";
              e.target.style.boxShadow = "none";
            }
          }}
        >
          Next: Preview & Save
          <span style={{ fontSize: "1.2rem" }}>→</span>
        </button>
      </div>

      <style jsx>{`
        @media (max-width: 1200px) {
          .form-builder-layout {
            grid-template-columns: 1fr !important;
            gap: 1rem !important;
          }
        }

        @media (max-width: 768px) {
          .field-types-grid {
            grid-template-columns: 1fr !important;
          }
          
          .form-actions {
            flex-direction: column !important;
            gap: 1rem !important;
          }

          .form-actions button {
            width: 100% !important;
            justify-content: center !important;
          }
        }
      `}</style>
    </div>
  );
};

export default FormBuilder;
