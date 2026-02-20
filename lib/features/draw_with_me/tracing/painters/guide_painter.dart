import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/tracing_engine.dart';

class GuidePainter extends CustomPainter {
  GuidePainter({
    required this.segments,
    required this.activeSegmentIndex,
    required this.segmentProgress,
    required this.allCompleted,
    required this.guideStrokeWidth,
    required this.reduceMotion,
    required this.chevronPhase,
    required this.repaintTick,
  });

  final List<SegmentData> segments;
  final int activeSegmentIndex;
  final double segmentProgress;
  final bool allCompleted;
  final double guideStrokeWidth;
  final bool reduceMotion;
  final double chevronPhase;
  final int repaintTick;

  static const _inactiveColor = Color(0xFFC8D5E8);
  static const _activeColor = Color(0xFF4A86FF);
  static const _activeGlowColor = Color(0xFF87BDFF);
  static const _completedColor = Color(0xFF3CCB8A);
  static const _completedGlowColor = Color(0xFF9AF2CC);

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final inactivePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _inactiveColor.withValues(alpha: 0.55);

    final completedGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideStrokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _completedGlowColor.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final completedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _completedColor;

    final activeGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideStrokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _activeGlowColor.withValues(alpha: 0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _activeColor;

    final activeProgressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideStrokeWidth + 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF18B875);

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];

      canvas.drawPath(segment.screenPath, inactivePaint);

      if (allCompleted || i < activeSegmentIndex) {
        canvas.drawPath(segment.screenPath, completedGlowPaint);
        canvas.drawPath(segment.screenPath, completedPaint);
        continue;
      }

      if (i == activeSegmentIndex) {
        canvas.drawPath(segment.screenPath, activeGlowPaint);
        canvas.drawPath(segment.screenPath, activePaint);

        final progressDistance = segment.length * segmentProgress;
        final donePath = segment.extractScreenPathTo(progressDistance);
        canvas.drawPath(donePath, activeProgressPaint);
      }
    }

    _drawStartMarker(canvas);
    _drawFinishFlag(canvas);

    if (!reduceMotion && !allCompleted) {
      _drawDirectionChevrons(canvas);
    }
  }

  void _drawStartMarker(Canvas canvas) {
    if (segments.isEmpty) return;
    final start = segments.first.screenPointAt(0);
    if (start == null) return;

    final markerPaint = Paint()..color = const Color(0xFFFFD84C);
    final shadowPaint = Paint()
      ..color = const Color(0x29000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final radius = guideStrokeWidth * 0.65;
    canvas.drawCircle(start, radius + 1.5, shadowPaint);

    final star = Path();
    for (var i = 0; i < 10; i++) {
      final ratio = i.isEven ? 1.0 : 0.5;
      final angle = -math.pi / 2 + (i / 10) * math.pi * 2;
      final point = Offset(
        start.dx + math.cos(angle) * radius * ratio,
        start.dy + math.sin(angle) * radius * ratio,
      );
      if (i == 0) {
        star.moveTo(point.dx, point.dy);
      } else {
        star.lineTo(point.dx, point.dy);
      }
    }
    star.close();

    canvas.drawPath(star, markerPaint);
  }

  void _drawFinishFlag(Canvas canvas) {
    if (segments.isEmpty) return;
    final endSegment = segments.last;
    final end = endSegment.screenPointAt(endSegment.length);
    if (end == null) return;

    final poleHeight = guideStrokeWidth * 2.2;
    final polePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF6C7B95);

    final poleTop = Offset(end.dx, end.dy - poleHeight);
    canvas.drawLine(end, poleTop, polePaint);

    final flag = Path()
      ..moveTo(poleTop.dx, poleTop.dy)
      ..lineTo(
        poleTop.dx + guideStrokeWidth * 1.4,
        poleTop.dy + guideStrokeWidth * 0.35,
      )
      ..lineTo(poleTop.dx, poleTop.dy + guideStrokeWidth * 0.7)
      ..close();

    final flagPaint = Paint()..color = const Color(0xFFFF7456);
    canvas.drawPath(flag, flagPaint);
  }

  void _drawDirectionChevrons(Canvas canvas) {
    if (activeSegmentIndex < 0 || activeSegmentIndex >= segments.length) return;

    final segment = segments[activeSegmentIndex];
    if (segment.length <= 0) return;

    final spacing = (guideStrokeWidth * 4.8).clamp(34.0, 62.0);
    final shift = (chevronPhase * spacing) % spacing;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFEAF2FF).withValues(alpha: 0.86);

    for (double d = spacing - shift; d < segment.length; d += spacing) {
      final center = segment.screenPointAt(d);
      final before = segment.screenPointAt((d - 2).clamp(0.0, segment.length));
      final after = segment.screenPointAt((d + 2).clamp(0.0, segment.length));

      if (center == null || before == null || after == null) continue;

      final tangent = after - before;
      final tangentLength = tangent.distance;
      if (tangentLength <= 0.0001) continue;

      final direction = tangent / tangentLength;
      final perp = Offset(-direction.dy, direction.dx);

      final size = guideStrokeWidth * 0.45;
      final tip = center + direction * size * 0.8;
      final left = center - direction * size * 0.6 + perp * size * 0.6;
      final right = center - direction * size * 0.6 - perp * size * 0.6;

      canvas.drawLine(left, tip, paint);
      canvas.drawLine(right, tip, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GuidePainter oldDelegate) {
    return oldDelegate.repaintTick != repaintTick ||
        oldDelegate.activeSegmentIndex != activeSegmentIndex ||
        oldDelegate.segmentProgress != segmentProgress ||
        oldDelegate.allCompleted != allCompleted ||
        oldDelegate.guideStrokeWidth != guideStrokeWidth ||
        oldDelegate.reduceMotion != reduceMotion ||
        oldDelegate.chevronPhase != chevronPhase ||
        oldDelegate.segments.length != segments.length;
  }
}
