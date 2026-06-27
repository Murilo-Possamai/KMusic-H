import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/velocity_service.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final user = provider.userProfile;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'CONFIGURAÇÕES',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                // Profile card
                if (provider.isLoggedIn && user != null)
                  _buildProfileCard(context, user, provider),

                const SizedBox(height: 20),
                _buildSection('SENSOR DE VELOCIDADE', [
                  _SettingSwitch(
                    icon: Icons.location_on,
                    title: 'Usar GPS',
                    subtitle: 'Mais preciso para dirigir',
                    value: provider.useGPS,
                    onChanged: (v) => provider.setUseGPS(v),
                  ),
                  _SettingSwitch(
                    icon: Icons.phone_android,
                    title: 'Usar Acelerômetro',
                    subtitle: 'Backup quando GPS indisponível',
                    value: !provider.useGPS,
                    onChanged: (v) => provider.setUseGPS(!v),
                  ),
                ]),

                const SizedBox(height: 20),
                _buildSection('RASTREAMENTO', [
                  _SettingItem(
                    icon: Icons.speed,
                    title: provider.isTracking
                        ? 'Parar rastreamento'
                        : 'Iniciar rastreamento',
                    subtitle: provider.isTracking
                        ? 'Velocidade sendo detectada'
                        : 'Toque para ativar',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: provider.isTracking
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        provider.isTracking ? 'Ativo' : 'Inativo',
                        style: TextStyle(
                          color: provider.isTracking
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      if (provider.isTracking) {
                        provider.stopTracking();
                      } else {
                        provider.startTracking();
                      }
                    },
                  ),
                ]),

                const SizedBox(height: 20),
                _buildSection('SOBRE', [
                  _SettingItem(
                    icon: Icons.info_outline,
                    title: 'Spotify Speed',
                    subtitle: 'Versão 1.0.0',
                    onTap: () {},
                  ),
                  _SettingItem(
                    icon: Icons.music_note,
                    title: 'Spotify API',
                    subtitle: 'Client ID: 579cf839...',
                    onTap: () {},
                  ),
                ]),

                if (provider.isLoggedIn) ...[
                  const SizedBox(height: 20),
                  _buildSection('CONTA', [
                    _SettingItem(
                      icon: Icons.logout,
                      title: 'Sair do Spotify',
                      subtitle: 'Desconectar conta',
                      iconColor: AppColors.error,
                      onTap: () => _confirmLogout(context, provider),
                    ),
                  ]),
                ],

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context, Map<String, dynamic> user, AppProvider provider) {
    final images = user['images'] as List?;
    final avatarUrl =
        images != null && images.isNotEmpty ? images[0]['url'] : null;
    final name = user['display_name'] ?? 'Usuário';
    final email = user['email'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl != null
                ? Image.network(avatarUrl, fit: BoxFit.cover)
                : const Icon(Icons.person,
                    color: AppColors.textSecondary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Conectado ao Spotify',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    const Divider(
                      height: 1,
                      color: AppColors.divider,
                      indent: 52,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(
      BuildContext context, AppProvider provider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sair?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Tem certeza que quer desconectar?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true) provider.logout();
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (iconColor ?? AppColors.primary).withOpacity(0.12),
        ),
        child: Icon(icon,
            color: iconColor ?? AppColors.primary, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}
