import 'dart:ui';
import 'package:flutter/material.dart';

class BackgroundBlur extends StatelessWidget {
  final Color cor;
  final double opacidade;
  final Widget child;

  const BackgroundBlur({
    super.key,
    required this.cor,
    required this.opacidade,
    required this.child,
  });

  Widget _blob() {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
      child: Container(
        width: 500,
        height: 500,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cor.withOpacity(opacidade),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(top: -80, right: -80, child: _blob()),
        Positioned(bottom: -80, left: -80, child: _blob()),
        child,
      ],
    );
  }
}
