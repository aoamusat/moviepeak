import '../../core/network/api_client.dart';
import '../models/movie.dart';
import '../models/paged_result.dart';
import '../models/playback_session.dart';

class SearchFilters {
  const SearchFilters({
    this.genre,
    this.language,
    this.minDuration,
    this.maxDuration,
    this.year,
    this.region,
  });

  final String? genre;
  final String? language;
  final int? minDuration;
  final int? maxDuration;
  final int? year;
  final String? region;

  Map<String, dynamic> toQuery() {
    return {
      if (genre != null && genre!.isNotEmpty) 'genre': genre,
      if (language != null && language!.isNotEmpty) 'language': language,
      if (minDuration != null) 'minDuration': minDuration,
      if (maxDuration != null) 'maxDuration': maxDuration,
      if (year != null) 'year': year,
      if (region != null && region!.isNotEmpty) 'region': region,
    };
  }
}

class MoviesRepository {
  MoviesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PagedResult<Movie>> getMovies({int page = 1, int limit = 20}) async {
    final payload = await _apiClient.get(
      '/movies',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      skipAuth: true,
    );

    return PagedResult.fromJson(payload, Movie.fromJson);
  }

  Future<Movie> getMovie(String movieId) async {
    final payload = await _apiClient.get('/movies/$movieId', skipAuth: true);
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid movie payload');
    }
    return Movie.fromJson(payload);
  }

  Future<void> toggleWatchlist(String movieId) async {
    await _apiClient.post('/movies/$movieId/watchlist', data: {});
  }

  Future<PagedResult<Movie>> getWatchlist(
      {int page = 1, int limit = 20}) async {
    final payload = await _apiClient.get(
      '/watchlist/me',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return PagedResult.fromJson(payload, Movie.fromJson);
  }

  Future<PagedResult<Movie>> search({
    required String query,
    SearchFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    final payload = await _apiClient.get(
      '/search',
      queryParameters: {
        'q': query,
        ...?filters?.toQuery(),
        'page': page,
        'limit': limit,
      },
      skipAuth: true,
    );

    return PagedResult.fromJson(payload, Movie.fromJson);
  }

  Future<List<Movie>> discovery(String bucket) async {
    final payload = await _apiClient.get('/discovery/$bucket', skipAuth: true);

    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(Movie.fromJson)
          .toList(growable: false);
    }

    if (payload is Map<String, dynamic>) {
      final list = payload['items'] ?? payload['results'] ?? payload['movies'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(Movie.fromJson)
            .toList(growable: false);
      }
    }

    return <Movie>[];
  }

  Future<PlaybackSession> playback(String movieId) async {
    final payload = await _apiClient.get('/movies/$movieId/playback');
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid playback payload');
    }

    return PlaybackSession.fromJson(payload);
  }
}
