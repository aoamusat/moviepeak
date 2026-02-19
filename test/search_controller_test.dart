import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviepeak_mobile/data/models/movie.dart';
import 'package:moviepeak_mobile/data/models/paged_result.dart';
import 'package:moviepeak_mobile/data/repositories/movies_repository.dart';
import 'package:moviepeak_mobile/features/search/providers/search_controller.dart';

class _MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late _MockMoviesRepository repository;
  late SearchController controller;

  setUp(() {
    repository = _MockMoviesRepository();
    controller = SearchController(repository);
  });

  test('shows validation error when query is empty', () async {
    await controller.search();

    expect(controller.state.error, isNotNull);
    expect(controller.state.hasSearched, isTrue);
    expect(controller.state.results, isEmpty);
  });

  test('returns results for valid query', () async {
    when(
      () => repository.search(
        query: 'nollywood drama',
        filters: any(named: 'filters'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => PagedResult<Movie>(
        items: [
          Movie(
            id: 'm1',
            title: 'The Lagos Story',
            genres: const ['Drama'],
            tags: const ['Feel-good'],
          ),
        ],
        page: 1,
        limit: 20,
        total: 1,
      ),
    );

    controller.setQuery('nollywood drama');
    await controller.search();

    expect(controller.state.error, isNull);
    expect(controller.state.results, hasLength(1));
    expect(controller.state.results.first.title, 'The Lagos Story');
  });
}
