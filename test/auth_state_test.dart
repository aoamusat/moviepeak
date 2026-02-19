import 'package:flutter_test/flutter_test.dart';
import 'package:moviepeak_mobile/data/models/user_profile.dart';
import 'package:moviepeak_mobile/features/auth/controllers/auth_controller.dart';

void main() {
  group('AuthState.shouldShowOnboarding', () {
    test('returns true for authenticated user with empty preferences', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        onboardingSeen: false,
        user: UserProfile(
          id: 'u1',
          email: 'test@example.com',
          preferences: UserPreferences.empty(),
        ),
      );

      expect(state.shouldShowOnboarding, isTrue);
    });

    test('returns false when onboarding already seen', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        onboardingSeen: true,
        user: UserProfile(
          id: 'u1',
          email: 'test@example.com',
          preferences: UserPreferences.empty(),
        ),
      );

      expect(state.shouldShowOnboarding, isFalse);
    });
  });
}
