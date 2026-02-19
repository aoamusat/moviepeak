import '../../core/network/api_client.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_status.dart';

class SubscriptionsRepository {
  SubscriptionsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<SubscriptionPlan>> getPlans() async {
    final payload = await _apiClient.get('/plans', skipAuth: true);

    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(SubscriptionPlan.fromJson)
          .toList(growable: false);
    }

    if (payload is Map<String, dynamic>) {
      final list = payload['items'] ?? payload['plans'] ?? payload['data'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(SubscriptionPlan.fromJson)
            .toList(growable: false);
      }
    }

    return <SubscriptionPlan>[];
  }

  Future<SubscriptionStatus?> getMySubscription() async {
    final payload = await _apiClient.get('/subscriptions/me');

    if (payload == null) {
      return null;
    }

    if (payload is Map<String, dynamic>) {
      if (payload.isEmpty) {
        return null;
      }
      return SubscriptionStatus.fromJson(payload);
    }

    return null;
  }

  Future<SubscriptionStatus> start(String planId) async {
    final payload = await _apiClient.post(
      '/subscriptions/start',
      data: {'planId': planId},
    );

    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid subscription payload');
    }

    return SubscriptionStatus.fromJson(payload);
  }

  Future<SubscriptionStatus> cancel() async {
    final payload = await _apiClient.post('/subscriptions/cancel', data: {});
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid subscription payload');
    }

    return SubscriptionStatus.fromJson(payload);
  }
}
