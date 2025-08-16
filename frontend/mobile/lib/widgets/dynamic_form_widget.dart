import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicFormWidget extends StatefulWidget {
  final Map<String, dynamic> formTemplate;
  final String formTitle;
  final Function(Map<String, dynamic>) onSubmit;
  final bool isLoading;

  const DynamicFormWidget({
    super.key,
    required this.formTemplate,
    required this.formTitle,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<DynamicFormWidget> createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  late Map<String, String?> _formData;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _controllers = {};
    _formData = {};

    for (String fieldName in widget.formTemplate.keys) {
      _controllers[fieldName] = TextEditingController();
      _formData[fieldName] = '';
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatFieldName(String fieldName) {
    // Convert field names to more readable format
    return fieldName
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : '',
        )
        .join(' ')
        .trim();
  }

  TextInputType _getInputType(String fieldName) {
    final lowerField = fieldName.toLowerCase();

    if (lowerField.contains('email')) {
      return TextInputType.emailAddress;
    } else if (lowerField.contains('phone') || lowerField.contains('number')) {
      return TextInputType.phone;
    } else if (lowerField.contains('date') ||
        lowerField.contains('year') ||
        lowerField.contains('month')) {
      return TextInputType.number;
    }

    return TextInputType.text;
  }

  List<TextInputFormatter> _getInputFormatters(String fieldName) {
    final lowerField = fieldName.toLowerCase();

    if (lowerField.contains('phone') ||
        lowerField.contains('nic') ||
        lowerField.contains('number') ||
        lowerField.contains('year') ||
        lowerField.contains('month') ||
        lowerField.contains('date')) {
      return [FilteringTextInputFormatter.digitsOnly];
    }

    return [];
  }

  String? _validateField(String fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${_formatFieldName(fieldName)} is required';
    }

    final lowerField = fieldName.toLowerCase();

    if (lowerField.contains('email')) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    }

    if (lowerField.contains('phone')) {
      if (value.length < 10) {
        return 'Please enter a valid phone number';
      }
    }

    if (lowerField.contains('nic') && lowerField.contains('no')) {
      if (value.length != 10 && value.length != 12) {
        return 'NIC should be 10 or 12 digits';
      }
    }

    return null;
  }

  Widget _buildFormField(String fieldName) {
    final controller = _controllers[fieldName]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatFieldName(fieldName),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: _getInputType(fieldName),
            inputFormatters: _getInputFormatters(fieldName),
            validator: (value) => _validateField(fieldName, value),
            onChanged: (value) {
              _formData[fieldName] = value;
            },
            decoration: InputDecoration(
              hintText: _getHintText(fieldName),
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

  String _getHintText(String fieldName) {
    final lowerField = fieldName.toLowerCase();

    if (lowerField.contains('email')) {
      return 'Enter your email address';
    } else if (lowerField.contains('phone')) {
      return 'Enter your phone number';
    } else if (lowerField.contains('nic')) {
      return 'Enter your NIC number';
    } else if (lowerField.contains('date')) {
      return 'DD';
    } else if (lowerField.contains('month')) {
      return 'MM';
    } else if (lowerField.contains('year')) {
      return 'YYYY';
    } else if (lowerField.contains('sex')) {
      return 'Male/Female';
    }

    return 'Enter ${_formatFieldName(fieldName).toLowerCase()}';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Clean the form data (remove empty values)
      final cleanedData = <String, dynamic>{};
      for (var entry in _formData.entries) {
        cleanedData[entry.key] = entry.value?.trim() ?? '';
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
                    ...widget.formTemplate.keys.map(
                      (fieldName) => _buildFormField(fieldName),
                    ),

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
                                    fontFamily: 'Proxima Nova',
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
