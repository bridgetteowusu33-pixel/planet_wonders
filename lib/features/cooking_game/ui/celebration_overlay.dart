import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/motion/motion_settings_provider.dart';
import '../../../core/theme/pw_theme.dart';

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.badgeTitle,
    required this.onDone,
  });

  final String badgeTitle;
  final VoidCallback onDone;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final AnimationController _badgeController;
  late final bool _reduceMotion;

  @override
  void initState() {
    super.initState();
    _reduceMotion = MotionUtil.isReducedFromContext(context);

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (!_reduceMotion) _confettiController.repeat();

    _badgeController = AnimationController(
      vsync: this,
      duration: _reduceMotion
          ? const Duration(milliseconds: 120)
          : const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context);

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.2),
        child: Stack(
          children: [
            if (!_reduceMotion)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ConfettiPainter(progress: _confettiController.value),
                    );
                  },
                ),
              ),
            Center(
              child: _reduceMotion
                  ? FadeTransition(opacity: _badgeController, child: card)
                  : ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _badgeController,
                        curve: Curves.elasticOut,
                      ),
                      child: card,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 8),
          Text(
            'Recipe Complete!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: PWColors.yellow.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.badgeTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: widget.onDone,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Done'),
            style: FilledButton.styleFrom(
              backgroundColor: PWColors.mint,
              minimumSize: const Size(150, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static const _colors = [
    PWColors.coral,
    PWColors.blue,
    PWColors.yellow,
    PWColors.mint,
    Color(0xFF9C27B0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const pieces = 64;
    for (int i = 0; i < pieces; i++) {
      final seed = i * 91.7;
      final x = (seed * 13.0) % size.width;
      final drift = math.sin((progress * math.pi * 2) + i) * 18;
      final y = ((progress * size.height * 1.25) + (i * 23)) % (size.height + 40) - 40;

      final paint = Paint()..color = _colors[i % _colors.length].withValues(alpha: 0.9);
      canvas.save();
      canvas.translate(x + drift, y);
      canvas.rotate((progress * math.pi * 4) + (i * 0.2));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 8 + (i % 3) * 4, height: 8 + (i % 2) * 6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
