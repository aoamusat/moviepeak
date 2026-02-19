class Movie {
  Movie({
    required this.id,
    required this.title,
    this.description,
    required this.genres,
    required this.tags,
    this.language,
    this.durationMinutes,
    this.releaseYear,
    this.region = 'NG',
    this.posterUrl,
    this.trailerUrl,
    this.streamUrl,
    this.isPublished = true,
  });

  final String id;
  final String title;
  final String? description;
  final List<String> genres;
  final List<String> tags;
  final String? language;
  final int? durationMinutes;
  final int? releaseYear;
  final String region;
  final String? posterUrl;
  final String? trailerUrl;
  final String? streamUrl;
  final bool isPublished;

  String get primaryGenre => genres.isEmpty ? 'Genre' : genres.first;

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic source) {
      if (source is List) {
        return source.map((e) => e.toString()).toList();
      }
      return <String>[];
    }

    int? parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      return int.tryParse(value?.toString() ?? '');
    }

    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      description: json['description']?.toString(),
      genres: parseList(json['genres']),
      tags: parseList(json['tags']),
      language: json['language']?.toString(),
      durationMinutes: parseInt(json['durationMinutes']),
      releaseYear: parseInt(json['releaseYear']),
      region: json['region']?.toString() ?? 'NG',
      posterUrl: json['posterUrl']?.toString(),
      trailerUrl: json['trailerUrl']?.toString(),
      streamUrl: json['streamUrl']?.toString(),
      isPublished: json['isPublished'] as bool? ?? true,
    );
  }
}
