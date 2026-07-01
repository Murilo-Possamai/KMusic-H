import 'package:flutter/material.dart';
import 'package:kmusich/auth_service.dart';
import 'package:kmusich/views/home_view.dart';
import 'package:kmusich/views/login_page.dart';
import 'package:kmusich/views/playlist_view.dart';
import 'package:kmusich/widgets/custom_buttom_nav.dart';
import 'package:kmusich/widgets/custom_top_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const HomeView(),
    const PlaylistView(),
    const Center(
      child: Text(
        'Configurações',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
  ];

  /* void sair(BuildContext context) {
    authService.value.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const CustomTopBar(),
              const SizedBox(height: 16),

              Expanded(
                child: IndexedStack(index: _currentIndex, children: _views),
              ),

              CustomBottomNav(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
