import 'dart:math';

import 'package:flutter/material.dart';

/// Simple CustomPainter outlines for Ghana coloring pages.
///
/// These are placeholder line-art outlines drawn programmatically.
/// When real illustration assets are ready, swap these for image rendering.
/// The outlines use only black strokes on transparent so they layer
/// cleanly on top of the kid's coloring.

final _outlinePaint = Paint()
  ..color = Colors.black
  ..strokeWidth = 2.5
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

// ---------------------------------------------------------------------------
// 1. Kente Pattern — a woven grid of rectangles
// ---------------------------------------------------------------------------
void paintKentePattern(Canvas canvas, Size size) {
  final paint = _outlinePaint;
  final cols = 4;
  final rows = 6;
  final cellW = size.width / (cols + 1);
  final cellH = size.height / (rows + 1);
  final offsetX = cellW / 2;
  final offsetY = cellH / 2;

  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      final rect = Rect.fromLTWH(
        offsetX + c * cellW,
        offsetY + r * cellH,
        cellW,
        cellH,
      );
      canvas.drawRect(rect, paint);

      // Inner diamond in every other cell for visual interest
      if ((r + c) % 2 == 0) {
        final cx = rect.center.dx;
        final cy = rect.center.dy;
        final dx = cellW * 0.3;
        final dy = cellH * 0.3;
        final diamond = Path()
          ..moveTo(cx, cy - dy)
          ..lineTo(cx + dx, cy)
          ..lineTo(cx, cy + dy)
          ..lineTo(cx - dx, cy)
          ..close();
        canvas.drawPath(diamond, paint);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// 2. Talking Drum — hourglass / goblet shape
// ---------------------------------------------------------------------------
void paintTalkingDrum(Canvas canvas, Size size) {
  final paint = _outlinePaint;
  final cx = size.width / 2;
  final w = size.width * 0.35;
  final topY = size.height * 0.15;
  final midY = size.height * 0.5;
  final botY = size.height * 0.85;
  final neckW = w * 0.45;

  // Drum body — two curves meeting at a narrow neck
  final body = Path()
    ..moveTo(cx - w, topY)
    ..quadraticBezierTo(cx - neckW, midY, cx - w, botY)
    ..lineTo(cx + w, botY)
    ..quadraticBezierTo(cx + neckW, midY, cx + w, topY)
    ..close();
  canvas.drawPath(body, paint);

  // Top & bottom ovals (drum heads)
  canvas.drawOval(
    Rect.fromCenter(center: Offset(cx, topY), width: w * 2, height: 30),
    paint,
  );
  canvas.drawOval(
    Rect.fromCenter(center: Offset(cx, botY), width: w * 2, height: 30),
    paint,
  );

  // Tension strings
  for (var i = 0; i < 5; i++) {
    final t = (i + 1) / 6;
    final x1 = cx - w + (w * 2 * t);
    final x2 = cx - w + (w * 2 * t);
    canvas.drawLine(Offset(x1, topY), Offset(x2, botY), paint);
  }
}

// ---------------------------------------------------------------------------
// 3. Adinkra Symbol — Gye Nyame ("Except God")
//    Simplified as a bold spiral / scroll shape
// ---------------------------------------------------------------------------
void paintAdinkraSymbol(Canvas canvas, Size size) {
  final paint = _outlinePaint..strokeWidth = 3.0;
  final cx = size.width / 2;
  final cy = size.height / 2;
  final r = min(size.width, size.height) * 0.32;

  // Outer circle
  canvas.drawCircle(Offset(cx, cy), r, paint);

  // Inner decorative spiral (simplified Gye Nyame)
  final spiral = Path()
    ..moveTo(cx - r * 0.6, cy)
    ..quadraticBezierTo(cx - r * 0.6, cy - r * 0.5, cx, cy - r * 0.5)
    ..quadraticBezierTo(cx + r * 0.5, cy - r * 0.5, cx + r * 0.5, cy)
    ..quadraticBezierTo(cx + r * 0.5, cy + r * 0.3, cx, cy + r * 0.3)
    ..quadraticBezierTo(cx - r * 0.3, cy + r * 0.3, cx - r * 0.3, cy);
  canvas.drawPath(spiral, paint);

  // Center dot
  canvas.drawCircle(
    Offset(cx, cy),
    6,
    paint..style = PaintingStyle.fill,
  );

  // Reset to stroke
  paint.style = PaintingStyle.stroke;
  paint.strokeWidth = 2.5;

  // Corner decorations
  final cornerR = r * 0.2;
  for (final offset in [
    Offset(cx - r * 0.7, cy - r * 0.7),
    Offset(cx + r * 0.7, cy - r * 0.7),
    Offset(cx - r * 0.7, cy + r * 0.7),
    Offset(cx + r * 0.7, cy + r * 0.7),
  ]) {
    canvas.drawCircle(offset, cornerR, paint);
  }
}

// ---------------------------------------------------------------------------
// 4. Ghana Star — the five-pointed star from the flag
// ---------------------------------------------------------------------------
void paintGhanaStar(Canvas canvas, Size size) {
  final paint = _outlinePaint;
  final cx = size.width / 2;
  final cy = size.height / 2;
  final outerR = min(size.width, size.height) * 0.38;
  final innerR = outerR * 0.4;

  // Five-pointed star
  final star = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? outerR : innerR;
    final angle = (i * pi / 5) - (pi / 2); // start at top
    final x = cx + r * cos(angle);
    final y = cy + r * sin(angle);
    if (i == 0) {
      star.moveTo(x, y);
    } else {
      star.lineTo(x, y);
    }
  }
  star.close();
  canvas.drawPath(star, paint);

  // Surrounding circle
  canvas.drawCircle(Offset(cx, cy), outerR + 16, paint);
}
