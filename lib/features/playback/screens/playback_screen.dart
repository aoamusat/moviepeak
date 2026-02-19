import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/movie.dart';

class PlaybackScreen extends ConsumerStatefulWidget {
  const PlaybackScreen({super.key, required this.movie});

  final Movie movie;

  @override
  ConsumerState<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends ConsumerState<PlaybackScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  Timer? _progressTimer;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrapPlayback();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _sendProgress();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.movie.title)),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? EmptyState(
                    title: 'Unable to start playback',
                    subtitle: _error!,
                  )
                : _chewieController == null
                    ? const EmptyState(
                        title: 'Playback unavailable',
                        subtitle: 'Try again in a moment.',
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Chewie(controller: _chewieController!),
                          ),
                        ),
                      ),
      ),
    );
  }

  Future<void> _bootstrapPlayback() async {
    try {
      final session =
          await ref.read(moviesRepositoryProvider).playback(widget.movie.id);

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(session.streamUrl),
        httpHeaders: {
          'Authorization': 'Bearer ${session.playbackToken}',
        },
      );

      await controller.initialize();

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        allowFullScreen: true,
        showControls: true,
        looping: false,
      );

      _videoController = controller;
      _chewieController = chewie;

      _progressTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _sendProgress();
      });

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _sendProgress() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final position = controller.value.position.inSeconds;
    final duration = controller.value.duration.inSeconds > 0
        ? controller.value.duration.inSeconds
        : (widget.movie.durationMinutes ?? 0) * 60;

    if (duration <= 0) {
      return;
    }

    try {
      await ref.read(watchHistoryRepositoryProvider).progress(
            movieId: widget.movie.id,
            positionSeconds: position,
            durationSeconds: duration,
          );
      ref.invalidate(watchHistoryProvider(1));
    } catch (_) {
      // Ignore periodic progress errors.
    }
  }
}
