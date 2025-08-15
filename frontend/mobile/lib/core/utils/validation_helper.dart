class ValidationHelper {
  // Username/Email validation (for login - can be either email or NIC)
  static String? validateUsernameOrEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email or NIC is required';
    }

    // If it contains @ symbol, validate as email
    if (value.contains('@')) {
      return validateEmail(value);
    }

    // Otherwise validate as NIC/username
    if (value.length < 3) {
      return 'Please enter a valid email or NIC';
    }

    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters for validation
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid length (adjust based on your country requirements)
    if (cleanedValue.length < 8 || cleanedValue.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // National ID validation (you may need to adjust this based on your country's format)
  static String? validateNationalId(String? value) {
    if (value == null || value.isEmpty) {
      return 'National ID is required';
    }

    // Remove all non-alphanumeric characters
    final cleanedValue = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // Check minimum length (adjust based on your country's requirements)
    if (cleanedValue.length < 5) {
      return 'National ID must be at least 5 characters';
    }

    // Check maximum length (adjust based on your country's requirements)
    if (cleanedValue.length > 20) {
      return 'National ID is too long';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    if (value.length > 50) {
      return '$fieldName is too long';
    }

    // Check if it contains only letters, spaces, hyphens, and apostrophes
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // First name validation
  static String? validateFirstName(String? value) {
    return validateName(value, 'First name');
  }

  // Last name validation
  static String? validateLastName(String? value) {
    return validateName(value, 'Last name');
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Validation for minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    return null;
  }

  // Validation for maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    return null;
  }

  // Combined min and max length validation
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    final minError = validateMinLength(value, minLength, fieldName);
    if (minError != null) return minError;

    final maxError = validateMaxLength(value, maxLength, fieldName);
    if (maxError != null) return maxError;

    return null;
  }

  // Validate if all form fields are valid
  static bool isFormValid(List<String?> validationResults) {
    return validationResults.every((result) => result == null);
  }

  // Get first error from validation results
  static String? getFirstError(List<String?> validationResults) {
    return validationResults.firstWhere(
      (result) => result != null,
      orElse: () => null,
    );
  }

  // Password strength checker
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character type checks
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // Common patterns check (negative score)
    if (password.toLowerCase().contains('password') ||
        password.toLowerCase().contains('123456') ||
        password == password.toLowerCase() && password.length < 10) {
      score--;
    }

    if (score <= 1) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    if (score <= 5) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }
}

// Password strength enumeration
enum PasswordStrength { none, weak, medium, strong, veryStrong }

// Extension to get color and text for password strength
extension PasswordStrengthExtension on PasswordStrength {
  String get text {
    switch (this) {
      case PasswordStrength.none:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  // You can add color properties here if needed
  // Color get color { ... }
}
