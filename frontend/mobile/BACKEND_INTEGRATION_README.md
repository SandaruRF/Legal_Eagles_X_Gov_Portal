# Backend Integration Implementation

## Overview
This document outlines the complete backend integration implementation for the signup screen in the Government Portal Flutter application.

## Architecture

### 1. Models (`/lib/models/`)

#### ApiResponse<T>
- **Purpose**: Generic wrapper for all API responses
- **Features**: Success/error states, status codes, error handling
- **Usage**: Consistent response handling across all API calls

#### User
- **Purpose**: User data model
- **Features**: JSON serialization, validation, copyWith functionality
- **Fields**: id, email, firstName, lastName, phoneNumber, nationalId, isVerified, createdAt, updatedAt

#### RegisterRequest
- **Purpose**: Request model for user registration
- **Features**: JSON serialization for API communication
- **Fields**: fullName, nicNo, phoneNo, email, password

### 2. Core Services (`/lib/core/services/`)

#### HttpClientService
- **Purpose**: Centralized HTTP client with comprehensive error handling
- **Features**: 
  - Request/response logging
  - Automatic auth token management
  - Timeout handling
  - Network error detection
  - Generic response parsing

#### AuthService
- **Purpose**: Authentication operations
- **Features**:
  - User registration
  - Login/logout
  - Profile management
  - Password operations
  - Account deletion

### 3. Configuration (`/lib/core/config/`)

#### ApiConfig
- **Purpose**: Centralized API configuration
- **Features**:
  - Base URL: `https://anuhasip-gov-portal-backend.hf.space/`
  - Standard headers
  - Timeout configurations
  - Endpoint definitions

### 4. Providers (`/lib/providers/`)

#### AuthProvider (Riverpod)
- **Purpose**: State management for authentication
- **Features**:
  - Loading states
  - Error handling
  - User state management
  - Automatic UI updates

### 5. Utilities (`/lib/core/utils/`)

#### ValidationHelper
- **Purpose**: Comprehensive form validation
- **Features**:
  - Email validation with regex
  - Password strength checking (8+ chars, uppercase, lowercase, numbers, special chars)
  - Name validation (letters, spaces, hyphens, apostrophes)
  - Phone number validation
  - National ID validation
  - Password confirmation matching

## Updated Signup Screen

### New Features
1. **Real Backend Integration**: Connects to actual backend API
2. **Enhanced Validation**: Uses ValidationHelper for comprehensive field validation
3. **Loading States**: Shows loading indicator during registration
4. **Error Handling**: Displays specific error messages from backend
5. **Password Visibility**: Toggle for password fields
6. **Success Feedback**: Success messages with navigation to KYC

### Form Fields
- First Name (separate from Last Name for better data structure)
- Last Name
- NIC Number
- Phone Number
- Email
- Password (with strength requirements)
- Confirm Password

### Validation Rules
- **First/Last Name**: 2-50 characters, letters/spaces/hyphens/apostrophes only
- **Email**: Valid email format with regex validation
- **Password**: Minimum 8 characters, must contain uppercase, lowercase, number, and special character
- **Phone**: 8-15 digits
- **NIC**: 5-20 alphanumeric characters
- **Confirm Password**: Must match password field

## API Integration

### Backend URL
```
https://anuhasip-gov-portal-backend.hf.space/
```

### Registration Endpoint
```
POST /api/citizens/register
```

### Request Format
```json
{
  "full_name": "John Doe",
  "nic_no": "123456789V",
  "phone_no": "+94771234567",
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

### Response Format
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": { ... },
    "token": "jwt_token_here"
  }
}
```

## Error Handling

### Network Errors
- No internet connection
- Request timeout
- Server unreachable

### Validation Errors
- Field-specific error messages
- Real-time validation feedback
- Form submission prevention on errors

### Backend Errors
- Server-side validation failures
- Duplicate email/phone detection
- Custom error message display

## State Management

### AuthState
```dart
class AuthState {
  final AuthStatus status;     // initial, authenticated, unauthenticated, loading
  final User? user;           // Current user data
  final String? errorMessage; // Error feedback
  final bool isLoading;       // Loading state
}
```

### Provider Usage
```dart
// Watch authentication state
final authState = ref.watch(authProvider);

// Access loading state
final isLoading = ref.watch(authLoadingProvider);

// Access current user
final user = ref.watch(currentUserProvider);
```

## Usage Example

### Registration Flow
1. User fills out form fields
2. Client-side validation runs on form submission
3. If valid, AuthProvider.register() is called
4. HTTP request sent to backend
5. Response processed and state updated
6. Success: Navigate to KYC verification
7. Error: Show error message to user

## Dependencies Added
- `http: ^1.1.0` - For HTTP requests

## Files Modified/Created
- `lib/models/api_response.dart` - Created
- `lib/models/user.dart` - Created
- `lib/models/register_request.dart` - Created
- `lib/core/config/api_config.dart` - Created
- `lib/core/services/http_client_service.dart` - Created
- `lib/core/services/auth_service.dart` - Created
- `lib/core/utils/validation_helper.dart` - Created
- `lib/providers/auth_provider.dart` - Created
- `lib/screens/auth/signup_screen.dart` - Modified
- `pubspec.yaml` - Updated with http dependency

## Testing

The implementation has been tested for:
- Compilation without errors
- Form validation functionality
- State management integration
- Error handling paths

## Next Steps

1. **Testing**: Implement unit tests for validation logic and API services
2. **Login Integration**: Apply similar patterns to login screen
3. **Persistence**: Add secure storage for auth tokens
4. **Error Recovery**: Implement retry mechanisms for network failures
5. **Performance**: Add request caching and optimization

## Security Considerations

- Passwords are not stored locally
- Auth tokens should be stored securely (implement when adding persistence)
- All API communication uses HTTPS
- Input validation prevents malicious data submission
