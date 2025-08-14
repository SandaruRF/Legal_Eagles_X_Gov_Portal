import 'package:flutter_riverpod/flutter_riverpod.dart';

// Navigation state for onboarding
class NavigationState {
  final int currentPageIndex;
  final bool isOnboardingComplete;

  const NavigationState({
    required this.currentPageIndex,
    required this.isOnboardingComplete,
  });

  NavigationState copyWith({
    int? currentPageIndex,
    bool? isOnboardingComplete,
  }) {
    return NavigationState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }
}

// Navigation provider
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier()
    : super(
        const NavigationState(currentPageIndex: 0, isOnboardingComplete: false),
      );

  void nextPage() {
    state = state.copyWith(currentPageIndex: state.currentPageIndex + 1);
  }

  void previousPage() {
    if (state.currentPageIndex > 0) {
      state = state.copyWith(currentPageIndex: state.currentPageIndex - 1);
    }
  }

  void completeOnboarding() {
    state = state.copyWith(isOnboardingComplete: true);
  }

  void resetOnboarding() {
    state = const NavigationState(
      currentPageIndex: 0,
      isOnboardingComplete: false,
    );
  }
}

// Provider instance
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });
