import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/track_model.dart';
import '../models/playlist_model.dart';
import '../theme.dart';

class NowPlayingCard extends StatelessWidget {
  final CurrentTrack? track;
  final PlaylistConfig? activeConfig;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onRewind;
  final VoidCallback? onFastForward;

  const NowPlayingCard({
    super.key,
    this.track,
    this.activeConfig,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onRewind,
    this.onFastForward,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Active playlist card
        if (activeConfig != null) _buildPlaylistCard(context),
        const SizedBox(height: 12),
        // Now playing card
        _buildNowPlayingCard(context),
        const SizedBox(height: 12),
        // Controls
        _buildControls(context),
      ],
    );
  }

  Widget _buildPlaylistCard(BuildContext context) {
    final config = activeConfig!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Playlist image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: config.playlist.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: config.playlist.imageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 52,
                    height: 52,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.music_note,
                        color: AppColors.textMuted),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLAYLIST · ${config.minSpeedKmh.toInt()}KM/H',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  config.playlist.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${config.minSpeedKmh.toInt()}KM/H',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.sync, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  Widget _buildNowPlayingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Album image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: track?.albumImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: track!.albumImageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 52,
                    height: 52,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.music_note,
                        color: AppColors.textMuted),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  track?.name.toUpperCase() ?? 'SEM MÚSICA',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  track?.artist ?? '—',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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

  Widget _buildControls(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.fast_rewind,
            onTap: onRewind,
            size: 22,
          ),
          _ControlButton(
            icon: Icons.skip_previous,
            onTap: onPrevious,
            size: 26,
          ),
          _PlayPauseButton(
            isPlaying: track?.isPlaying ?? false,
            onTap: onPlayPause,
          ),
          _ControlButton(
            icon: Icons.skip_next,
            onTap: onNext,
            size: 26,
          ),
          _ControlButton(
            icon: Icons.fast_forward,
            onTap: onFastForward,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const _ControlButton({
    required this.icon,
    this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceVariant,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: size),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onTap;

  const _PlayPauseButton({required this.isPlaying, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.textPrimary,
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}
