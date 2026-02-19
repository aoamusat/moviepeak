class MovieRequest {
  MovieRequest({
    required this.id,
    required this.title,
    required this.count,
    this.requestedBy,
  });

  final String id;
  final String title;
  final int count;
  final String? requestedBy;

  factory MovieRequest.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return MovieRequest(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      count: parseInt(json['count']),
      requestedBy: json['requesterUserId']?.toString(),
    );
  }
}
