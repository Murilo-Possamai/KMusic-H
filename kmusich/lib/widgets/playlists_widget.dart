import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist_model.dart';
import '../models/saved_playlist.dart';
import '../providers/app_provider.dart';
import '../services/playlist_storage_service.dart';

class PlaylistsWidget extends StatefulWidget {
  const PlaylistsWidget({super.key});

  @override
  State<PlaylistsWidget> createState() => _PlaylistsWidgetState();
}

class _PlaylistsWidgetState extends State<PlaylistsWidget> {
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color cardBackground = Color(0xFF121212);

  final PlaylistStorageService _storage = PlaylistStorageService();

  List<SavedPlaylist> _saved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _storage.getAll();
    if (!mounted) return;
    setState(() {
      _saved = items;
      _loading = false;
    });
  }

  //botao de maisze

  Future<void> _onAddPressed() async {
    final provider = context.read<AppProvider>();

    // Não conectado no Spotify avisa para conectar nas Configuracoes
    if (!provider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conecte sua conta Spotify nas Configurações primeiro.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Conecta abre o picker com as playlists do spotify.
    final chosen = await _showPlaylistPicker(provider);
    if (chosen == null || !mounted) return;

    final km = await _askKm();
    if (km == null || !mounted) return;

    await _storage.insert(SavedPlaylist(
      id: chosen.id,
      name: chosen.name,
      uri: chosen.uri,
      imageUrl: chosen.imageUrl,
      targetKmh: km,
    ));
    await _load();
    if (mounted) await context.read<AppProvider>().reloadSavedPlaylists();
  }

  Future<SpotifyPlaylist?> _showPlaylistPicker(AppProvider provider) {
    return showModalBottomSheet<SpotifyPlaylist>(
      context: context,
      backgroundColor: cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FutureBuilder<List<SpotifyPlaylist>>(
          future: provider.apiService.getUserPlaylists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: neonCyan),
                ),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Erro: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }
            final playlists = snapshot.data ?? [];
            if (playlists.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Nenhuma playlist encontrada',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              );
            }
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (context, controller) {
                return ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  itemCount: playlists.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'ESCOLHA UMA PLAYLIST',
                          style: TextStyle(
                            color: neonCyan,
                            fontSize: 13,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    final pl = playlists[index - 1];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: _cover(pl.imageUrl, 48),
                      title: Text(
                        pl.name,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        pl.trackCount > 0 ? '${pl.trackCount} músicas' : '',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                      onTap: () => Navigator.pop(context, pl),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<int?> _askKm({int? initial}) {
    final controller =
        TextEditingController(text: initial != null ? '$initial' : '');
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardBackground,
          title: const Text(
            'Velocidade alvo (km/h)',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'ex: 110',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: neonCyan),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                final km = int.tryParse(controller.text.trim());
                if (km != null && km > 0) Navigator.pop(context, km);
              },
              child: const Text('Salvar', style: TextStyle(color: neonCyan)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editKm(SavedPlaylist playlist) async {
    final km = await _askKm(initial: playlist.targetKmh);
    if (km == null) return;
    await _storage.updateKm(playlist.id, km);
    await _load();
    if (mounted) await context.read<AppProvider>().reloadSavedPlaylists();
  }

  Future<void> _delete(SavedPlaylist playlist) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackground,
        title: const Text('Remover playlist',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Text(
          'Remover "${playlist.name}" da lista?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _storage.delete(playlist.id);
    await _load();
    if (mounted) await context.read<AppProvider>().reloadSavedPlaylists();
  }

  // === UI ===

  Widget _cover(String? url, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url != null
          ? Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _coverPlaceholder(size),
            )
          : _coverPlaceholder(size),
    );
  }

  Widget _coverPlaceholder(double size) => Container(
        width: size,
        height: size,
        color: Colors.white10,
        child: const Icon(Icons.queue_music, color: Colors.white24),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MINHAS PLAYLISTS',
                  style: TextStyle(
                    color: neonCyan,
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: neonCyan,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: _onAddPressed,
                    tooltip: 'Adicionar playlist do Spotify',
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: neonCyan));
    }
    if (_saved.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhuma playlist salva.\nToque no + para adicionar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, height: 1.5),
          ),
        ),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _saved.length,
      separatorBuilder: (_, __) => const Divider(
        color: neonCyan,
        height: 28,
        thickness: 1,
        indent: 64,
      ),
      itemBuilder: (context, index) => _buildItem(_saved[index]),
    );
  }

  Widget _buildItem(SavedPlaylist pl) {
    return Row(
      children: [
        _cover(pl.imageUrl, 56),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pl.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${pl.targetKmh} km/h',
                style: const TextStyle(color: neonCyan, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
          onPressed: () => _editKm(pl),
          tooltip: 'Editar km',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline,
              color: Colors.redAccent, size: 20),
          onPressed: () => _delete(pl),
          tooltip: 'Remover',
        ),
      ],
    );
  }
}
