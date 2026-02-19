import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

class UsageProgressCard extends StatelessWidget {
  const UsageProgressCard({
    super.key,
    required this.usedMinutes,
    required this.limitMinutes,
  });

  final int usedMinutes;

  /// 0 means unlimited.
  final int limitMinutes;

  @override
  Widget build(BuildContext context) {
    final tc = PWThemeColors.of(context);
    final hasLimit = limitMinutes > 0;
    final fraction =
        hasLimit ? (usedMinutes / limitMinutes).clamp(0.0, 1.0) : 0.0;

    // Color based on usage level
    Color arcColor;
    if (!hasLimit) {
      arcColor = PWColors.blue;
    } else if (fraction < 0.5) {
      arcColor = PWColors.mint;
    } else if (fraction < 0.8) {
      arcColor = PWColors.yellow;
    } else {
      arcColor = PWColors.coral;
    }

    final label = hasLimit
        ? '$usedMinutes / $limitMinutes min'
        : '$usedMinutes min';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: tc.shadowColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Today's Screen Time",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: tc.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _ArcPainter(
                fraction: fraction,
                arcColor: arcColor,
                trackColor: tc.textMuted.withValues(alpha: 0.15),
                hasLimit: hasLimit,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$usedMinutes',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: tc.textPrimary,
                      ),
                    ),
                    Text(
                      'min',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: tc.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tc.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.fraction,
    required this.arcColor,
    required this.trackColor,
    required this.hasLimit,
  });

  final double fraction;
  final Color arcColor;
  final Color trackColor;
  final bool hasLimit;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 12.0;
    const startAngle = -math.pi / 2; // 12 o'clock
    const fullSweep = math.pi * 2;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweep,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (!hasLimit) return;

    // Progress arc
    final sweep = fullSweep * fraction;
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = arcColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.trackColor != trackColor;
  }
}
