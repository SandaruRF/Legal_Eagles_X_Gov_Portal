import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/form_service.dart';

/// State for dynamic forms
class FormState {
  final Map<String, dynamic>? formTemplate;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? successMessage;

  const FormState({
    this.formTemplate,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
  });

  FormState copyWith({
    Map<String, dynamic>? formTemplate,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? successMessage,
  }) {
    return FormState(
      formTemplate: formTemplate ?? this.formTemplate,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Form provider for managing dynamic forms
class FormNotifier extends StateNotifier<FormState> {
  FormNotifier() : super(const FormState());

  final FormService _formService = FormService();

  /// Fetch form template by form ID
  Future<void> fetchFormTemplate(String formId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _formService.getFormTemplate(formId);

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
          formTemplate = _createFormTemplateBasedOnFormName(formName, formId);
        } else {
          // Old structure - use response data directly
          formTemplate = responseData;
        }

        state = state.copyWith(
          formTemplate: formTemplate,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch form template: ${e.toString()}',
      );
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

  /// Submit form data
  Future<void> submitForm(String formId, Map<String, dynamic> formData) async {
    state = state.copyWith(
      isSubmitting: true,
      error: null,
      successMessage: null,
    );

    try {
      final response = await _formService.submitForm(formId, formData);

      if (response.success) {
        state = state.copyWith(
          isSubmitting: false,
          error: null,
          successMessage: 'Form submitted successfully!',
        );
      } else {
        state = state.copyWith(isSubmitting: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit form: ${e.toString()}',
      );
    }
  }

  /// Clear form state
  void clearForm() {
    state = const FormState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear success message
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }
}

/// Provider for form state
final formProvider = StateNotifierProvider<FormNotifier, FormState>((ref) {
  return FormNotifier();
});

/// Convenience provider to check if form is loading
final isFormLoadingProvider = Provider<bool>((ref) {
  return ref.watch(formProvider).isLoading;
});

/// Convenience provider to check if form is submitting
final isFormSubmittingProvider = Provider<bool>((ref) {
  return ref.watch(formProvider).isSubmitting;
});

/// Convenience provider to get form template
final formTemplateProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(formProvider).formTemplate;
});

/// Convenience provider to get form errors
final formErrorProvider = Provider<String?>((ref) {
  return ref.watch(formProvider).error;
});

/// Convenience provider to get form success message
final formSuccessProvider = Provider<String?>((ref) {
  return ref.watch(formProvider).successMessage;
});
