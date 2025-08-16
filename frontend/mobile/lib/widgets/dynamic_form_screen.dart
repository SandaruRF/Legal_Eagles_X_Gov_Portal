import 'package:flutter/material.dart';
import '../core/services/form_service.dart';

class DynamicFormScreen extends StatefulWidget {
  final String formId;
  final String title;
  final String? subtitle;

  const DynamicFormScreen({
    super.key,
    required this.formId,
    required this.title,
    this.subtitle,
  });

  @override
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  final FormService _formService = FormService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _formTemplate;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _formData = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFormTemplate();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFormTemplate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _formService.getFormTemplate(widget.formId);

      if (response.success && response.data != null) {
        // Check if the response has the expected structure
        final responseData = response.data!;

        Map<String, dynamic> formTemplate;

        // Check if response has nested form structure (new API format)
        if (responseData.containsKey('form') &&
            responseData.containsKey('status')) {
          final formData = responseData['form'] as Map<String, dynamic>;
          final formName = formData['name'] as String? ?? 'Unknown Form';

          // Log the form info for debugging
          print('Form loaded: $formName');
          print('Form template URL: ${formData['form_template']}');

          // Create form fields based on form name/ID
          formTemplate = _createFormTemplateBasedOnFormName(
            formName,
            widget.formId,
          );
        } else {
          // Old structure - use response data directly
          formTemplate = responseData;
        }

        setState(() {
          _formTemplate = formTemplate;
          _initializeControllers();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load form: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _createFormTemplateBasedOnFormName(
    String formName,
    String formId,
  ) {
    // Create form template based on form name or ID
    final lowerFormName = formName.toLowerCase();

    if (lowerFormName.contains('medical') || formId.contains('medical')) {
      return _createMedicalAppointmentTemplate();
    } else if (lowerFormName.contains('driving') ||
        lowerFormName.contains('license')) {
      return _createDrivingLicenseTemplate();
    } else if (lowerFormName.contains('passport')) {
      return _createPassportApplicationTemplate();
    } else {
      // Default generic form
      return _createGenericApplicationTemplate();
    }
  }

  Map<String, dynamic> _createMedicalAppointmentTemplate() {
    // Create a template for medical appointment based on common requirements
    return {
      'Full Name': '',
      'NIC No': '',
      'Date of Birth': '',
      'Sex': '',
      'Phone Number': '',
      'Email': '',
      'Address': '',
      'City': '',
      'District': '',
      'Emergency Contact Name': '',
      'Emergency Contact Number': '',
      'Medical History': '',
      'Current Medications': '',
      'Allergies': '',
      'Preferred Appointment Date': '',
      'Preferred Time': '',
      'Additional Notes': '',
    };
  }

  Map<String, dynamic> _createDrivingLicenseTemplate() {
    return {
      'Full Name': '',
      'Other Names': '',
      'Surname': '',
      'NIC No': '',
      'DOB Date': '',
      'DOB Month': '',
      'DOB Year': '',
      'Sex': '',
      'Email': '',
      'Phone Number': '',
      'Street & house no': '',
      'City': '',
      'District': '',
      'Birth District': '',
      'Place Of Birth': '',
      'Type of service': '',
      'Date filled': '',
    };
  }

  Map<String, dynamic> _createPassportApplicationTemplate() {
    return {
      'Full Name': '',
      'Other Names': '',
      'Surname': '',
      'NIC No': '',
      'Birth Certificate No': '',
      'Sex': '',
      'Email': '',
      'Phone Number': '',
      'Address': '',
      'City': '',
      'District': '',
      'Profession': '',
      'Type of travel document': '',
      'Present Travel Document Number': '',
      'Dual Citizenship No': '',
      'Foreign Nationality': '',
      'Foreign Passport No': '',
      'National Identity Card No/ Present Travel Document No of Father/Guardian':
          '',
      'National Identity Card No/ Present Travel Document No of Mother/Guardian':
          '',
    };
  }

  Map<String, dynamic> _createGenericApplicationTemplate() {
    return {
      'Full Name': '',
      'NIC No': '',
      'Email': '',
      'Phone Number': '',
      'Address': '',
      'City': '',
      'District': '',
      'Date of Application': '',
      'Additional Information': '',
    };
  }

  void _initializeControllers() {
    _controllers.clear();
    _formData.clear();

    if (_formTemplate != null) {
      for (String fieldName in _formTemplate!.keys) {
        _controllers[fieldName] = TextEditingController();
        _formData[fieldName] = _formTemplate![fieldName] ?? '';

        // Set initial value if exists
        if (_formTemplate![fieldName] != null &&
            _formTemplate![fieldName].toString().isNotEmpty) {
          _controllers[fieldName]!.text = _formTemplate![fieldName].toString();
        }
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    // Update form data with current controller values
    for (String fieldName in _controllers.keys) {
      _formData[fieldName] = _controllers[fieldName]!.text;
    }

    try {
      final response = await _formService.submitForm(widget.formId, _formData);

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        setState(() {
          _error = response.message;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to submit form: ${e.toString()}';
        _isSubmitting = false;
      });
    }
  }

  Widget _buildFormField(String fieldName, dynamic initialValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldName,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[fieldName],
            decoration: InputDecoration(
              hintText: 'Enter $fieldName',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            validator: (value) {
              // Basic validation - required fields
              if (_isRequiredField(fieldName) &&
                  (value == null || value.trim().isEmpty)) {
                return '$fieldName is required';
              }
              return null;
            },
            keyboardType: _getKeyboardType(fieldName),
          ),
        ],
      ),
    );
  }

  bool _isRequiredField(String fieldName) {
    // Define which fields are required based on common field names
    final requiredFields = [
      'Email',
      'NIC No',
      'Surname',
      'Other Names',
      'Phone Number',
      'DOB Date',
      'DOB Month',
      'DOB Year',
      'Sex',
      'Date filled',
    ];
    return requiredFields.any(
      (required) => fieldName.toLowerCase().contains(required.toLowerCase()),
    );
  }

  TextInputType _getKeyboardType(String fieldName) {
    final fieldLower = fieldName.toLowerCase();

    if (fieldLower.contains('email')) {
      return TextInputType.emailAddress;
    } else if (fieldLower.contains('phone') ||
        fieldLower.contains('number') ||
        fieldLower.contains('no') ||
        fieldLower.contains('year') ||
        fieldLower.contains('date')) {
      return TextInputType.number;
    }

    return TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main Content
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF5B00),
                        ),
                      )
                      : _error != null
                      ? _buildErrorWidget()
                      : _buildFormContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 103,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
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
                        image: AssetImage('assets/images/gov_portal_logo.png'),
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
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(
              'Error Loading Form',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFormTemplate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5B00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    if (_formTemplate == null || _formTemplate!.isEmpty) {
      return const Center(
        child: Text(
          'No form fields available',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Form content
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF171717),
                    ),
                  ),

                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Error message
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        border: Border.all(color: const Color(0xFFFECACA)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form fields
                  ...(_formTemplate!.keys.map(
                    (fieldName) =>
                        _buildFormField(fieldName, _formTemplate![fieldName]),
                  )),
                ],
              ),
            ),
          ),
        ),

        // Submit button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
          ),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5B00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child:
                _isSubmitting
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
                      'Submit Form',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
