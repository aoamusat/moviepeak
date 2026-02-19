import '../../core/network/api_client.dart';
import '../models/user_profile.dart';

class UserRepository {
  UserRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfile> me() async {
    final payload = await _apiClient.get('/users/me');
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid user payload');
    }

    return UserProfile.fromJson(payload);
  }

  Future<UserProfile> updateMe({
    String? name,
    String? phone,
    UserPreferences? preferences,
  }) async {
    final payload = await _apiClient.patch(
      '/users/me',
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (preferences != null) 'preferences': preferences.toJson(),
      },
    );

    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid user payload');
    }

    return UserProfile.fromJson(payload);
  }
}
