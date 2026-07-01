import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kmusich/auth_service.dart';
import 'package:kmusich/providers/app_provider.dart';
import 'package:kmusich/views/login_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('KMusic — Teste Backend'),
        actions: [
          TextButton(
            onPressed: () {
              authService.value.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Sair (Firebase)', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SpotifyAuthSection(provider: provider),
                if (provider.isLoggedIn) ...[
                  const SizedBox(height: 24),
                  _PlayerSection(provider: provider),
                  const SizedBox(height: 24),
                  _PlaylistSection(provider: provider),
                  const SizedBox(height: 24),
                  _VelocitySection(provider: provider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SpotifyAuthSection extends StatefulWidget {
  final AppProvider provider;
  const _SpotifyAuthSection({required this.provider});

  @override
  State<_SpotifyAuthSection> createState() => _SpotifyAuthSectionState();
}

class _SpotifyAuthSectionState extends State<_SpotifyAuthSection> {
  bool _loading = false;

  Future<void> _handleLogin() async {
    setState(() => _loading = true);
    try {
      await widget.provider.login();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro Spotify: $e'),
            duration: const Duration(seconds: 10),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    return _Card(
      title: 'Spotify Auth',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                p.isLoggedIn ? Icons.check_circle : Icons.cancel,
                color: p.isLoggedIn ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Text(
                p.isLoggedIn ? 'Conectado' : 'Desconectado',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          if (p.isLoggedIn && p.userProfile != null) ...[
            const SizedBox(height: 8),
            Text(
              '${p.userProfile!['display_name']} · ${p.userProfile!['email']}',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
          if (p.lastAuthError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                p.lastAuthError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (!p.isLoggedIn)
            ElevatedButton.icon(
              onPressed: _loading ? null : _handleLogin,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.login),
              label: const Text('Conectar Spotify'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: () => p.logout(),
              icon: const Icon(Icons.logout, color: Colors.white54),
              label: const Text('Desconectar', style: TextStyle(color: Colors.white54)),
            ),
        ],
      ),
    );
  }
}

class _PlayerSection extends StatelessWidget {
  final AppProvider provider;
  const _PlayerSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final track = provider.currentTrack;
    return _Card(
      title: 'Player',
      child: Column(
        children: [
          // Album art + info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: track?.albumImageUrl != null
                    ? Image.network(
                        track!.albumImageUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _artPlaceholder(),
                      )
                    : _artPlaceholder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: track == null
                    ? const Text(
                        'Nenhuma música tocando',
                        style: TextStyle(color: Colors.white54),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artist,
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (track.albumName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              track.albumName!,
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),

          // Progress bar
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: track?.progressPercent ?? 0,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF1DB954)),
            minHeight: 3,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                track?.progressFormatted ?? '0:00',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              Text(
                track?.durationFormatted ?? '0:00',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),

          // Controls
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => provider.previousTrack(),
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 36),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => provider.togglePlayPause(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1DB954),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    track?.isPlaying == true
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => provider.nextTrack(),
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _artPlaceholder() => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, color: Colors.white24, size: 32),
      );
}

class _PlaylistSection extends StatefulWidget {
  final AppProvider provider;
  const _PlaylistSection({required this.provider});

  @override
  State<_PlaylistSection> createState() => _PlaylistSectionState();
}

class _PlaylistSectionState extends State<_PlaylistSection> {
  @override
  void initState() {
    super.initState();
    if (widget.provider.playlists.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.provider.loadPlaylists();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    return _Card(
      title: 'Playlists',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: p.loadingPlaylists
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1DB954),
                          ),
                        ),
                      )
                    : p.playlists.isEmpty
                        ? const Text(
                            'Nenhuma playlist encontrada',
                            style: TextStyle(color: Colors.white54),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: p.selectedPlaylist?.id,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1A1A1A),
                              iconEnabledColor: Colors.white54,
                              hint: const Text(
                                'Selecionar playlist...',
                                style: TextStyle(color: Colors.white54),
                              ),
                              items: p.playlists.map((pl) {
                                return DropdownMenuItem<String>(
                                  value: pl.id,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: pl.imageUrl != null
                                            ? Image.network(
                                                pl.imageUrl!,
                                                width: 36,
                                                height: 36,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _thumbPlaceholder(),
                                              )
                                            : _thumbPlaceholder(),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              pl.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${pl.trackCount} músicas',
                                              style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (id) {
                                final pl = p.playlists
                                    .firstWhere((pl) => pl.id == id);
                                p.selectAndPlayPlaylist(pl);
                              },
                            ),
                          ),
              ),
              IconButton(
                onPressed: p.loadingPlaylists ? null : () => p.loadPlaylists(),
                icon: const Icon(Icons.refresh, color: Colors.white38),
                tooltip: 'Recarregar playlists',
              ),
            ],
          ),
          if (p.selectedPlaylist != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.play_circle_filled,
                    color: Color(0xFF1DB954), size: 14),
                const SizedBox(width: 6),
                Text(
                  'Tocando: ${p.selectedPlaylist!.name}',
                  style: const TextStyle(color: Color(0xFF1DB954), fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _thumbPlaceholder() => Container(
        width: 36,
        height: 36,
        color: Colors.white10,
        child: const Icon(Icons.queue_music, color: Colors.white24, size: 18),
      );
}

class _VelocitySection extends StatelessWidget {
  final AppProvider provider;
  const _VelocitySection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final source = provider.velocitySource.name.toUpperCase();
    return _Card(
      title: 'Velocidade',
      child: Column(
        children: [
          Text(
            '${provider.currentSpeedKmh.toStringAsFixed(1)} km/h',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          Text(
            'Fonte: $source',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: provider.isTracking ? null : () => provider.startTracking(),
                child: const Text('Iniciar GPS'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: provider.isTracking ? () => provider.stopTracking() : null,
                child: const Text('Parar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
