import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/movie.dart';
import '../../movie_details/screens/movie_details_screen.dart';
import '../providers/home_providers.dart';
import '../widgets/discovery_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingMoviesProvider);
    final under90 = ref.watch(under90MoviesProvider);
    final nollywood = ref.watch(nollywoodMoviesProvider);
    final becauseWatched = ref.watch(becauseWatchedMoviesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoviePeak'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(discoveryRepositoryProvider).clear();
          ref.invalidate(trendingMoviesProvider);
          ref.invalidate(under90MoviesProvider);
          ref.invalidate(nollywoodMoviesProvider);
          ref.invalidate(becauseWatchedMoviesProvider);
          await Future.wait([
            ref.read(trendingMoviesProvider.future),
            ref.read(under90MoviesProvider.future),
            ref.read(nollywoodMoviesProvider.future),
            ref.read(becauseWatchedMoviesProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                color: AppColors.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What are you in the mood for?',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover in seconds, then start watching.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            DiscoverySection(
              title: trendingBucket.title,
              movies: trending.value ?? const [],
              loading: trending.isLoading,
              error: trending.error,
              onMovieTap: (movie) => _openMovie(context, movie),
            ),
            const SizedBox(height: 20),
            DiscoverySection(
              title: under90Bucket.title,
              movies: under90.value ?? const [],
              loading: under90.isLoading,
              error: under90.error,
              onMovieTap: (movie) => _openMovie(context, movie),
            ),
            const SizedBox(height: 20),
            DiscoverySection(
              title: nollywoodBucket.title,
              movies: nollywood.value ?? const [],
              loading: nollywood.isLoading,
              error: nollywood.error,
              onMovieTap: (movie) => _openMovie(context, movie),
            ),
            const SizedBox(height: 20),
            DiscoverySection(
              title: becauseWatchedBucket.title,
              movies: becauseWatched.value ?? const [],
              loading: becauseWatched.isLoading,
              error: becauseWatched.error,
              onMovieTap: (movie) => _openMovie(context, movie),
            ),
          ],
        ),
      ),
    );
  }

  void _openMovie(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(initialMovie: movie)),
    );
  }
}
