import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_provider.dart';
import '../models/playlist_model.dart';
import '../theme.dart';
import 'dart:math';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  List<SpotifyPlaylist> _userPlaylists = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    setState(() => _loading = true);
    final provider = context.read<AppProvider>();
    final playlists = await provider.apiService.getUserPlaylists();
    if (mounted) {
      setState(() {
        _userPlaylists = playlists;
        _loading = false;
      });
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddPlaylistSheet(
        playlists: _userPlaylists,
        onAdd: (config) async {
          await context.read<AppProvider>().addPlaylistConfig(config);
          if (mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showEditDialog(PlaylistConfig config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddPlaylistSheet(
        playlists: _userPlaylists,
        existingConfig: config,
        onAdd: (updated) async {
          await context.read<AppProvider>().updatePlaylistConfig(updated);
          if (mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'PLAYLISTS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showAddDialog,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.black, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Configure playlists para cada velocidade',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            // Configs list
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  if (provider.playlistConfigs.isEmpty) {
                    return _buildEmpty();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.playlistConfigs.length,
                    itemBuilder: (ctx, i) {
                      final config = provider.playlistConfigs[i];
                      return _ConfigCard(
                        config: config,
                        isActive: provider.activeConfig?.id == config.id,
                        onEdit: () => _showEditDialog(config),
                        onDelete: () =>
                            provider.removePlaylistConfig(config.id),
                        onPlay: () =>
                            provider.playPlaylist(config.playlist.uri),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
            child: const Icon(Icons.queue_music,
                color: AppColors.textMuted, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma playlist configurada',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque + para adicionar',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  final PlaylistConfig config;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPlay;

  const _ConfigCard({
    required this.config,
    required this.isActive,
    required this.onEdit,
    required this.onDelete,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.cardBorder,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Playlist image header
          if (config.playlist.imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: config.playlist.imageUrl!,
                    width: double.infinity,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                  if (isActive)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'ATIVO',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.playlist.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.speed,
                        color: AppColors.primary, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      'A partir de ${config.minSpeedKmh.toInt()} km/h',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (config.maxSpeedKmh != null) ...[
                      const Text(
                        ' até ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${config.maxSpeedKmh!.toInt()} km/h',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Editar',
                        color: AppColors.surfaceVariant,
                        textColor: AppColors.textPrimary,
                        onTap: onEdit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Tocar',
                        color: AppColors.primary,
                        textColor: Colors.black,
                        onTap: onPlay,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Container(
                        width: 38,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: AppColors.error, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remover playlist?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Remover "${config.playlist.name}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true) onDelete();
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// =================== Add/Edit Bottom Sheet ===================

class _AddPlaylistSheet extends StatefulWidget {
  final List<SpotifyPlaylist> playlists;
  final PlaylistConfig? existingConfig;
  final Function(PlaylistConfig) onAdd;

  const _AddPlaylistSheet({
    required this.playlists,
    this.existingConfig,
    required this.onAdd,
  });

  @override
  State<_AddPlaylistSheet> createState() => _AddPlaylistSheetState();
}

class _AddPlaylistSheetState extends State<_AddPlaylistSheet> {
  SpotifyPlaylist? _selectedPlaylist;
  double _minSpeed = 60;
  double? _maxSpeed;
  bool _hasMaxSpeed = false;
  final _searchController = TextEditingController();
  List<SpotifyPlaylist> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.playlists;
    if (widget.existingConfig != null) {
      final ec = widget.existingConfig!;
      _selectedPlaylist = ec.playlist;
      _minSpeed = ec.minSpeedKmh;
      _maxSpeed = ec.maxSpeedKmh;
      _hasMaxSpeed = _maxSpeed != null;
    }
    _searchController.addListener(() {
      final q = _searchController.text.toLowerCase();
      setState(() {
        _filtered = widget.playlists
            .where((p) => p.name.toLowerCase().contains(q))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _save() {
    if (_selectedPlaylist == null) return;
    final config = PlaylistConfig(
      id: widget.existingConfig?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      playlist: _selectedPlaylist!,
      minSpeedKmh: _minSpeed,
      maxSpeedKmh: _hasMaxSpeed ? _maxSpeed : null,
    );
    widget.onAdd(config);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingConfig != null;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isEdit ? 'EDITAR PLAYLIST' : 'ADICIONAR PLAYLIST',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // Playlist picker
                const Text(
                  'Playlist',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                // Search
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar playlist...',
                    hintStyle:
                        const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final p = _filtered[i];
                      final sel = _selectedPlaylist?.id == p.id;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: p.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: p.imageUrl!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 44,
                                  height: 44,
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(Icons.music_note,
                                      color: AppColors.textMuted),
                                ),
                        ),
                        title: Text(
                          p.name,
                          style: TextStyle(
                            color: sel
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${p.trackCount} músicas',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        trailing: sel
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primary)
                            : null,
                        onTap: () =>
                            setState(() => _selectedPlaylist = p),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Min speed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Velocidade mínima',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${_minSpeed.toInt()} km/h',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _minSpeed,
                  min: 0,
                  max: 200,
                  divisions: 40,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.surfaceVariant,
                  onChanged: (v) => setState(() => _minSpeed = v),
                ),
                const SizedBox(height: 8),
                // Max speed toggle
                Row(
                  children: [
                    Switch(
                      value: _hasMaxSpeed,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() {
                        _hasMaxSpeed = v;
                        if (v) _maxSpeed = _minSpeed + 40;
                      }),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Velocidade máxima',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                if (_hasMaxSpeed) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Text(
                        '${(_maxSpeed ?? _minSpeed + 40).toInt()} km/h',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _maxSpeed ?? _minSpeed + 40,
                    min: _minSpeed,
                    max: 300,
                    divisions: 60,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.surfaceVariant,
                    onChanged: (v) => setState(() => _maxSpeed = v),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _selectedPlaylist != null ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEdit ? 'SALVAR ALTERAÇÕES' : 'ADICIONAR PLAYLIST',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
