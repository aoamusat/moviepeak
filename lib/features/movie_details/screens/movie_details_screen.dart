import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/subscription_status.dart';
import '../../playback/screens/playback_screen.dart';
import '../../subscriptions/screens/plans_screen.dart';

class MovieDetailsScreen extends ConsumerStatefulWidget {
  const MovieDetailsScreen({super.key, required this.initialMovie});

  final Movie initialMovie;

  @override
  ConsumerState<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends ConsumerState<MovieDetailsScreen> {
  late Movie _movie;
  bool _loading = false;
  bool _watchlistBusy = false;

  @override
  void initState() {
    super.initState();
    _movie = widget.initialMovie;
    _refreshMovie();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionStatusProvider).valueOrNull;
    final hasAccess = _hasSubscriptionAccess(subscription);

    return Scaffold(
      appBar: AppBar(title: Text(_movie.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _movie.posterUrl == null || _movie.posterUrl!.isEmpty
                  ? Container(
                      color: AppColors.surface,
                      child:
                          const Icon(Icons.movie_creation_outlined, size: 40),
                    )
                  : Image.network(
                      _movie.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _movie.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '${_movie.releaseYear ?? 'N/A'} • ${_movie.durationMinutes ?? 0} mins • ${_movie.language ?? 'N/A'}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._movie.genres.map(
                (genre) => Chip(label: Text(genre)),
              ),
              ..._movie.tags.map(
                (tag) => Chip(label: Text(tag)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _movie.description ?? 'No description available.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          if (_loading) const LinearProgressIndicator(),
          if (hasAccess)
            PrimaryButton(
              label: 'Play',
              onPressed: () => _openPlayback(context),
            )
          else
            PrimaryButton(
              label: 'Subscribe to Watch',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PlansScreen()),
                );
              },
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _watchlistBusy ? null : _toggleWatchlist,
            icon: _watchlistBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_add_outlined),
            label: const Text('Toggle Watchlist'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _movie.trailerUrl == null || _movie.trailerUrl!.isEmpty
                ? null
                : _openTrailer,
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Watch Trailer'),
          ),
          if (!hasAccess) ...[
            const SizedBox(height: 8),
            Text(
              'Subscription required to start playback.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasSubscriptionAccess(SubscriptionStatus? subscription) {
    if (subscription == null) {
      return false;
    }

    return subscription.isActiveLike;
  }

  Future<void> _refreshMovie() async {
    setState(() {
      _loading = true;
    });

    try {
      final fresh =
          await ref.read(moviesRepositoryProvider).getMovie(_movie.id);
      if (!mounted) return;
      setState(() {
        _movie = fresh;
      });
    } catch (_) {
      // Keep initial payload if fetch fails.
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleWatchlist() async {
    setState(() {
      _watchlistBusy = true;
    });

    try {
      await ref.read(moviesRepositoryProvider).toggleWatchlist(_movie.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Watchlist updated.')),
      );
      ref.invalidate(watchlistProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _watchlistBusy = false;
        });
      }
    }
  }

  Future<void> _openTrailer() async {
    final trailer = _movie.trailerUrl;
    if (trailer == null || trailer.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(trailer);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openPlayback(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaybackScreen(movie: _movie)),
    );
  }
}
