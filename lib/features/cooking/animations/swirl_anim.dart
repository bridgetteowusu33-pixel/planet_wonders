import 'dart:math' as math;

import 'package:flutter/material.dart';

class SwirlAnim extends StatelessWidget {
  const SwirlAnim({
    super.key,
    required this.progress,
    this.color = const Color(0x66FFFFFF),
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _SwirlPainter(progress: progress, color: color),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _SwirlPainter extends CustomPainter {
  const _SwirlPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = math.min(size.width, size.height) * 0.38;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..color = color;

    for (int i = 0; i < 3; i++) {
      final radius = maxRadius - i * 18;
      final sweep = (progress * 2.2 + i * 0.18).clamp(0.1, 1.0) * math.pi;
      final start = -math.pi / 2 + i * 0.55;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SwirlPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
