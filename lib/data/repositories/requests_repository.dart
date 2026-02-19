import '../../core/network/api_client.dart';
import '../models/movie_request.dart';

class RequestsRepository {
  RequestsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<MovieRequest> create(String title) async {
    final payload = await _apiClient.post('/requests', data: {'title': title});
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid request payload');
    }

    return MovieRequest.fromJson(payload);
  }

  Future<List<MovieRequest>> top() async {
    final payload = await _apiClient.get('/requests/top', skipAuth: true);

    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(MovieRequest.fromJson)
          .toList(growable: false);
    }

    if (payload is Map<String, dynamic>) {
      final list = payload['items'] ?? payload['requests'] ?? payload['data'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(MovieRequest.fromJson)
            .toList(growable: false);
      }
    }

    return <MovieRequest>[];
  }
}
