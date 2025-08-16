import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/dynamic_form_widget.dart';
import '../../providers/form_provider.dart';

class DynamicFormScreen extends ConsumerStatefulWidget {
  final String formId;
  final String formTitle;

  const DynamicFormScreen({
    super.key,
    required this.formId,
    required this.formTitle,
  });

  @override
  ConsumerState<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends ConsumerState<DynamicFormScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch form template when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(formProvider.notifier).fetchFormTemplate(widget.formId);
    });
  }

  void _handleFormSubmit(Map<String, dynamic> formData) async {
    await ref.read(formProvider.notifier).submitForm(widget.formId, formData);

    final successMessage = ref.read(formSuccessProvider);
    final error = ref.read(formErrorProvider);

    if (mounted) {
      if (successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );

        // Clear success message
        ref.read(formProvider.notifier).clearSuccessMessage();

        // Navigate back or to success screen
        Navigator.pop(context);
      } else if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );

        // Clear error
        ref.read(formProvider.notifier).clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(formProvider);
    final isLoading = ref.watch(isFormLoadingProvider);
    final isSubmitting = ref.watch(isFormSubmittingProvider);

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5B00)),
          ),
        ),
      );
    }

    if (formState.error != null && formState.formTemplate == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading form',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  formState.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(formProvider.notifier)
                      .fetchFormTemplate(widget.formId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5B00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (formState.formTemplate == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(
          child: Text(
            'No form template available',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return DynamicFormWidget(
      formTemplate: formState.formTemplate!,
      formTitle: widget.formTitle,
      onSubmit: _handleFormSubmit,
      isLoading: isSubmitting,
    );
  }
}
