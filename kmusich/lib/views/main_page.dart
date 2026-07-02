import 'package:flutter/material.dart';
import 'package:kmusich/auth_service.dart';
import 'package:kmusich/providers/app_provider.dart';
import 'package:kmusich/views/home_view.dart';
import 'package:kmusich/views/login_page.dart';
import 'package:kmusich/widgets/custom_buttom_nav.dart';
import 'package:kmusich/widgets/playlists_widget.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    HomeView(),
    PlaylistsWidget(),
    _SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: IndexedStack(index: _currentIndex, children: _views),
              ),
              CustomBottomNav(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _loadingSpotify = false;

  Future<void> _handleSpotifyLogin(AppProvider provider) async {
    setState(() => _loadingSpotify = true);
    try {
      await provider.login();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro Spotify: $e'),
          duration: const Duration(seconds: 10),
          backgroundColor: Colors.red[900],
        ));
      }
    } finally {
      if (mounted) setState(() => _loadingSpotify = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'CONFIGURAÇÕES',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // === SPOTIFY AUTH ===
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SPOTIFY',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        provider.isLoggedIn ? Icons.check_circle : Icons.cancel,
                        color: provider.isLoggedIn
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.isLoggedIn ? 'Conectado' : 'Desconectado',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                  if (provider.isLoggedIn && provider.userProfile != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${provider.userProfile!['display_name']} · ${provider.userProfile!['email']}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                  if (provider.lastAuthError != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        provider.lastAuthError!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 11),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (!provider.isLoggedIn)
                    ElevatedButton.icon(
                      onPressed: _loadingSpotify
                          ? null
                          : () => _handleSpotifyLogin(provider),
                      icon: _loadingSpotify
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.login),
                      label: const Text('Conectar Spotify'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => provider.logout(),
                      icon: const Icon(Icons.logout, color: Colors.white54),
                      label: const Text('Desconectar Spotify',
                          style: TextStyle(color: Colors.white54)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // === TOGGLE TROCA DE PLAYLIST ===
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                secondary:
                    const Icon(Icons.swap_horiz, color: Color(0xFF00E5FF)),
                title: const Text(
                  'Trocar playlist instantaneamente',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  provider.instantSwitch
                      ? 'Troca ao atingir a velocidade'
                      : 'Aguarda a música atual terminar',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: provider.instantSwitch,
                activeThumbColor: const Color(0xFF00E5FF),
                onChanged: (v) => provider.setInstantSwitch(v),
              ),
            ),
            const SizedBox(height: 12),

            // === LOGOUT FIREBASE ===
            ListTile(
              tileColor: const Color(0xFF121212),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Sair (Firebase)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                authService.value.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
