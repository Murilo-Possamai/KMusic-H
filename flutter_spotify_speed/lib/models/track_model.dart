class CurrentTrack {
  final String name;
  final String artist;
  final String? albumName;
  final String? albumImageUrl;
  final bool isPlaying;
  final int progressMs;
  final int durationMs;
  final String? contextUri;

  const CurrentTrack({
    required this.name,
    required this.artist,
    this.albumName,
    this.albumImageUrl,
    required this.isPlaying,
    required this.progressMs,
    required this.durationMs,
    this.contextUri,
  });

  factory CurrentTrack.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>;
    final artists = item['artists'] as List;
    final artistNames =
        artists.map((a) => a['name'] as String).toList().join(', ');
    final images = item['album']?['images'] as List?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0]['url'];
    }

    return CurrentTrack(
      name: item['name'] ?? '',
      artist: artistNames,
      albumName: item['album']?['name'],
      albumImageUrl: imageUrl,
      isPlaying: json['is_playing'] ?? false,
      progressMs: json['progress_ms'] ?? 0,
      durationMs: item['duration_ms'] ?? 0,
      contextUri: json['context']?['uri'],
    );
  }

  double get progressPercent =>
      durationMs > 0 ? progressMs / durationMs : 0.0;

  String get progressFormatted => _formatMs(progressMs);
  String get durationFormatted => _formatMs(durationMs);

  String _formatMs(int ms) {
    final s = ms ~/ 1000;
    final min = s ~/ 60;
    final sec = s % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}
