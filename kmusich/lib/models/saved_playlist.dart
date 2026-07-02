/// Uma playlist do Spotify salva localmente com um km alvo associado.
class SavedPlaylist {
  final String id;
  final String name;
  final String uri;
  final String? imageUrl;
  final int targetKmh;

  const SavedPlaylist({
    required this.id,
    required this.name,
    required this.uri,
    this.imageUrl,
    required this.targetKmh,
  });

  SavedPlaylist copyWith({int? targetKmh}) => SavedPlaylist(
        id: id,
        name: name,
        uri: uri,
        imageUrl: imageUrl,
        targetKmh: targetKmh ?? this.targetKmh,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'uri': uri,
        'imageUrl': imageUrl,
        'targetKmh': targetKmh,
      };

  factory SavedPlaylist.fromMap(Map<String, dynamic> map) => SavedPlaylist(
        id: map['id'] as String,
        name: map['name'] as String,
        uri: map['uri'] as String,
        imageUrl: map['imageUrl'] as String?,
        targetKmh: map['targetKmh'] as int,
      );
}
