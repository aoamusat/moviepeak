import '../../core/network/api_client.dart';
import '../models/paged_result.dart';
import '../models/watch_history_entry.dart';

class WatchHistoryRepository {
  WatchHistoryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> progress({
    required String movieId,
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    await _apiClient.post(
      '/watch-history/progress',
      data: {
        'movieId': movieId,
        'positionSeconds': positionSeconds,
        'durationSeconds': durationSeconds,
      },
    );
  }

  Future<PagedResult<WatchHistoryEntry>> myHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final payload = await _apiClient.get(
      '/watch-history/me',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return PagedResult.fromJson(payload, WatchHistoryEntry.fromJson);
  }
}
