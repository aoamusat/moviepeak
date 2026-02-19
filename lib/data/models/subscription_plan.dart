class SubscriptionPlan {
  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceNgn,
    required this.billingPeriod,
    required this.maxQuality,
    required this.screens,
    required this.isActive,
  });

  final String id;
  final String name;
  final int priceNgn;
  final String billingPeriod;
  final String maxQuality;
  final int screens;
  final bool isActive;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return SubscriptionPlan(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Plan',
      priceNgn: parseInt(json['priceNgn']),
      billingPeriod: json['billingPeriod']?.toString() ?? 'MONTHLY',
      maxQuality: json['maxQuality']?.toString() ?? '720',
      screens: parseInt(json['screens']),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
