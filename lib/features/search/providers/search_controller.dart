import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/movie.dart';
import '../../../data/repositories/movies_repository.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.filters = const SearchFilters(),
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.hasSearched = false,
  });

  final String query;
  final SearchFilters filters;
  final List<Movie> results;
  final bool isLoading;
  final String? error;
  final bool hasSearched;

  SearchState copyWith({
    String? query,
    SearchFilters? filters,
    List<Movie>? results,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? hasSearched,
  }) {
    return SearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class SearchController extends StateNotifier<SearchState> {
  SearchController(this._moviesRepository) : super(const SearchState());

  final MoviesRepository _moviesRepository;

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void updateFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
  }

  Future<void> search() async {
    final query = state.query.trim();
    if (query.isEmpty) {
      state = state.copyWith(
        hasSearched: true,
        results: const [],
        error: 'Enter what you are in the mood for.',
      );
      return;
    }

    state =
        state.copyWith(isLoading: true, clearError: true, hasSearched: true);

    try {
      final result = await _moviesRepository.search(
        query: query,
        filters: state.filters,
        limit: 24,
      );

      state = state.copyWith(
        isLoading: false,
        results: result.items,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final searchControllerProvider =
    StateNotifierProvider.autoDispose<SearchController, SearchState>((ref) {
  return SearchController(ref.watch(moviesRepositoryProvider));
});
