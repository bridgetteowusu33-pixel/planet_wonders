import 'dart:math' as math;

import 'package:flutter/material.dart';

class EffectsPainter extends CustomPainter {
  EffectsPainter({
    required this.hintGlowPoint,
    required this.showCompletionSparkles,
    required this.sparklePositions,
    required this.sparklePhase,
    required this.reduceMotion,
    required this.repaintTick,
    this.segmentBurstCenter,
    this.segmentBurstPhase = 0,
  });

  final Offset? hintGlowPoint;
  final bool showCompletionSparkles;
  final List<Offset> sparklePositions;
  final double sparklePhase;
  final bool reduceMotion;
  final int repaintTick;
  final Offset? segmentBurstCenter;
  final double segmentBurstPhase;

  static const _hintColor = Color(0xFFFFB34A);
  static const _sparkleColors = <Color>[
    Color(0xFFFFD54A),
    Color(0xFFFF8364),
    Color(0xFF7ED9B3),
    Color(0xFF8CC8FF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintHint(canvas);
    _paintSegmentBurst(canvas);

    if (!showCompletionSparkles || reduceMotion) return;
    _paintSparkles(canvas);
  }

  void _paintHint(Canvas canvas) {
    final center = hintGlowPoint;
    if (center == null) return;

    final pulse = reduceMotion
        ? 0.55
        : (0.35 + 0.65 * (0.5 + 0.5 * math.sin(sparklePhase * math.pi * 2)));

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = _hintColor.withValues(alpha: 0.26 + pulse * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawCircle(center, 10 + pulse * 11, paint);
  }

  void _paintSparkles(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < sparklePositions.length; i++) {
      final center = sparklePositions[i];
      final offsetPhase = (sparklePhase + i * 0.137) % 1;
      final scale = 0.65 + 0.55 * math.sin(offsetPhase * math.pi);
      final angle = offsetPhase * math.pi * 2;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.scale(scale, scale);

      paint.color = _sparkleColors[i % _sparkleColors.length];
      _drawSparkle(canvas, paint, 6.5);
      canvas.restore();
    }
  }

  void _paintSegmentBurst(Canvas canvas) {
    final center = segmentBurstCenter;
    if (center == null || reduceMotion || segmentBurstPhase <= 0) return;

    final t = segmentBurstPhase.clamp(0.0, 1.0);
    // Scale up then fade out.
    final scale = t < 0.3 ? t / 0.3 : 1.0;
    final alpha = t < 0.3 ? 1.0 : 1.0 - ((t - 0.3) / 0.7);

    final paint = Paint()..style = PaintingStyle.fill;
    const burstCount = 5;
    const burstRadius = 28.0;

    for (var i = 0; i < burstCount; i++) {
      final angle = (i / burstCount) * math.pi * 2 + t * math.pi;
      final dist = burstRadius * scale;
      final pos = Offset(
        center.dx + math.cos(angle) * dist,
        center.dy + math.sin(angle) * dist,
      );
      paint.color =
          _sparkleColors[i % _sparkleColors.length].withValues(alpha: alpha);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + t * math.pi);
      canvas.scale(scale * 0.8, scale * 0.8);
      _drawSparkle(canvas, paint, 5.5);
      canvas.restore();
    }
  }

  void _drawSparkle(Canvas canvas, Paint paint, double radius) {
    final path = Path()
      ..moveTo(0, -radius)
      ..lineTo(radius * 0.42, 0)
      ..lineTo(0, radius)
      ..lineTo(-radius * 0.42, 0)
      ..close();

    final cross = Path()
      ..moveTo(-radius, 0)
      ..lineTo(0, radius * 0.30)
      ..lineTo(radius, 0)
      ..lineTo(0, -radius * 0.30)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(cross, paint);
  }

  @override
  bool shouldRepaint(covariant EffectsPainter oldDelegate) {
    return oldDelegate.repaintTick != repaintTick ||
        oldDelegate.hintGlowPoint != hintGlowPoint ||
        oldDelegate.showCompletionSparkles != showCompletionSparkles ||
        oldDelegate.sparklePhase != sparklePhase ||
        oldDelegate.reduceMotion != reduceMotion ||
        oldDelegate.segmentBurstCenter != segmentBurstCenter ||
        oldDelegate.segmentBurstPhase != segmentBurstPhase;
  }
}
