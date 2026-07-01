import 'package:flutter/material.dart';

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
          _buildSpeedmeter(),
          const SizedBox(height: 16),
          _buildCurrentPlaylistCard(),
          const SizedBox(height: 16),
          _buildPlayerCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSpeedmeter() {
    return Container(
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
          const Text(
            'DRIVING',
            style: TextStyle(
              color: neonCyan,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '112',
            style: TextStyle(
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
        ],
      ),
    );
  }

  Widget _buildCurrentPlaylistCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage('assets/images/playlist_cover.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PLAYLIST - 110km/h',
                  style: TextStyle(
                    color: neonCyan,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'DE NEGRÃO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '110KM/H',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard() {
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
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage('assets/pimp_cover.png'),
                    fit: BoxFit.cover,
                  ),
                ),
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
                    const Text(
                      'P.I.M.P',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '50 Cent',
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
                icon: const Icon(
                  Icons.fast_rewind_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 54,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.fast_forward_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
