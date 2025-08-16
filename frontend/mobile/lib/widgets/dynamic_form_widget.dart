import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/form_field_model.dart';

class DynamicFormWidget extends StatefulWidget {
  final List<FormFieldModel> formFields;
  final String formTitle;
  final Function(Map<String, dynamic>) onSubmit;
  final bool isLoading;

  const DynamicFormWidget({
    super.key,
    required this.formFields,
    required this.formTitle,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<DynamicFormWidget> createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;
  late Map<String, TextEditingController> _controllers;
  late Map<String, String?> _selectedValues; // For dropdowns and radio buttons
  late Map<String, List<String>> _selectedCheckboxes; // For checkboxes
  late Map<String, File?> _selectedFiles; // For file uploads
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _formData = {};
    _controllers = {};
    _selectedValues = {};
    _selectedCheckboxes = {};
    _selectedFiles = {};

    for (final field in widget.formFields) {
      final fieldKey = field.label.toLowerCase().replaceAll(' ', '_');

      if (field.type == 'text' ||
          field.type == 'email' ||
          field.type == 'tel' ||
          field.type == 'textarea' ||
          field.type == 'number') {
        _controllers[fieldKey] = TextEditingController();
      } else if (field.type == 'select' || field.type == 'radio') {
        _selectedValues[fieldKey] = null;
      } else if (field.type == 'checkbox') {
        _selectedCheckboxes[fieldKey] = [];
      } else if (field.type == 'file') {
        _selectedFiles[fieldKey] = null;
      } else if (field.type == 'date') {
        _controllers[fieldKey] = TextEditingController();
      }

      _formData[fieldKey] = null;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateField(FormFieldModel field) {
    final fieldKey = field.label.toLowerCase().replaceAll(' ', '_');

    if (!field.required) return null;

    if (field.type == 'text' ||
        field.type == 'email' ||
        field.type == 'tel' ||
        field.type == 'textarea' ||
        field.type == 'number' ||
        field.type == 'date') {
      final value = _controllers[fieldKey]?.text;
      if (value == null || value.trim().isEmpty) {
        return '${field.label} is required';
      }

      if (field.type == 'email') {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
      }

      if (field.type == 'number') {
        final num? numValue = num.tryParse(value);
        if (numValue == null) {
          return 'Please enter a valid number';
        }
        if (field.minValue != null && numValue < field.minValue!) {
          return 'Value must be at least ${field.minValue}';
        }
        if (field.maxValue != null && numValue > field.maxValue!) {
          return 'Value must not exceed ${field.maxValue}';
        }
      }

      if (field.maxLength != null && value.length > field.maxLength!) {
        return 'Maximum ${field.maxLength} characters allowed';
      }
    } else if (field.type == 'select' || field.type == 'radio') {
      final value = _selectedValues[fieldKey];
      if (value == null || value.isEmpty) {
        return '${field.label} is required';
      }
    } else if (field.type == 'checkbox') {
      final values = _selectedCheckboxes[fieldKey];
      if (values == null || values.isEmpty) {
        return '${field.label} is required';
      }
    } else if (field.type == 'file') {
      final file = _selectedFiles[fieldKey];
      if (file == null) {
        return '${field.label} is required';
      }
    }

    return null;
  }

  Widget _buildFormField(FormFieldModel field) {
    final fieldKey = field.label.toLowerCase().replaceAll(' ', '_');

    switch (field.type) {
      case 'text':
      case 'email':
      case 'tel':
        return _buildTextFormField(field, fieldKey);
      case 'textarea':
        return _buildTextAreaField(field, fieldKey);
      case 'number':
        return _buildNumberField(field, fieldKey);
      case 'date':
        return _buildDateField(field, fieldKey);
      case 'select':
        return _buildSelectField(field, fieldKey);
      case 'radio':
        return _buildRadioField(field, fieldKey);
      case 'checkbox':
        return _buildCheckboxField(field, fieldKey);
      case 'file':
        return _buildFileField(field, fieldKey);
      default:
        return _buildTextFormField(field, fieldKey);
    }
  }

  Widget _buildTextFormField(FormFieldModel field, String fieldKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label + (field.required ? ' *' : ''),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[fieldKey],
            keyboardType: _getKeyboardType(field.type),
            validator: (_) => _validateField(field),
            onChanged: (value) => _formData[fieldKey] = value,
            decoration: InputDecoration(
              hintText:
                  field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5B00),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaField(FormFieldModel field, String fieldKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label + (field.required ? ' *' : ''),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[fieldKey],
            maxLines: 4,
            validator: (_) => _validateField(field),
            onChanged: (value) => _formData[fieldKey] = value,
            decoration: InputDecoration(
              hintText:
                  field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5B00),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(FormFieldModel field, String fieldKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label + (field.required ? ' *' : ''),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[fieldKey],
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (_) => _validateField(field),
            onChanged: (value) => _formData[fieldKey] = value,
            decoration: InputDecoration(
              hintText:
                  field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5B00),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(FormFieldModel field, String fieldKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label + (field.required ? ' *' : ''),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[fieldKey],
            readOnly: true,
            validator: (_) => _validateField(field),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                final formattedDate =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                _controllers[fieldKey]!.text = formattedDate;
                _formData[fieldKey] = formattedDate;
              }
            },
            decoration: InputDecoration(
              hintText: 'Select date',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              suffixIcon: const Icon(
                Icons.calendar_today,
                color: Color(0xFF9CA3AF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5B00),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectField(FormFieldModel field, String fieldKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label + (field.required ? ' *' : ''),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          FormField<String>(
            validator: (_) => _validateField(field),
            builder: (formFieldState) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        formFieldState.hasError
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE5E7EB),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedValues[fieldKey],
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Select ${field.label.toLowerCase()}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        _selectedValues[fieldKey] = value;
                        _formData[fieldKey] = value;
                      });
                    },
                    items:
                        field.options?.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Color(0xFF171717),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadioField(FormFieldModel field, String fieldKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FormField<String>(
        validator: (_) => _validateField(field),
        builder: (formFieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label + (field.required ? ' *' : ''),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              ...field.options?.map((option) {
                    return RadioListTile<String>(
                      title: Text(
                        option,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF171717),
                        ),
                      ),
                      value: option,
                      groupValue: _selectedValues[fieldKey],
                      onChanged: (value) {
                        setState(() {
                          _selectedValues[fieldKey] = value;
                          _formData[fieldKey] = value;
                        });
                      },
                      activeColor: const Color(0xFFFF5B00),
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList() ??
                  [],
              if (formFieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Text(
                    formFieldState.errorText!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckboxField(FormFieldModel field, String fieldKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FormField<List<String>>(
        validator: (_) => _validateField(field),
        builder: (formFieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label + (field.required ? ' *' : ''),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              ...field.options?.map((option) {
                    return CheckboxListTile(
                      title: Text(
                        option,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF171717),
                        ),
                      ),
                      value:
                          _selectedCheckboxes[fieldKey]?.contains(option) ??
                          false,
                      onChanged: (checked) {
                        setState(() {
                          if (_selectedCheckboxes[fieldKey] == null) {
                            _selectedCheckboxes[fieldKey] = [];
                          }
                          if (checked == true) {
                            _selectedCheckboxes[fieldKey]!.add(option);
                          } else {
                            _selectedCheckboxes[fieldKey]!.remove(option);
                          }
                          _formData[fieldKey] = _selectedCheckboxes[fieldKey];
                        });
                      },
                      activeColor: const Color(0xFFFF5B00),
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList() ??
                  [],
              if (formFieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Text(
                    formFieldState.errorText!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFileField(FormFieldModel field, String fieldKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FormField<File>(
        validator: (_) => _validateField(field),
        builder: (formFieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label + (field.required ? ' *' : ''),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedFiles[fieldKey] = File(pickedFile.path);
                      _formData[fieldKey] = _selectedFiles[fieldKey];
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          formFieldState.hasError
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_upload, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedFiles[fieldKey]?.path.split('/').last ??
                              field.placeholder ??
                              'Choose file',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color:
                                _selectedFiles[fieldKey] != null
                                    ? const Color(0xFF171717)
                                    : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (formFieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    formFieldState.errorText!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  TextInputType _getKeyboardType(String type) {
    switch (type) {
      case 'email':
        return TextInputType.emailAddress;
      case 'tel':
        return TextInputType.phone;
      case 'number':
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Clean the form data
      final cleanedData = <String, dynamic>{};
      for (var entry in _formData.entries) {
        if (entry.value != null) {
          cleanedData[entry.key] = entry.value;
        }
      }

      widget.onSubmit(cleanedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Status bar area
          Container(
            height: MediaQuery.of(context).padding.top,
            color: const Color(0xFFFAFAFA),
          ),

          // Header
          Container(
            width: double.infinity,
            height: 82,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 33.5,
                    height: 36,
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: Color(0xFF525252),
                    ),
                  ),
                ),

                // Gov Portal centered with logo
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Gov logo
                      Container(
                        width: 47,
                        height: 47,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/gov_portal_logo.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Gov Portal',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171717),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Empty space to balance the back button
                const SizedBox(width: 33.5),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form title
                    Text(
                      widget.formTitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF171717),
                      ),
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'Please fill out all the required information below',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Dynamic form fields
                    ...widget.formFields.map((field) => _buildFormField(field)),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: widget.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5B00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child:
                            widget.isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Submit Application',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
