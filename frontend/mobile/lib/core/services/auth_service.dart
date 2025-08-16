import '../../models/user.dart';
import '../../models/register_request.dart';
import '../../models/login_request.dart';
import '../../models/login_response.dart';
import '../../models/api_response.dart';
import 'http_client_service.dart';
import '../config/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HttpClientService _httpClient = HttpClientService();

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String nationalId,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Validate passwords match
      if (password != confirmPassword) {
        return ApiResponse<Map<String, dynamic>>.error(
          message: 'Passwords do not match',
        );
      }

      // Create register request (combine first and last name for fullName)
      final registerRequest = RegisterRequest(
        fullName: '$firstName $lastName',
        nicNo: nationalId,
        phoneNo: phoneNumber,
        email: email,
        password: password,
      );

      // Make API call
      final response = await _httpClient.post<Map<String, dynamic>>(
        ApiConfig.citizensRegister,
        body: registerRequest.toJson(),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<LoginResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Create login request
      final loginRequest = LoginRequest(username: username, password: password);

      final response = await _httpClient.post<LoginResponse>(
        ApiConfig.citizensLogin,
        body: loginRequest.toJson(),
        fromJson: (data) => LoginResponse.fromJson(data),
        useFormEncoding:
            true, // Try form encoding as backend might expect form data
      );

      // If login successful, store auth token
      if (response.success && response.data != null) {
        final token = response.data!.accessToken;
        _httpClient.setAuthToken(token);
      }

      return response;
    } catch (e) {
      return ApiResponse<LoginResponse>.error(
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<User>> getUserProfile() async {
    try {
      final response = await _httpClient.get<User>(
        ApiConfig.citizensMe,
        fromJson: (data) => User.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<User>.error(
        message: 'Failed to get user profile: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final response = await _httpClient.put<Map<String, dynamic>>(
        '/api/citizens/profile',
        body: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        message: 'Failed to update profile: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Validate passwords match
      if (newPassword != confirmPassword) {
        return ApiResponse<Map<String, dynamic>>.error(
          message: 'New passwords do not match',
        );
      }

      final response = await _httpClient.put<Map<String, dynamic>>(
        '/api/citizens/change-password',
        body: {'currentPassword': currentPassword, 'newPassword': newPassword},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        message: 'Failed to change password: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/api/citizens/forgot-password',
        body: {'email': email},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        message: 'Failed to send reset password email: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Validate passwords match
      if (newPassword != confirmPassword) {
        return ApiResponse<Map<String, dynamic>>.error(
          message: 'Passwords do not match',
        );
      }

      final response = await _httpClient.post<Map<String, dynamic>>(
        '/api/citizens/reset-password',
        body: {'token': token, 'newPassword': newPassword},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        message: 'Failed to reset password: ${e.toString()}',
      );
    }
  }

  void logout() {
    _httpClient.setAuthToken(null);
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    try {
      final response = await _httpClient.delete<Map<String, dynamic>>(
        '/api/citizens/delete-account',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      // Clear auth token on successful account deletion
      if (response.success) {
        logout();
      }

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        message: 'Failed to delete account: ${e.toString()}',
      );
    }
  }

  /// Validate the current user token by calling the /me endpoint
  Future<ApiResponse<User>> validateCurrentUser() async {
    try {
      final response = await _httpClient.get<User>(
        ApiConfig.citizensMe,
        fromJson: (data) => User.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      return ApiResponse<User>.error(
        message: 'Failed to validate user token: ${e.toString()}',
      );
    }
  }
}
