import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

enum AuthStatus {
  loading,
  unauthenticated,
  authenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isBusy = false,
    this.onboardingSeen = false,
  });

  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;
  final bool isBusy;
  final bool onboardingSeen;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  bool get shouldShowOnboarding {
    if (!isAuthenticated || user == null) {
      return false;
    }

    if (!onboardingSeen && user!.preferences.isEmpty) {
      return true;
    }

    return false;
  }

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? errorMessage,
    bool clearError = false,
    bool? isBusy,
    bool? onboardingSeen,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isBusy: isBusy ?? this.isBusy,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required SecureStorageService secureStorageService,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _secureStorageService = secureStorageService,
        super(const AuthState(status: AuthStatus.loading));

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final SecureStorageService _secureStorageService;

  Future<void> bootstrap() async {
    try {
      final token = await _secureStorageService.readAccessToken();
      final onboardingSeen = await _secureStorageService.isOnboardingSeen();

      if (token == null || token.isEmpty) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          onboardingSeen: onboardingSeen,
        );
        return;
      }

      final user = await _userRepository.me();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        onboardingSeen: onboardingSeen,
      );
    } catch (_) {
      await _secureStorageService.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isBusy: true, clearError: true);

    try {
      final session =
          await _authRepository.login(email: email, password: password);
      await _secureStorageService.saveTokens(
        accessToken: session.tokens.accessToken,
        refreshToken: session.tokens.refreshToken,
      );

      final onboardingSeen = await _secureStorageService.isOnboardingSeen();

      state = AuthState(
        status: AuthStatus.authenticated,
        user: session.user,
        onboardingSeen: onboardingSeen,
      );
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    state = state.copyWith(isBusy: true, clearError: true);

    try {
      final session = await _authRepository.signup(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      await _secureStorageService.saveTokens(
        accessToken: session.tokens.accessToken,
        refreshToken: session.tokens.refreshToken,
      );

      final onboardingSeen = await _secureStorageService.isOnboardingSeen();

      state = AuthState(
        status: AuthStatus.authenticated,
        user: session.user,
        onboardingSeen: onboardingSeen,
      );
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> refreshProfile() async {
    if (!state.isAuthenticated) {
      return;
    }

    try {
      final user = await _userRepository.me();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<void> updateUser(UserProfile updated) async {
    state = state.copyWith(user: updated);
  }

  Future<void> setOnboardingSeen(bool value) async {
    await _secureStorageService.setOnboardingSeen(value);
    state = state.copyWith(onboardingSeen: value);
  }

  Future<void> logout() async {
    state = state.copyWith(isBusy: true, clearError: true);

    try {
      final refreshToken = await _secureStorageService.readRefreshToken();
      await _authRepository.logout(refreshToken: refreshToken);
    } catch (_) {
      // Ignore remote logout failures for client-side sign-out.
    }

    await _secureStorageService.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
