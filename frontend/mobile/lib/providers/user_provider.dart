import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../core/services/auth_service.dart';

/// State for user profile data
class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserState({this.user, this.isLoading = false, this.error});

  UserState copyWith({User? user, bool? isLoading, String? error}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// User provider for managing user profile data
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  final AuthService _authService = AuthService();

  /// Fetch current user profile from /me endpoint
  Future<void> fetchUserProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.getUserProfile();

      if (response.success && response.data != null) {
        state = state.copyWith(
          user: response.data,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch user profile: ${e.toString()}',
      );
    }
  }

  /// Clear user data (used for logout)
  void clearUser() {
    state = const UserState();
  }

  /// Update user data manually (if needed after profile edit)
  void updateUser(User user) {
    state = state.copyWith(user: user, error: null);
  }
}

/// Provider for user state
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

/// Convenience provider to get just the user data
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(userProvider).user;
});

/// Convenience provider to check if user data is loading
final isUserLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoading;
});

/// Convenience provider to get user errors
final userErrorProvider = Provider<String?>((ref) {
  return ref.watch(userProvider).error;
});
