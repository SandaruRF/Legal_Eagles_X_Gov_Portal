import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../core/services/auth_service.dart';
import '../core/services/http_client_service.dart';

// Auth state enumeration
enum AuthStatus { initial, authenticated, unauthenticated, loading }

// Auth state class
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
}

// Auth provider class
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService, this._httpClient) : super(const AuthState());

  final AuthService _authService;
  final HttpClientService _httpClient;

  // Initialize the provider
  void initialize() {
    _httpClient.initialize();
    // You can check for stored auth token here if using local storage
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  // Register new user
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String nationalId,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        nationalId: nationalId,
        password: password,
        confirmPassword: confirmPassword,
      );

      state = state.copyWith(isLoading: false);

      if (response.success) {
        // Registration successful - user might need to verify email
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(errorMessage: response.message);
      }

      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed: ${e.toString()}',
      );
      return ApiResponse<Map<String, dynamic>>.error(message: e.toString());
    }
  }

  // Login user
  Future<ApiResponse<LoginResponse>> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.login(
        username: username,
        password: password,
      );

      if (response.success) {
        // Get user profile after successful login
        final profileResponse = await _authService.getUserProfile();

        if (profileResponse.success && profileResponse.data != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: profileResponse.data,
            isLoading: false,
            errorMessage: null,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            isLoading: false,
            errorMessage: null,
          );
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          errorMessage: response.message,
        );
      }

      return response;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: 'Login failed: ${e.toString()}',
      );
      return ApiResponse<LoginResponse>.error(message: e.toString());
    }
  }

  // Get user profile
  Future<void> getUserProfile() async {
    try {
      final response = await _authService.getUserProfile();

      if (response.success && response.data != null) {
        state = state.copyWith(user: response.data, errorMessage: null);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to get user profile: ${e.toString()}',
      );
    }
  }

  // Update user profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      if (response.success) {
        // Refresh user profile
        await getUserProfile();
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: response.success ? null : response.message,
      );

      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Update failed: ${e.toString()}',
      );
      return ApiResponse<Map<String, dynamic>>.error(message: e.toString());
    }
  }

  // Change password
  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: response.success ? null : response.message,
      );

      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Password change failed: ${e.toString()}',
      );
      return ApiResponse<Map<String, dynamic>>.error(message: e.toString());
    }
  }

  // Forgot password
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.forgotPassword(email: email);

      state = state.copyWith(
        isLoading: false,
        errorMessage: response.success ? null : response.message,
      );

      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send reset email: ${e.toString()}',
      );
      return ApiResponse<Map<String, dynamic>>.error(message: e.toString());
    }
  }

  // Logout user
  void logout() {
    _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // Delete account
  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.deleteAccount();

      if (response.success) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
      }

      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Account deletion failed: ${e.toString()}',
      );
      return ApiResponse<Map<String, dynamic>>.error(message: e.toString());
    }
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider instances
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final httpClientServiceProvider = Provider<HttpClientService>(
  (ref) => HttpClientService(),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final httpClient = ref.watch(httpClientServiceProvider);
  final notifier = AuthNotifier(authService, httpClient);
  notifier.initialize();
  return notifier;
});

// Computed providers for easy access
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});
