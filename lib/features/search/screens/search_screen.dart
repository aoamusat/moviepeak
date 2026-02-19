import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/movie_poster_card.dart';
import '../../../data/models/movie.dart';
import '../../../data/repositories/movies_repository.dart';
import '../../movie_details/screens/movie_details_screen.dart';
import '../providers/search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _queryController = TextEditingController();
  final _yearController = TextEditingController();
  final _minDurationController = TextEditingController();
  final _maxDurationController = TextEditingController();

  String? _selectedGenre;
  String? _selectedLanguage;

  @override
  void dispose() {
    _queryController.dispose();
    _yearController.dispose();
    _minDurationController.dispose();
    _maxDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
        children: [
          TextField(
            controller: _queryController,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'What are you in the mood for?',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                ref.read(searchControllerProvider.notifier).setQuery(value),
            onSubmitted: (_) => _runSearch(),
          ),
          const SizedBox(height: 12),
          _FilterPanel(
            selectedGenre: _selectedGenre,
            selectedLanguage: _selectedLanguage,
            yearController: _yearController,
            minDurationController: _minDurationController,
            maxDurationController: _maxDurationController,
            onGenreChanged: (value) {
              setState(() {
                _selectedGenre = value;
              });
            },
            onLanguageChanged: (value) {
              setState(() {
                _selectedLanguage = value;
              });
            },
            onApply: _runSearch,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: state.isLoading ? null : _runSearch,
            icon: state.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: const Text('Search'),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 14),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (!state.hasSearched)
            const EmptyState(
              title: 'Search by mood, genre, or story type',
              subtitle:
                  'Use natural language and filters to find your next watch.',
            )
          else if (state.results.isEmpty)
            EmptyState(
              title: 'No results yet',
              subtitle:
                  'Couldn\'t find this movie now. Request it and we\'ll track demand.',
              action: ElevatedButton(
                onPressed: _requestMovie,
                child: const Text('Request this movie'),
              ),
            )
          else
            _SearchResultsGrid(
              movies: state.results,
              onTap: _openMovie,
            ),
        ],
      ),
    );
  }

  Future<void> _runSearch() async {
    final filters = SearchFilters(
      genre: _selectedGenre,
      language: _selectedLanguage,
      minDuration: int.tryParse(_minDurationController.text.trim()),
      maxDuration: int.tryParse(_maxDurationController.text.trim()),
      year: int.tryParse(_yearController.text.trim()),
      region: 'NG',
    );

    ref.read(searchControllerProvider.notifier).updateFilters(filters);
    await ref.read(searchControllerProvider.notifier).search();
  }

  Future<void> _requestMovie() async {
    final state = ref.read(searchControllerProvider);
    final titleController =
        TextEditingController(text: _queryController.text.trim());

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request movie'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Movie title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (submitted != true) {
      return;
    }

    final title = titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    try {
      await ref.read(requestsRepositoryProvider).create(title);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted.')),
      );
      ref.invalidate(topRequestsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }

    if (state.results.isEmpty) {
      ref.invalidate(topRequestsProvider);
    }
  }

  void _openMovie(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(initialMovie: movie)),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.selectedGenre,
    required this.selectedLanguage,
    required this.yearController,
    required this.minDurationController,
    required this.maxDurationController,
    required this.onGenreChanged,
    required this.onLanguageChanged,
    required this.onApply,
  });

  final String? selectedGenre;
  final String? selectedLanguage;
  final TextEditingController yearController;
  final TextEditingController minDurationController;
  final TextEditingController maxDurationController;
  final ValueChanged<String?> onGenreChanged;
  final ValueChanged<String?> onLanguageChanged;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: selectedGenre,
                  hint: const Text('Genre'),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Any genre')),
                    ...AppConstants.genres.map(
                      (genre) => DropdownMenuItem<String?>(
                        value: genre,
                        child: Text(genre),
                      ),
                    ),
                  ],
                  onChanged: onGenreChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: selectedLanguage,
                  hint: const Text('Language'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Any language'),
                    ),
                    ...AppConstants.languages.map(
                      (language) => DropdownMenuItem<String?>(
                        value: language,
                        child: Text(language),
                      ),
                    ),
                  ],
                  onChanged: onLanguageChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Min duration'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: maxDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max duration'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Year'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.tune),
              label: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsGrid extends StatelessWidget {
  const _SearchResultsGrid({required this.movies, required this.onTap});

  final List<Movie> movies;
  final ValueChanged<Movie> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return MoviePosterCard(
          movie: movies[index],
          onTap: () => onTap(movies[index]),
          width: 180,
        );
      },
    );
  }
}
