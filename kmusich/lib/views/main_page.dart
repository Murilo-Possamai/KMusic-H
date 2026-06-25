import 'package:flutter/material.dart';
import 'package:kmusich/auth_service.dart';
import 'package:kmusich/views/login_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  void sair(BuildContext context) {
    authService.value.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tela Principal',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => sair(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
