class MarketingBanner {
  MarketingBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.movieId,
    this.deeplink,
    this.priority = 0,
    this.source,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? movieId;
  final String? deeplink;
  final int priority;
  final String? source;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  factory MarketingBanner.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return MarketingBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'MoviePeak Banner',
      subtitle: json['subtitle']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      movieId: json['movieId']?.toString(),
      deeplink: json['deeplink']?.toString(),
      priority: parseInt(json['priority']),
      source: json['source']?.toString(),
    );
  }
}
