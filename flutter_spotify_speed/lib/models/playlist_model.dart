class SpotifyPlaylist {
  final String id;
  final String name;
  final String uri;
  final String? imageUrl;
  final int trackCount;
  final String? ownerName;

  const SpotifyPlaylist({
    required this.id,
    required this.name,
    required this.uri,
    this.imageUrl,
    required this.trackCount,
    this.ownerName,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0]['url'];
    }

    return SpotifyPlaylist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sem nome',
      uri: json['uri'] ?? '',
      imageUrl: imageUrl,
      trackCount: json['tracks']?['total'] ?? 0,
      ownerName: json['owner']?['display_name'],
    );
  }
}

/// Configuration: a playlist tied to a speed threshold
class PlaylistConfig {
  final String id;
  final SpotifyPlaylist playlist;
  final double minSpeedKmh;
  final double? maxSpeedKmh;

  const PlaylistConfig({
    required this.id,
    required this.playlist,
    required this.minSpeedKmh,
    this.maxSpeedKmh,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'playlistId': playlist.id,
        'playlistName': playlist.name,
        'playlistUri': playlist.uri,
        'playlistImageUrl': playlist.imageUrl,
        'playlistTrackCount': playlist.trackCount,
        'playlistOwnerName': playlist.ownerName,
        'minSpeedKmh': minSpeedKmh,
        'maxSpeedKmh': maxSpeedKmh,
      };

  factory PlaylistConfig.fromJson(Map<String, dynamic> json) {
    return PlaylistConfig(
      id: json['id'],
      playlist: SpotifyPlaylist(
        id: json['playlistId'],
        name: json['playlistName'],
        uri: json['playlistUri'],
        imageUrl: json['playlistImageUrl'],
        trackCount: json['playlistTrackCount'] ?? 0,
        ownerName: json['playlistOwnerName'],
      ),
      minSpeedKmh: (json['minSpeedKmh'] as num).toDouble(),
      maxSpeedKmh: json['maxSpeedKmh'] != null
          ? (json['maxSpeedKmh'] as num).toDouble()
          : null,
    );
  }
}
