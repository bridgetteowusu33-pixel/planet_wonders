import 'package:flutter/material.dart';

import '../engine/tracing_engine.dart';

/// The type of animation to play on a completed segment.
enum SegmentAnimationType { none, earWiggle, wingFlutter, tailWag }

/// Paints a single completed segment with an animated transform
/// (rotation around its center). Only active during the brief
/// animation window after segment completion.
class AnimatedSegmentPainter extends CustomPainter {
  AnimatedSegmentPainter({
    required this.segment,
    required this.animationType,
    required this.angle,
    required this.strokeWidth,
  });

  final SegmentData segment;
  final SegmentAnimationType animationType;
  final double angle;
  final double strokeWidth;

  static const _completedColor = Color(0xFF3CCB8A);
  static const _glowColor = Color(0xFF9AF2CC);

  @override
  void paint(Canvas canvas, Size size) {
    if (animationType == SegmentAnimationType.none || angle.abs() < 0.001) {
      return;
    }

    // Find the center of the segment's screen path bounding box for rotation.
    final bounds = segment.screenPath.getBounds();
    final center = bounds.center;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _glowColor.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _completedColor;

    canvas.drawPath(segment.screenPath, glowPaint);
    canvas.drawPath(segment.screenPath, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AnimatedSegmentPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.animationType != animationType ||
        oldDelegate.segment != segment;
  }
}
