import '../../core/config/app_config.dart';
import '../models/movie.dart';
import 'movies_repository.dart';

class DiscoveryRepository {
  DiscoveryRepository(this._moviesRepository);

  final MoviesRepository _moviesRepository;
  final Map<String, _DiscoveryCacheEntry> _cache = {};

  Future<List<Movie>> getBucket(
    String bucket, {
    bool forceRefresh = false,
  }) async {
    final cached = _cache[bucket];
    final now = DateTime.now();
    if (!forceRefresh && cached != null) {
      final age = now.difference(cached.cachedAt);
      if (age.inMinutes < AppConfig.discoveryCacheMinutes) {
        return cached.movies;
      }
    }

    final movies = await _moviesRepository.discovery(bucket);
    _cache[bucket] = _DiscoveryCacheEntry(movies: movies, cachedAt: now);
    return movies;
  }

  void clear() => _cache.clear();
}

class _DiscoveryCacheEntry {
  _DiscoveryCacheEntry({required this.movies, required this.cachedAt});

  final List<Movie> movies;
  final DateTime cachedAt;
}
