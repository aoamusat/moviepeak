class PlaybackSession {
  PlaybackSession({required this.streamUrl, required this.playbackToken});

  final String streamUrl;
  final String playbackToken;

  factory PlaybackSession.fromJson(Map<String, dynamic> json) {
    return PlaybackSession(
      streamUrl: json['streamUrl']?.toString() ?? '',
      playbackToken: json['playbackToken']?.toString() ?? '',
    );
  }
}
