import '../../core/network/api_client.dart';
import '../models/auth_tokens.dart';
import '../models/user_profile.dart';

class AuthSession {
  AuthSession({required this.tokens, required this.user});

  final AuthTokens tokens;
  final UserProfile user;
}

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> signup({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    final payload = await _apiClient.post(
      '/auth/signup',
      data: {
        'email': email,
        'password': password,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      },
      skipAuth: true,
    );

    return _parseAuthSession(payload);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final payload = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      skipAuth: true,
    );

    return _parseAuthSession(payload);
  }

  Future<AuthTokens> refreshToken(String refreshToken) async {
    final payload = await _apiClient.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      skipAuth: true,
    );

    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid refresh token response');
    }

    return AuthTokens.fromJson(payload);
  }

  Future<void> logout({String? refreshToken}) async {
    await _apiClient.post(
      '/auth/logout',
      data: {
        if (refreshToken != null && refreshToken.isNotEmpty)
          'refreshToken': refreshToken,
      },
    );
  }

  AuthSession _parseAuthSession(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid auth response');
    }

    final userJson = payload['user'];
    final tokensJson = payload['tokens'];

    if (userJson is! Map<String, dynamic>) {
      throw Exception('Missing user in auth response');
    }

    if (tokensJson is Map<String, dynamic>) {
      return AuthSession(
        tokens: AuthTokens.fromJson(tokensJson),
        user: UserProfile.fromJson(userJson),
      );
    }

    return AuthSession(
      tokens: AuthTokens.fromJson(payload),
      user: UserProfile.fromJson(userJson),
    );
  }
}
