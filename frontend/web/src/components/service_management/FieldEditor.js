import React, { useState } from 'react';
import { MdEdit, MdClose, MdAdd, MdDelete } from 'react-icons/md';

const FieldEditor = ({ field, onSave, onCancel }) => {
  const [editedField, setEditedField] = useState({ ...field });

  const handleOptionChange = (index, value) => {
    const newOptions = [...editedField.options];
    newOptions[index] = value;
    setEditedField({ ...editedField, options: newOptions });
  };

  const addOption = () => {
    setEditedField({
      ...editedField,
      options: [...(editedField.options || []), `Option ${editedField.options.length + 1}`]
    });
  };

  const removeOption = (index) => {
    const newOptions = editedField.options.filter((_, i) => i !== index);
    setEditedField({ ...editedField, options: newOptions });
  };

  return (
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
          maxWidth: "600px",
          width: "90%",
          maxHeight: "90vh",
          overflow: "hidden",
          boxShadow: "0 10px 30px rgba(0, 0, 0, 0.3)",
        }}
      >
        {/* Modal Header */}
        <div
          style={{
            background: "var(--primary-red)",
            color: "white",
            padding: "1.5rem",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <h3
            style={{
              margin: 0,
              fontSize: "1.25rem",
              fontWeight: "600",
              display: "flex",
              alignItems: "center",
              gap: "0.5rem",
            }}
          >
            <MdEdit />
            Edit {editedField.type} Field
          </h3>
          <button
            onClick={onCancel}
            style={{
              background: "none",
              border: "none",
              color: "white",
              fontSize: "1.5rem",
              cursor: "pointer",
              padding: "0.25rem",
              borderRadius: "4px",
              transition: "background-color 0.2s",
            }}
            onMouseOver={(e) => {
              e.target.style.backgroundColor = "rgba(255, 255, 255, 0.1)";
            }}
            onMouseOut={(e) => {
              e.target.style.backgroundColor = "transparent";
            }}
          >
            <MdClose />
          </button>
        </div>

        {/* Modal Body */}
        <div
          style={{
            padding: "2rem",
            maxHeight: "60vh",
            overflowY: "auto",
          }}
        >
          {/* Field Label */}
          <div style={{ marginBottom: "1.5rem" }}>
            <label
              style={{
                display: "block",
                marginBottom: "0.5rem",
                fontWeight: "600",
                color: "var(--text-dark)",
                fontSize: "1rem",
              }}
            >
              Field Label *
            </label>
            <input
              type="text"
              value={editedField.label}
              onChange={(e) => setEditedField({ ...editedField, label: e.target.value })}
              style={{
                width: "100%",
                padding: "0.75rem",
                border: "2px solid #e9ecef",
                borderRadius: "6px",
                fontSize: "1rem",
                transition: "all 0.2s ease",
                background: "white",
              }}
              onFocus={(e) => {
                e.target.style.borderColor = "var(--primary-red)";
                e.target.style.boxShadow = "0 0 0 3px rgba(139, 21, 56, 0.1)";
              }}
              onBlur={(e) => {
                e.target.style.borderColor = "#e9ecef";
                e.target.style.boxShadow = "none";
              }}
            />
          </div>

          {/* Placeholder Text */}
          <div style={{ marginBottom: "1.5rem" }}>
            <label
              style={{
                display: "block",
                marginBottom: "0.5rem",
                fontWeight: "600",
                color: "var(--text-dark)",
                fontSize: "1rem",
              }}
            >
              Placeholder Text
            </label>
            <input
              type="text"
              value={editedField.placeholder || ''}
              onChange={(e) => setEditedField({ ...editedField, placeholder: e.target.value })}
              placeholder="Enter placeholder text"
              style={{
                width: "100%",
                padding: "0.75rem",
                border: "2px solid #e9ecef",
                borderRadius: "6px",
                fontSize: "1rem",
                transition: "all 0.2s ease",
                background: "white",
              }}
              onFocus={(e) => {
                e.target.style.borderColor = "var(--primary-red)";
                e.target.style.boxShadow = "0 0 0 3px rgba(139, 21, 56, 0.1)";
              }}
              onBlur={(e) => {
                e.target.style.borderColor = "#e9ecef";
                e.target.style.boxShadow = "none";
              }}
            />
          </div>

          {/* Required Field Checkbox */}
          <div style={{ marginBottom: "1.5rem" }}>
            <label
              style={{
                display: "flex",
                alignItems: "center",
                gap: "0.5rem",
                cursor: "pointer",
                fontWeight: "600",
                color: "var(--text-dark)",
              }}
            >
              <input
                type="checkbox"
                checked={editedField.required}
                onChange={(e) => setEditedField({ ...editedField, required: e.target.checked })}
                style={{ cursor: "pointer" }}
              />
              Required Field
            </label>
          </div>

          {/* Options for select, radio, checkbox fields */}
          {(editedField.type === 'select' || editedField.type === 'radio' || editedField.type === 'checkbox') && (
            <div style={{ marginBottom: "1.5rem" }}>
              <label
                style={{
                  display: "block",
                  marginBottom: "1rem",
                  fontWeight: "600",
                  color: "var(--text-dark)",
                  fontSize: "1rem",
                }}
              >
                Options
              </label>
              
              {editedField.options?.map((option, index) => (
                <div 
                  key={index}
                  style={{
                    display: "flex",
                    gap: "0.5rem",
                    marginBottom: "0.75rem",
                    alignItems: "center",
                  }}
                >
                  <input
                    type="text"
                    value={option}
                    onChange={(e) => handleOptionChange(index, e.target.value)}
                    placeholder={`Option ${index + 1}`}
                    style={{
                      flex: "1",
                      padding: "0.75rem",
                      border: "2px solid #e9ecef",
                      borderRadius: "6px",
                      fontSize: "1rem",
                      transition: "all 0.2s ease",
                      background: "white",
                    }}
                    onFocus={(e) => {
                      e.target.style.borderColor = "var(--primary-red)";
                      e.target.style.boxShadow = "0 0 0 3px rgba(139, 21, 56, 0.1)";
                    }}
                    onBlur={(e) => {
                      e.target.style.borderColor = "#e9ecef";
                      e.target.style.boxShadow = "none";
                    }}
                  />
                  <button 
                    type="button"
                    onClick={() => removeOption(index)}
                    style={{
                      padding: "0.75rem",
                      backgroundColor: "var(--primary-red)",
                      color: "white",
                      border: "none",
                      borderRadius: "6px",
                      cursor: "pointer",
                      transition: "all 0.2s ease",
                      display: "flex",
                      alignItems: "center",
                    }}
                    onMouseOver={(e) => {
                      e.target.style.backgroundColor = "#6b1a21";
                    }}
                    onMouseOut={(e) => {
                      e.target.style.backgroundColor = "var(--primary-red)";
                    }}
                  >
                    <MdDelete />
                  </button>
                </div>
              ))}
              
              <button 
                type="button"
                onClick={addOption}
                style={{
                  padding: "0.75rem 1.5rem",
                  backgroundColor: "white",
                  color: "var(--accent-green)",
                  border: "2px solid var(--accent-green)",
                  borderRadius: "6px",
                  cursor: "pointer",
                  fontSize: "1rem",
                  fontWeight: "500",
                  transition: "all 0.2s ease",
                  display: "flex",
                  alignItems: "center",
                  gap: "0.5rem",
                }}
                onMouseOver={(e) => {
                  e.target.style.backgroundColor = "var(--accent-green)";
                  e.target.style.color = "white";
                }}
                onMouseOut={(e) => {
                  e.target.style.backgroundColor = "white";
                  e.target.style.color = "var(--accent-green)";
                }}
              >
                <MdAdd />
                Add Option
              </button>
            </div>
          )}

          {/* Validation rules for text fields */}
          {editedField.type === 'text' && (
            <div style={{ marginBottom: "1.5rem" }}>
              <label
                style={{
                  display: "block",
                  marginBottom: "0.5rem",
                  fontWeight: "600",
                  color: "var(--text-dark)",
                  fontSize: "1rem",
                }}
              >
                Maximum Length
              </label>
              <input
                type="number"
                value={editedField.maxLength || ''}
                onChange={(e) => setEditedField({ ...editedField, maxLength: parseInt(e.target.value) })}
                placeholder="Leave empty for no limit"
                style={{
                  width: "100%",
                  padding: "0.75rem",
                  border: "2px solid #e9ecef",
                  borderRadius: "6px",
                  fontSize: "1rem",
                  transition: "all 0.2s ease",
                  background: "white",
                }}
                onFocus={(e) => {
                  e.target.style.borderColor = "var(--primary-red)";
                  e.target.style.boxShadow = "0 0 0 3px rgba(139, 21, 56, 0.1)";
                }}
                onBlur={(e) => {
                  e.target.style.borderColor = "#e9ecef";
                  e.target.style.boxShadow = "none";
                }}
              />
            </div>
          )}

          {/* Validation rules for number fields */}
          {editedField.type === 'number' && (
            <>
              <div style={{ marginBottom: "1.5rem" }}>
                <label
                  style={{
                    display: "block",
                    marginBottom: "0.5rem",
                    fontWeight: "600",
                    color: "var(--text-dark)",
                    fontSize: "1rem",
                  }}
                >
                  Minimum Value
                </label>
                <input
                  type="number"
                  value={editedField.min || ''}
                  onChange={(e) => setEditedField({ ...editedField, min: parseFloat(e.target.value) })}
                  style={{
                    width: "100%",
                    padding: "0.75rem",
                    border: "2px solid #e9ecef",
                    borderRadius: "6px",
                    fontSize: "1rem",
                    transition: "all 0.2s ease",
                    background: "white",
                  }}
                  onFocus={(e) => {
                    e.target.style.borderColor = "var(--primary-red)";
                    e.target.style.boxShadow = "0 0 0 3px rgba(139, 21, 56, 0.1)";
                  }}
                  onBlur={(e) => {
                    e.target.style.borderColor = "#e9ecef";
                    e.target.style.boxShadow = "none";
                  }}
                />
              </div>
              <div style={{ marginBottom: "1.5rem" }}>
                <label
                  style={{
                    display: "block",
                    marginBottom: "0.5rem",
                    fontWeight: "600",
                    color: "var(--text-dark)",
                    fontSize: "1rem",
                  }}
                >
                  Maximum Value
                </label>
                <input
                  type="number"
                  value={editedField.max || ''}
                  onChange={(e) => setEditedField({ ...editedField, max: parseFloat(e.target.value) })}
                  style={{
                    width: "100%",
                    padding: "0.75rem",
                    border: "2px solid #e9ecef",
                    borderRadius: "6px",
                    fontSize: "1rem",
                    transition: "all 0.2s ease",
                    background: "white",
                  }}
                  onFocus={(e) => {
                    e.target.style.borderColor = "var(--primary-red)";
                    e.target.style.boxShadow = "0 0 0 3px rgba(139, 21, 56, 0.1)";
                  }}
                  onBlur={(e) => {
                    e.target.style.borderColor = "#e9ecef";
                    e.target.style.boxShadow = "none";
                  }}
                />
              </div>
            </>
          )}
        </div>

        {/* Modal Footer */}
        <div
          style={{
            padding: "1.5rem",
            background: "#f8f9fa",
            display: "flex",
            justifyContent: "flex-end",
            gap: "1rem",
            borderTop: "1px solid #e9ecef",
          }}
        >
          <button 
            onClick={onCancel}
            style={{
              padding: "0.75rem 1.5rem",
              backgroundColor: "#6c757d",
              color: "white",
              border: "none",
              borderRadius: "6px",
              fontSize: "1rem",
              fontWeight: "500",
              cursor: "pointer",
              transition: "all 0.2s ease",
            }}
            onMouseOver={(e) => {
              e.target.style.backgroundColor = "#545b62";
              e.target.style.transform = "translateY(-1px)";
            }}
            onMouseOut={(e) => {
              e.target.style.backgroundColor = "#6c757d";
              e.target.style.transform = "translateY(0)";
            }}
          >
            Cancel
          </button>
          <button 
            onClick={() => onSave(editedField)}
            disabled={!editedField.label.trim()}
            style={{
              padding: "0.75rem 1.5rem",
              backgroundColor: !editedField.label.trim() ? "#ccc" : "var(--accent-green)",
              color: "white",
              border: "none",
              borderRadius: "6px",
              fontSize: "1rem",
              fontWeight: "500",
              cursor: !editedField.label.trim() ? "not-allowed" : "pointer",
              transition: "all 0.2s ease",
            }}
            onMouseOver={(e) => {
              if (editedField.label.trim()) {
                e.target.style.backgroundColor = "#3d564d";
                e.target.style.transform = "translateY(-1px)";
              }
            }}
            onMouseOut={(e) => {
              if (editedField.label.trim()) {
                e.target.style.backgroundColor = "var(--accent-green)";
                e.target.style.transform = "translateY(0)";
              }
            }}
          >
            Save Field
          </button>
        </div>
      </div>
    </div>
  );
};

export default FieldEditor;
