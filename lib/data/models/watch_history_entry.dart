import 'movie.dart';

class WatchHistoryEntry {
  WatchHistoryEntry({
    required this.id,
    required this.movieId,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.completed,
    required this.updatedAt,
    this.movie,
  });

  final String id;
  final String movieId;
  final int positionSeconds;
  final int durationSeconds;
  final bool completed;
  final DateTime updatedAt;
  final Movie? movie;

  factory WatchHistoryEntry.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final movieJson = json['movie'];

    return WatchHistoryEntry(
      id: json['id']?.toString() ?? '',
      movieId: json['movieId']?.toString() ?? '',
      positionSeconds: parseInt(json['positionSeconds']),
      durationSeconds: parseInt(json['durationSeconds']),
      completed: json['completed'] as bool? ?? false,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      movie:
          movieJson is Map<String, dynamic> ? Movie.fromJson(movieJson) : null,
    );
  }
}
