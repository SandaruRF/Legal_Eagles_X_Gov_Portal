import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final bool _hasSubmitted = false; // Track if form has been submitted

  @override
  void initState() {
    super.initState();
    // Add listeners to controllers to trigger rebuilds when text changes
    _fullNameController.addListener(() => setState(() {}));
    _nicController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

                      // Full Name field
                      _buildFormField(
                        label: 'Full Name',
                        hint: 'Enter your name',
                        controller: _fullNameController,
                        showSkipAll: true,
                      ),

                      const SizedBox(height: 16),

                      // NIC Number field
                      _buildFormField(
                        label: 'NIC Number',
                        hint: 'Enter your phone NIC number',
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
                        hint: 'Enter your phone email',
                        controller: _emailController,
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      _buildFormField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        isPassword: true,
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password field
                      _buildFormField(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        controller: _confirmPasswordController,
                        isPassword: true,
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
                        child: ElevatedButton(
                          onPressed: () {
                            print('Register button pressed!');
                            // TEMPORARY: Skip validation for testing
                            print(
                              'Skipping validation - navigating directly to KYC',
                            );
                            Navigator.pushNamed(context, '/kyc_verification');

                            /* ORIGINAL VALIDATION CODE - UNCOMMENT TO RESTORE:
                            setState(() {
                              _hasSubmitted = true;
                            });

                            // Manual validation check
                            bool isValid = true;

                            // Check all fields for errors
                            if (_hasError(
                              'Full Name',
                              _fullNameController.text,
                            )) {
                              print(
                                'Full Name validation failed: "${_fullNameController.text}"',
                              );
                              isValid = false;
                            }
                            if (_hasError('NIC Number', _nicController.text)) {
                              print(
                                'NIC validation failed: "${_nicController.text}"',
                              );
                              isValid = false;
                            }
                            if (_hasError(
                              'Phone Number',
                              _phoneController.text,
                            )) {
                              print(
                                'Phone validation failed: "${_phoneController.text}"',
                              );
                              isValid = false;
                            }
                            if (_hasError('Email', _emailController.text)) {
                              print(
                                'Email validation failed: "${_emailController.text}"',
                              );
                              isValid = false;
                            }
                            if (_hasError(
                              'Password',
                              _passwordController.text,
                            )) {
                              print(
                                'Password validation failed: "${_passwordController.text}"',
                              );
                              isValid = false;
                            }
                            if (_hasError(
                              'Confirm Password',
                              _confirmPasswordController.text,
                            )) {
                              print(
                                'Confirm Password validation failed: "${_confirmPasswordController.text}"',
                              );
                              isValid = false;
                            }

                            print('Form validation result: $isValid');
                            if (isValid) {
                              print(
                                'Registration form submitted - navigating to KYC',
                              );
                              Navigator.pushNamed(context, '/kyc_verification');
                            } else {
                              print('Form validation failed - not navigating');
                              // Show a message to user about filling required fields
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill in all required fields correctly',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            */
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5B00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFFFCFAF7),
                              height: 1.5,
                            ),
                          ),
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
                  obscureText: isPassword,
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
                  ),
                  // Remove validator completely to prevent any built-in validation behavior
                ),
              ),
              // Custom error message with consistent spacing
              Container(
                height: 20, // Fixed height for error message
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Builder(
                  builder: (context) {
                    // Get error message for this field
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
                        : const SizedBox.shrink(); // Use shrink instead of empty SizedBox
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
    if (value.isEmpty) {
      return true;
    }
    if (label == 'Email' && !value.contains('@')) {
      return true;
    }
    if (label == 'Confirm Password' && value != _passwordController.text) {
      return true;
    }
    return false;
  }

  // Helper method to get error message for a field
  String? _getErrorMessage(String label, String value) {
    if (value.isEmpty) {
      return 'Please enter your ${label.toLowerCase()}';
    }
    if (label == 'Email' && !value.contains('@')) {
      return 'Please enter a valid email';
    }
    if (label == 'Confirm Password' && value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
