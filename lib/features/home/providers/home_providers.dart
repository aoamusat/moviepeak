import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/movie.dart';

class DiscoveryBucket {
  const DiscoveryBucket({required this.slug, required this.title});

  final String slug;
  final String title;
}

const trendingBucket = DiscoveryBucket(
  slug: 'trending',
  title: 'Trending in Nigeria',
);
const under90Bucket =
    DiscoveryBucket(slug: 'under-90', title: 'Under 90 Minutes');
const nollywoodBucket = DiscoveryBucket(
  slug: 'nollywood',
  title: 'Nollywood Picks',
);
const becauseWatchedBucket = DiscoveryBucket(
  slug: 'because-you-watched',
  title: 'Because You Watched',
);

final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(discoveryBucketProvider(trendingBucket.slug).future);
});

final under90MoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(discoveryBucketProvider(under90Bucket.slug).future);
});

final nollywoodMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(discoveryBucketProvider(nollywoodBucket.slug).future);
});

final becauseWatchedMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(discoveryBucketProvider(becauseWatchedBucket.slug).future);
});
