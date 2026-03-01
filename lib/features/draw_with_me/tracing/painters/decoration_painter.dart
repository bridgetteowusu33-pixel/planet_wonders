import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../models/trace_decorations.dart';

class DecorationPainter extends CustomPainter {
  DecorationPainter({
    required this.decorations,
    required this.scale,
    required this.tx,
    required this.ty,
    required this.opacity,
  });

  final TraceDecorations decorations;
  final double scale;
  final double tx;
  final double ty;
  final double opacity;

  Float64List get _matrix => Float64List.fromList([
        scale, 0, 0, 0,
        0, scale, 0, 0,
        0, 0, 1, 0,
        tx, ty, 0, 1,
      ]);

  Offset _toScreen(double cx, double cy) =>
      Offset(cx * scale + tx, cy * scale + ty);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;

    _paintBlush(canvas);
    _paintEyes(canvas);
    _paintNose(canvas);
    _paintMouth(canvas);
    _paintTongue(canvas);
    _paintEyebrows(canvas);
  }

  void _paintEyes(Canvas canvas) {
    for (final eye in decorations.eyes) {
      final center = _toScreen(eye.cx, eye.cy);
      final r = eye.r * scale;
      final pupilR = eye.pupilR * scale;
      final highlightR = eye.highlightR * scale;

      // White sclera
      final scleraPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(center, r, scleraPaint);

      // Sclera outline
      final outlinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * scale
        ..color = const Color(0xFF2D3142).withValues(alpha: opacity * 0.5);
      canvas.drawCircle(center, r, outlinePaint);

      // Black pupil
      final pupilPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF2D3142).withValues(alpha: opacity);
      canvas.drawCircle(center, pupilR, pupilPaint);

      // White highlight
      final hlOffset = Offset(
        eye.highlightOffset.dx * scale,
        eye.highlightOffset.dy * scale,
      );
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(alpha: opacity * 0.95);
      canvas.drawCircle(center + hlOffset, highlightR, highlightPaint);
    }
  }

  void _paintNose(Canvas canvas) {
    final pathData = decorations.nosePath;
    if (pathData.isEmpty) return;

    final path = parseSvgPathData(pathData).transform(_matrix);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF2D3142).withValues(alpha: opacity);
    canvas.drawPath(path, paint);
  }

  void _paintMouth(Canvas canvas) {
    final pathData = decorations.mouthPath;
    if (pathData.isEmpty) return;

    final path = parseSvgPathData(pathData).transform(_matrix);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF2D3142).withValues(alpha: opacity);
    canvas.drawPath(path, paint);
  }

  void _paintTongue(Canvas canvas) {
    final pathData = decorations.tonguePath;
    if (pathData.isEmpty) return;

    final path = parseSvgPathData(pathData).transform(_matrix);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFF8A9E).withValues(alpha: opacity);
    canvas.drawPath(path, paint);
  }

  void _paintBlush(Canvas canvas) {
    for (final b in decorations.blush) {
      final center = _toScreen(b.cx, b.cy);
      final rx = b.rx * scale;
      final ry = b.ry * scale;

      final rect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFFFB0C4).withValues(alpha: opacity * 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rx * 0.4);
      canvas.drawOval(rect, paint);
    }
  }

  void _paintEyebrows(Canvas canvas) {
    for (final pathData in decorations.eyebrowPaths) {
      if (pathData.isEmpty) continue;

      final path = parseSvgPathData(pathData).transform(_matrix);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF2D3142).withValues(alpha: opacity * 0.8);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DecorationPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.scale != scale ||
        oldDelegate.tx != tx ||
        oldDelegate.ty != ty;
  }
}
