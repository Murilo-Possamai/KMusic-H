import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/speedometer_widget.dart';
import '../widgets/now_playing_card.dart';
import '../theme.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      if (provider.isLoggedIn && !provider.isTracking) {
        provider.startTracking();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (!provider.isLoggedIn) {
          return const LoginScreen();
        }

        final user = provider.userProfile;
        final userName = user?['display_name'] ?? 'Usuário';
        final avatarUrl = (user?['images'] as List?)?.isNotEmpty == true
            ? user!['images'][0]['url'] as String?
            : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceVariant,
                          border: Border.all(
                              color: AppColors.primary, width: 1.5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: avatarUrl != null
                            ? Image.network(avatarUrl, fit: BoxFit.cover)
                            : const Icon(Icons.person,
                                color: AppColors.textSecondary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          userName.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline,
                            color: AppColors.textSecondary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Speedometer
                SpeedometerWidget(speedKmh: provider.currentSpeedKmh),
                const SizedBox(height: 12),

                // GPS/Accel indicator + tracking toggle
                _buildStatusBar(context, provider),
                const SizedBox(height: 12),

                // Now Playing
                Expanded(
                  child: SingleChildScrollView(
                    child: NowPlayingCard(
                      track: provider.currentTrack,
                      activeConfig: provider.activeConfig,
                      onPlayPause: () => provider.togglePlayPause(),
                      onNext: () => provider.nextTrack(),
                      onPrevious: () => provider.previousTrack(),
                      onRewind: () => provider.previousTrack(),
                      onFastForward: () => provider.nextTrack(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(BuildContext context, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Source indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  provider.velocitySource == VelocitySource.gps
                      ? Icons.location_on
                      : Icons.phone_android,
                  color: AppColors.accent,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  provider.velocitySource == VelocitySource.gps
                      ? 'GPS'
                      : 'Acelerômetro',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Tracking toggle
          GestureDetector(
            onTap: () {
              if (provider.isTracking) {
                provider.stopTracking();
              } else {
                provider.startTracking();
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: provider.isTracking
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: provider.isTracking
                      ? AppColors.primary
                      : AppColors.cardBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.isTracking
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    provider.isTracking ? 'Ativo' : 'Pausado',
                    style: TextStyle(
                      color: provider.isTracking
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
