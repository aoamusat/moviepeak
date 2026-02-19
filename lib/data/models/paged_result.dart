class PagedResult<T> {
  PagedResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;

  bool get hasMore => page * limit < total;

  factory PagedResult.fromJson(
    dynamic raw,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) {
        return value;
      }
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    if (raw is List) {
      return PagedResult<T>(
        items: raw
            .whereType<Map<String, dynamic>>()
            .map(parseItem)
            .toList(growable: false),
        page: 1,
        limit: raw.length,
        total: raw.length,
      );
    }

    if (raw is! Map<String, dynamic>) {
      return PagedResult<T>(items: [], page: 1, limit: 20, total: 0);
    }

    final possibleItems = raw['items'] ?? raw['data'] ?? raw['results'];
    final list = possibleItems is List ? possibleItems : <dynamic>[];

    return PagedResult<T>(
      items: list
          .whereType<Map<String, dynamic>>()
          .map(parseItem)
          .toList(growable: false),
      page: parseInt(raw['page'], 1),
      limit: parseInt(raw['limit'], list.length),
      total: parseInt(raw['total'], list.length),
    );
  }
}
