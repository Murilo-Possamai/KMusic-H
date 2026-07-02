import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color cardBackground = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Consumer<AppProvider>(
            builder: (_, provider, __) => _buildSpeedmeter(provider),
          ),
          const SizedBox(height: 16),
          Consumer<AppProvider>(
            builder: (_, provider, __) => _buildCurrentPlaylistCard(provider),
          ),
          const SizedBox(height: 16),
          Consumer<AppProvider>(
            builder: (_, provider, __) => _buildPlayerCard(provider),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSpeedmeter(AppProvider provider) {
    final speed = provider.currentSpeedKmh;
    final isTracking = provider.isTracking;
    return GestureDetector(
      onTap: () {
        if (isTracking) {
          provider.stopTracking();
        } else {
          provider.startTracking();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cardBackground,
              // ignore: deprecated_member_use
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isTracking ? 'DRIVING' : 'PARADO',
                  style: TextStyle(
                    color: isTracking ? neonCyan : Colors.white38,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isTracking ? Icons.gps_fixed : Icons.gps_off,
                  color: isTracking ? neonCyan : Colors.white24,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              speed.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 110,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'km/h',
              style: TextStyle(
                color: neonCyan,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTracking ? 'Toque para parar' : 'Toque para iniciar GPS',
              style: const TextStyle(color: Colors.white24, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlaylistCard(AppProvider provider) {
    final track = provider.currentTrack;
    final contextUri = track?.contextUri;
    // Tenta achar o nome da playlist pelo contextUri (ex: spotify:playlist:xxx)
    final playlistName = contextUri != null ? provider.currentPlaylistName : null;
    final imageUrl = track?.albumImageUrl;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _coverPlaceholder(),
                  )
                : _coverPlaceholder(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOCANDO AGORA',
                  style: TextStyle(
                    color: neonCyan,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  playlistName ?? (track != null ? 'Sem playlist' : 'Nenhuma'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  provider.currentPlaylistTargetKmh != null
                      ? '${provider.currentPlaylistTargetKmh} km/h'
                      : (track?.name ?? '—'),
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(AppProvider provider) {
    final track = provider.currentTrack;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: track?.albumImageUrl != null
                    ? Image.network(
                        track!.albumImageUrl!,
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _coverPlaceholder(),
                      )
                    : _coverPlaceholder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        color: neonCyan,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track?.name ?? 'Nada tocando',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track?.artist ?? '—',
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.shuffle_rounded,
                  color: provider.shuffleOn ? neonCyan : Colors.white38,
                  size: 28,
                ),
                onPressed: () => provider.toggleShuffle(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () => provider.previousTrack(),
              ),
              IconButton(
                icon: Icon(
                  track?.isPlaying == true
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  color: neonCyan,
                  size: 60,
                ),
                onPressed: () => provider.togglePlayPause(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () => provider.nextTrack(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, color: Colors.white24, size: 30),
      );
}
