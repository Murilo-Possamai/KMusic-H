import 'package:flutter/material.dart';

class Playlist {
  final String title;
  final String speedCategory;
  final String targetSpeed;
  final String coverAsset;

  const Playlist({
    required this.title,
    required this.speedCategory,
    required this.targetSpeed,
    required this.coverAsset,
  });
}

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color cardBackground = Color(0xFF121212);

  final List<Playlist> _mockPlaylists = const [
    Playlist(
      title: 'DE NEGRÃO',
      speedCategory: 'PLAYLISTE - 110KM/H',
      targetSpeed: '20KM/H',
      coverAsset: 'assets/cover1.jpg',
    ),
    Playlist(
      title: 'REGGAEEE',
      speedCategory: 'PLAYLIST - 110KM/H',
      targetSpeed: '40KM/H',
      coverAsset: 'assets/cover2.png',
    ),
    Playlist(
      title: 'DE NEGRÃO',
      speedCategory: 'PLAYLIST - 110KM/H',
      targetSpeed: '80KM/H',
      coverAsset: 'assets/cover3.png',
    ),
    Playlist(
      title: 'PHONKISS',
      speedCategory: 'PLAYLIST - 110KM/H',
      targetSpeed: '110KM/H',
      coverAsset: 'assets/cover4.png',
    ),
    Playlist(
      title: 'TOKYO NIGHT',
      speedCategory: 'PLAYLIST - 110KM/H',
      targetSpeed: '130KM/H',
      coverAsset: 'assets/cover5.png',
    ),
    Playlist(
      title: 'SOCORRO DEUS',
      speedCategory: 'PLAYLIST - 110KM/H',
      targetSpeed: '220KM/H',
      coverAsset: 'assets/cover6.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _mockPlaylists.length,
          separatorBuilder: (context, index) => const Divider(
            color: neonCyan,
            height: 32,
            thickness: 1,
            indent: 76,
          ),
          itemBuilder: (context, index) {
            return _buildPlaylistItem(_mockPlaylists[index]);
          },
        ),
      ),
    );
  }

  Widget _buildPlaylistItem(Playlist playlist) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(playlist.coverAsset),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlist.speedCategory,
                style: const TextStyle(
                  color: neonCyan,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                playlist.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                playlist.targetSpeed,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.sync, color: Colors.white, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }
}
