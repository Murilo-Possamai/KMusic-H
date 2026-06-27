import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class SpeedometerWidget extends StatefulWidget {
  final double speedKmh;

  const SpeedometerWidget({super.key, required this.speedKmh});

  @override
  State<SpeedometerWidget> createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speed = widget.speedKmh.clamp(0, 999).toInt();
    final digits = speed.toString().padLeft(3, '0');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF080808),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // DRIVING label
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (_, __) => Text(
              'DRIVING',
              style: GoogleFonts.sharetech(
                color: AppColors.accent.withOpacity(_glowAnimation.value),
                fontSize: 18,
                letterSpacing: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Digital digits
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: digits
                .split('')
                .map((d) => _DigitDisplay(digit: d))
                .toList(),
          ),
          const SizedBox(height: 20),
          // KM/H label
          Text(
            'KM/H',
            style: GoogleFonts.sharetech(
              color: AppColors.accent,
              fontSize: 14,
              letterSpacing: 6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitDisplay extends StatelessWidget {
  final String digit;

  const _DigitDisplay({required this.digit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F1F1F), width: 1),
      ),
      child: Text(
        digit,
        style: GoogleFonts.sharetech(
          color: AppColors.accent,
          fontSize: 80,
          fontWeight: FontWeight.w600,
          height: 1,
          shadows: [
            Shadow(
              color: AppColors.accent.withOpacity(0.6),
              blurRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
