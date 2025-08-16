import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/validation_helper.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hasSubmitted = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to controllers to trigger rebuilds when text changes
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _nicController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    setState(() {
      _hasSubmitted = true;
    });

    // Clear any previous error
    ref.read(authProvider.notifier).clearError();

    // Validate all fields
    final List<String?> validationResults = [
      ValidationHelper.validateFirstName(_firstNameController.text),
      ValidationHelper.validateLastName(_lastNameController.text),
      ValidationHelper.validateNationalId(_nicController.text),
      ValidationHelper.validatePhoneNumber(_phoneController.text),
      ValidationHelper.validateEmail(_emailController.text),
      ValidationHelper.validatePassword(_passwordController.text),
      ValidationHelper.validateConfirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      ),
    ];

    if (!ValidationHelper.isFormValid(validationResults)) {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ValidationHelper.getFirstError(validationResults) ??
                'Please fix the errors above',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Attempt registration
      final response = await ref
          .read(authProvider.notifier)
          .register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            nationalId: _nicController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          );

      if (response.success) {
        // Registration successful - now automatically log in the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Logging you in...'),
              backgroundColor: Colors.green,
            ),
          );

          // Automatically log in the user with the same credentials
          final loginResponse = await ref
              .read(authProvider.notifier)
              .login(
                username: _emailController.text,
                password: _passwordController.text,
              );

          if (loginResponse.success && mounted) {
            // Login successful, navigate to KYC verification
            Navigator.pushNamed(context, '/kyc_verification');
          } else if (mounted) {
            // Login failed after registration - show error and redirect to login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Registration successful! Please log in to continue.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pushNamed(context, '/login');
          }
        }
      } else {
        // Registration failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
              Container(
                width: double.infinity,
                height: 104,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Stack(
                    children: [
                      // Back icon
                      Positioned(
                        left: 24,
                        top: 24,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SizedBox(
                            width: 18.74,
                            height: 14.56,
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xFF525252),
                              size: 16,
                            ),
                          ),
                        ),
                      ),

                      // Logo and Gov Portal text
                      Positioned(
                        left: screenWidth / 2 - 59.45,
                        top: 12,
                        child: Column(
                          children: [
                            // Logo
                            Container(
                              width: 47,
                              height: 47,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/signup_logo.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Gov Portal text
                            const Text(
                              'Gov Portal',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF171717),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sign Up title
              Padding(
                padding: const EdgeInsets.only(top: 17),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 23,
                    color: Color(0xFF171717),
                    height: 1.043,
                  ),
                ),
              ),

              // Form section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // First Name field
                      _buildFormField(
                        label: 'First Name',
                        hint: 'Enter your first name',
                        controller: _firstNameController,
                        showSkipAll: true,
                      ),

                      const SizedBox(height: 16),

                      // Last Name field
                      _buildFormField(
                        label: 'Last Name',
                        hint: 'Enter your last name',
                        controller: _lastNameController,
                      ),

                      const SizedBox(height: 16),

                      // NIC Number field
                      _buildFormField(
                        label: 'NIC Number',
                        hint: 'Enter your NIC number',
                        controller: _nicController,
                      ),

                      const SizedBox(height: 16),

                      // Phone Number field
                      _buildFormField(
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        controller: _phoneController,
                      ),

                      const SizedBox(height: 16),

                      // Email field
                      _buildFormField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      _buildFormField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password field
                      _buildFormField(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Terms and privacy policy text
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                        child: Text(
                          'By registering, you agree to our terms and privacy policy.',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xFF909090),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Register button
                      Container(
                        width: double.infinity,
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final authState = ref.watch(authProvider);
                            final isLoading = authState.isLoading;

                            return ElevatedButton(
                              onPressed: isLoading ? null : _handleRegistration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5B00),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFFFCFAF7),
                                              ),
                                        ),
                                      )
                                      : const Text(
                                        'Register',
                                        style: TextStyle(
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Color(0xFFFCFAF7),
                                          height: 1.5,
                                        ),
                                      ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Already have an account? Sign In
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to login screen
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Already have an account? Sign In',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xFF909090),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    bool showSkipAll = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with optional Skip all
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF404040),
                height: 1.21,
              ),
            ),
            if (showSkipAll)
              GestureDetector(
                onTap: () {
                  // Navigate to home page without login
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home_without_login',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Skip all',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xFF8C1F28),
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Input field with consistent height
        SizedBox(
          height: 74, // Fixed height to accommodate error messages
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color:
                        _hasSubmitted && _hasError(label, controller.text)
                            ? Colors.red
                            : const Color(0xFFD4D4D4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: controller,
                  obscureText: isPassword && !isPasswordVisible,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xFFADAEBC),
                      height: 1.5,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                    isDense: true,
                    errorStyle: const TextStyle(
                      height: 0,
                      fontSize: 0,
                      color: Colors.transparent,
                    ),
                    suffixIcon:
                        isPassword && onToggleVisibility != null
                            ? IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFFADAEBC),
                                size: 20,
                              ),
                              onPressed: onToggleVisibility,
                            )
                            : null,
                  ),
                ),
              ),
              // Custom error message with consistent spacing
              Container(
                height: 20, // Fixed height for error message
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Builder(
                  builder: (context) {
                    // Get error message for this field using proper validation
                    final errorMessage = _getErrorMessage(
                      label,
                      controller.text,
                    );

                    // Only show error if form has been submitted and field is invalid
                    final showError = _hasSubmitted && errorMessage != null;

                    return showError
                        ? Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to check if a field has an error
  bool _hasError(String label, String value) {
    return _getErrorMessage(label, value) != null;
  }

  // Helper method to get error message for a field using ValidationHelper
  String? _getErrorMessage(String label, String value) {
    switch (label) {
      case 'First Name':
        return ValidationHelper.validateFirstName(value);
      case 'Last Name':
        return ValidationHelper.validateLastName(value);
      case 'NIC Number':
        return ValidationHelper.validateNationalId(value);
      case 'Phone Number':
        return ValidationHelper.validatePhoneNumber(value);
      case 'Email':
        return ValidationHelper.validateEmail(value);
      case 'Password':
        return ValidationHelper.validatePassword(value);
      case 'Confirm Password':
        return ValidationHelper.validateConfirmPassword(
          value,
          _passwordController.text,
        );
      default:
        return null;
    }
  }
}
