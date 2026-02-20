import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../coloring_engine/core/spline_path.dart';

class StrokePainter extends CustomPainter {
  StrokePainter({
    required this.segmentStrokes,
    required this.activeStrokePoints,
    required this.strokeWidth,
    required this.repaintTick,
    required ValueListenable<int> repaint,
  }) : super(repaint: repaint);

  final List<List<Offset>> segmentStrokes;
  final List<Offset> activeStrokePoints;
  final double strokeWidth;
  final int repaintTick;

  static const _completedColor = Color(0xFF1769DA);
  static const _activeColor = Color(0xFF45B2FF);

  @override
  void paint(Canvas canvas, Size size) {
    final completedGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _completedColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final completedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _completedColor;

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _activeColor;

    for (final stroke in segmentStrokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, strokeWidth * 0.5, completedPaint);
        continue;
      }

      final path = buildSplinePath(stroke);
      canvas.drawPath(path, completedGlow);
      canvas.drawPath(path, completedPaint);
    }

    if (activeStrokePoints.isEmpty) return;

    if (activeStrokePoints.length == 1) {
      canvas.drawCircle(
        activeStrokePoints.first,
        strokeWidth * 0.5,
        activePaint,
      );
      return;
    }

    canvas.drawPath(buildSplinePath(activeStrokePoints), activePaint);
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return oldDelegate.repaintTick != repaintTick ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
