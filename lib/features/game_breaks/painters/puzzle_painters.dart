import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Base class for programmatic puzzle images.
///
/// Paints a colorful picture that can be sliced into tiles by the puzzle grid.
abstract class PuzzlePainter extends CustomPainter {
  const PuzzlePainter();
}

// ---------------------------------------------------------------------------
// Ghana Flag — red / gold / green horizontal stripes + black star
// ---------------------------------------------------------------------------

class GhanaFlagPainter extends PuzzlePainter {
  const GhanaFlagPainter();

  static const _red = Color(0xFFCE1126);
  static const _gold = Color(0xFFFCD116);
  static const _green = Color(0xFF006B3F);

  @override
  void paint(Canvas canvas, Size size) {
    final stripeH = size.height / 3;

    // Red stripe
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, stripeH),
      Paint()..color = _red,
    );
    // Gold stripe
    canvas.drawRect(
      Rect.fromLTWH(0, stripeH, size.width, stripeH),
      Paint()..color = _gold,
    );
    // Green stripe
    canvas.drawRect(
      Rect.fromLTWH(0, stripeH * 2, size.width, stripeH),
      Paint()..color = _green,
    );

    // Black star centered
    _drawStar(canvas, size.width / 2, size.height / 2, size.height * 0.18);
  }

  void _drawStar(Canvas canvas, double cx, double cy, double radius) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final outerAngle = (i * 2 * math.pi / 5) - math.pi / 2;
      final innerAngle = outerAngle + math.pi / 5;
      final ox = cx + radius * math.cos(outerAngle);
      final oy = cy + radius * math.sin(outerAngle);
      final ix = cx + radius * 0.4 * math.cos(innerAngle);
      final iy = cy + radius * 0.4 * math.sin(innerAngle);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// USA Flag — stars and stripes
// ---------------------------------------------------------------------------

class UsaFlagPainter extends PuzzlePainter {
  const UsaFlagPainter();

  static const _red = Color(0xFFB31942);
  static const _white = Color(0xFFFFFFFF);
  static const _blue = Color(0xFF0A3161);

  @override
  void paint(Canvas canvas, Size size) {
    final stripeH = size.height / 13;

    // 13 stripes
    for (var i = 0; i < 13; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeH, size.width, stripeH),
        Paint()..color = i.isEven ? _red : _white,
      );
    }

    // Blue canton (top-left, 7 stripes tall, 40% width)
    final cantonW = size.width * 0.4;
    final cantonH = stripeH * 7;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cantonW, cantonH),
      Paint()..color = _blue,
    );

    // Simplified star grid (5 rows × 6 cols for kids — not 50 exact)
    const rows = 5;
    const cols = 6;
    final starRadius = cantonH / (rows * 3.2);
    final spacingX = cantonW / (cols + 1);
    final spacingY = cantonH / (rows + 1);

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final cx = spacingX * (c + 1);
        final cy = spacingY * (r + 1);
        _drawStar(canvas, cx, cy, starRadius);
      }
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double radius) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final outerAngle = (i * 2 * math.pi / 5) - math.pi / 2;
      final innerAngle = outerAngle + math.pi / 5;
      final ox = cx + radius * math.cos(outerAngle);
      final oy = cy + radius * math.sin(outerAngle);
      final ix = cx + radius * 0.4 * math.cos(innerAngle);
      final iy = cy + radius * 0.4 * math.sin(innerAngle);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Kente Pattern — colorful woven stripes
// ---------------------------------------------------------------------------

class KentePatternPainter extends PuzzlePainter {
  const KentePatternPainter();

