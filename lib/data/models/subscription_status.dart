import 'subscription_plan.dart';

class SubscriptionStatus {
  SubscriptionStatus({
    required this.id,
    required this.status,
    this.plan,
    this.currentPeriodEnd,
    this.currentPeriodStart,
    this.startedAt,
    this.canceledAt,
  });

  final String id;
  final String status;
  final SubscriptionPlan? plan;
  final DateTime? currentPeriodEnd;
  final DateTime? currentPeriodStart;
  final DateTime? startedAt;
  final DateTime? canceledAt;

  bool get isActiveLike {
    final normalized = status.toUpperCase();
    if (normalized == 'ACTIVE') {
      return true;
    }
    if (normalized == 'CANCELED') {
      if (currentPeriodEnd == null) {
        return false;
      }
      return currentPeriodEnd!.isAfter(DateTime.now());
    }
    return false;
  }

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) {
        return null;
      }
      return DateTime.tryParse(value.toString());
    }

    final planJson = json['plan'];

    return SubscriptionStatus(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'NONE',
      plan: planJson is Map<String, dynamic>
          ? SubscriptionPlan.fromJson(planJson)
          : null,
      currentPeriodEnd: parseDate(json['currentPeriodEnd']),
      currentPeriodStart: parseDate(json['currentPeriodStart']),
      startedAt: parseDate(json['startedAt']),
      canceledAt: parseDate(json['canceledAt']),
    );
  }
}
