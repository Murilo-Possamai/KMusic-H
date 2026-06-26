import 'package:flutter/material.dart';

class LogoCard extends StatelessWidget {
  final double imageSize;

  const LogoCard({super.key, required this.imageSize});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/images/logo_tp.png',
      height: imageSize,
      fit: BoxFit.contain,
    );
  }
}