  static const _colors = [
    Color(0xFFFCD116), // gold
    Color(0xFFCE1126), // red
    Color(0xFF006B3F), // green
    Color(0xFF0A3161), // blue
    Color(0xFFFF8C00), // orange
    Color(0xFF4B0082), // indigo
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A1A1A),
    );

    const blockCols = 6;
    const blockRows = 6;
    final blockW = size.width / blockCols;
    final blockH = size.height / blockRows;

    for (var r = 0; r < blockRows; r++) {
      for (var c = 0; c < blockCols; c++) {
        final x = c * blockW;
        final y = r * blockH;
        final colorIdx = (r + c) % _colors.length;
        final color = _colors[colorIdx];

        // Outer block
        canvas.drawRect(
          Rect.fromLTWH(x + 2, y + 2, blockW - 4, blockH - 4),
          Paint()..color = color,
        );

        // Inner diamond pattern
        final cx = x + blockW / 2;
        final cy = y + blockH / 2;
        final dSize = blockW * 0.25;
        final diamond = Path()
          ..moveTo(cx, cy - dSize)
          ..lineTo(cx + dSize, cy)
          ..lineTo(cx, cy + dSize)
          ..lineTo(cx - dSize, cy)
          ..close();
        canvas.drawPath(
          diamond,
          Paint()..color = _colors[(colorIdx + 3) % _colors.length],
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Adinkra Symbol — "Gye Nyame" (Except God) — bold & iconic
// ---------------------------------------------------------------------------

class AdinkraGNPainter extends PuzzlePainter {
  const AdinkraGNPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Warm background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFFCD116),
    );

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.35;
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Inner spiral-like curves (simplified Gye Nyame)
    final fillPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    // Top arc
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - r * 0.2), width: r, height: r * 0.8),
      -math.pi * 0.8,
      math.pi * 0.6,
      false,
      paint,
    );

    // Bottom arc
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + r * 0.2), width: r, height: r * 0.8),
      math.pi * 0.2,
      math.pi * 0.6,
      false,
      paint,
    );

    // Center dot
    canvas.drawCircle(Offset(cx, cy), r * 0.12, fillPaint);

    // Corner decorations
    final cornerR = size.width * 0.08;
    for (final offset in [
      Offset(cornerR * 2, cornerR * 2),
      Offset(size.width - cornerR * 2, cornerR * 2),
      Offset(cornerR * 2, size.height - cornerR * 2),
      Offset(size.width - cornerR * 2, size.height - cornerR * 2),
    ]) {
      canvas.drawCircle(offset, cornerR, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// USA Landmarks collage — simplified iconic shapes
// ---------------------------------------------------------------------------

class UsaLandmarksPainter extends PuzzlePainter {
  const UsaLandmarksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
      Paint()..color = const Color(0xFF4CAF50),
    );

    final w = size.width;
    final h = size.height;

    // Statue of Liberty (left side) — simplified
    final statuePaint = Paint()..color = const Color(0xFF4DB6AC);
    final base = Paint()..color = const Color(0xFF78909C);

    // Pedestal
    canvas.drawRect(
      Rect.fromLTWH(w * 0.08, h * 0.55, w * 0.18, h * 0.2),
      base,
    );
    // Body
    final body = Path()
      ..moveTo(w * 0.12, h * 0.55)
      ..lineTo(w * 0.14, h * 0.25)
      ..lineTo(w * 0.20, h * 0.25)
      ..lineTo(w * 0.22, h * 0.55)
      ..close();
    canvas.drawPath(body, statuePaint);
    // Torch
    canvas.drawRect(
      Rect.fromLTWH(w * 0.19, h * 0.12, w * 0.03, h * 0.13),
      statuePaint,
    );
    canvas.drawCircle(
      Offset(w * 0.205, h * 0.10),
      w * 0.03,
      Paint()..color = const Color(0xFFFFC107),
    );

    // Skyscraper (center)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.40, h * 0.20, w * 0.15, h * 0.55),
      Paint()..color = const Color(0xFF546E7A),
    );
    // Windows
    final windowPaint = Paint()..color = const Color(0xFFFFF9C4);
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 3; col++) {
        canvas.drawRect(
          Rect.fromLTWH(
            w * 0.42 + col * w * 0.045,
            h * 0.23 + row * h * 0.06,
            w * 0.03,
            h * 0.035,
          ),
          windowPaint,
        );
      }
    }

    // Golden Gate Bridge (right side)
    final bridgePaint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = w * 0.02
      ..style = PaintingStyle.stroke;
    // Towers
    canvas.drawRect(
      Rect.fromLTWH(w * 0.68, h * 0.30, w * 0.04, h * 0.45),
      Paint()..color = const Color(0xFFE53935),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.88, h * 0.30, w * 0.04, h * 0.45),
      Paint()..color = const Color(0xFFE53935),
    );
    // Cables
    final cable = Path()
      ..moveTo(w * 0.70, h * 0.32)
      ..quadraticBezierTo(w * 0.80, h * 0.50, w * 0.90, h * 0.32);
    canvas.drawPath(cable, bridgePaint);

    // Sun
    canvas.drawCircle(
      Offset(w * 0.82, h * 0.12),
      w * 0.06,
      Paint()..color = const Color(0xFFFFC107),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
