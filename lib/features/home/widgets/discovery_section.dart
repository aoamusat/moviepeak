import 'package:flutter/material.dart';

import '../../../core/widgets/loading_card.dart';
import '../../../core/widgets/movie_poster_card.dart';
import '../../../data/models/movie.dart';

class DiscoverySection extends StatelessWidget {
  const DiscoverySection({
    super.key,
    required this.title,
    required this.movies,
    required this.loading,
    required this.error,
    required this.onMovieTap,
  });

  final String title;
  final List<Movie> movies;
  final bool loading;
  final Object? error;
  final ValueChanged<Movie> onMovieTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (loading)
          const SizedBox(
            height: 240,
            child: Row(
              children: [
                LoadingCard(),
                SizedBox(width: 12),
                LoadingCard(),
                SizedBox(width: 12),
                LoadingCard(),
              ],
            ),
          )
        else if (error != null)
          SizedBox(
            height: 60,
            child: Text(
              'Failed to load section.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else if (movies.isEmpty)
          SizedBox(
            height: 60,
            child: Text(
              'No movies available right now.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return MoviePosterCard(
                  movie: movie,
                  onTap: () => onMovieTap(movie),
                );
              },
            ),
          ),
      ],
    );
  }
}
