import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a cozy British kitchen background.
///
/// Elements: tiled wall, arched window with rain, teapot on counter,
/// Union Jack apron on wall hook, cat silhouette on windowsill,
/// warm wooden counter at bottom.
class BritishKitchenPainter extends CustomPainter {
  const BritishKitchenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // --- Warm cream background ---
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFFF5EDE0),
            Color(0xFFF0E4D4),
            Color(0xFFEADAC6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );

    // --- Tiled wall (subtle grid) ---
    final tilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0x14A08060);
    const tileSize = 44.0;
    final wallBottom = size.height * 0.72;
    for (double y = 0; y < wallBottom; y += tileSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), tilePaint);
    }
    for (double x = 0; x < size.width; x += tileSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, wallBottom), tilePaint);
    }

    // --- Window (arched, top-center) with rain ---
    _paintWindow(canvas, size);

    // --- Cat silhouette on windowsill ---
    _paintCat(canvas, size);

    // --- Union Jack apron on wall hook (left side) ---
    _paintApron(canvas, size);

    // --- Shelf with teapot and cups (right side) ---
    _paintShelf(canvas, size);

    // --- Wooden counter ---
    _paintCounter(canvas, size);

    // --- Teapot silhouette on counter ---
    _paintTeapot(canvas, size);

    // --- Soft rain streaks ---
    _paintRain(canvas, size);
  }

  void _paintWindow(Canvas canvas, Size size) {
    final windowCenter = Offset(size.width * 0.5, size.height * 0.1);
    final windowRect = Rect.fromCenter(
      center: windowCenter,
      width: size.width * 0.30,
      height: size.height * 0.2,
    );

    // Sky fill
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x509CCDDE), Color(0x30B8D8E8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(windowRect);
    final windowPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        windowRect,
        topLeft: const Radius.circular(56),
        topRight: const Radius.circular(56),
        bottomLeft: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      ));
    canvas.drawPath(windowPath, skyPaint);

    // Clouds
    final cloudPaint = Paint()..color = const Color(0x30FFFFFF);
    final cx = windowRect.center.dx;
    final cy = windowRect.center.dy - 6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 14, cy), width: 56, height: 16),
        const Radius.circular(10),
      ),
      cloudPaint,
    );
    canvas.drawCircle(Offset(cx - 30, cy - 4), 9, cloudPaint);
    canvas.drawCircle(Offset(cx + 4, cy - 6), 11, cloudPaint);

    // Frame
    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0x55A08060);
    canvas.drawPath(windowPath, framePaint);

    // Cross panes
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top + 12),
      Offset(windowRect.center.dx, windowRect.bottom),
      framePaint,
    );
    canvas.drawLine(
      Offset(windowRect.left, windowRect.center.dy),
      Offset(windowRect.right, windowRect.center.dy),
      framePaint,
    );

    // Sill
    final sillPaint = Paint()..color = const Color(0x44A08060);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          windowRect.left - 6,
          windowRect.bottom - 2,
          windowRect.width + 12,
          6,
        ),
        const Radius.circular(3),
      ),
      sillPaint,
    );
  }

  void _paintCat(Canvas canvas, Size size) {
    final catPaint = Paint()..color = const Color(0x28604830);
    final cx = size.width * 0.56;
    final cy = size.height * 0.19;

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 20, height: 12),
      catPaint,
    );
    // Head
    canvas.drawCircle(Offset(cx - 8, cy - 2), 7, catPaint);
    // Ears
    final earPath = Path()
      ..moveTo(cx - 14, cy - 6)
      ..lineTo(cx - 11, cy - 14)
      ..lineTo(cx - 8, cy - 6)
      ..close();
    canvas.drawPath(earPath, catPaint);
    final earPath2 = Path()
      ..moveTo(cx - 6, cy - 7)
      ..lineTo(cx - 3, cy - 14)
      ..lineTo(cx, cy - 6)
      ..close();
    canvas.drawPath(earPath2, catPaint);
    // Tail
    final tailPath = Path()
      ..moveTo(cx + 10, cy + 2)
      ..quadraticBezierTo(cx + 22, cy - 8, cx + 18, cy - 12);
    canvas.drawPath(
      tailPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x28604830),
    );
  }

  void _paintApron(Canvas canvas, Size size) {
    final apronPaint = Paint()..color = const Color(0x20304878);
    final ax = size.width * 0.12;
    final ay = size.height * 0.32;

    // Hook
    canvas.drawCircle(Offset(ax, ay - 14), 4, apronPaint);

    // Apron body (trapezoid)
    final body = Path()
      ..moveTo(ax - 14, ay)
      ..lineTo(ax + 14, ay)
      ..lineTo(ax + 18, ay + 40)
      ..lineTo(ax - 18, ay + 40)
      ..close();
    canvas.drawPath(body, apronPaint);

    // Union Jack hint — red cross
    final redPaint = Paint()
      ..color = const Color(0x20C03030)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(ax, ay + 4), Offset(ax, ay + 36), redPaint);
    canvas.drawLine(Offset(ax - 14, ay + 20), Offset(ax + 14, ay + 20), redPaint);

    // Blue corners
    final bluePaint = Paint()..color = const Color(0x14003078);
    canvas.drawRect(
      Rect.fromLTWH(ax - 13, ay + 2, 12, 16),
      bluePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(ax + 2, ay + 2, 12, 16),
      bluePaint,
    );

    // Strings
    final stringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0x20304878);
    canvas.drawLine(Offset(ax - 14, ay), Offset(ax - 6, ay - 14), stringPaint);
    canvas.drawLine(Offset(ax + 14, ay), Offset(ax + 6, ay - 14), stringPaint);
  }

  void _paintShelf(Canvas canvas, Size size) {
    final shelfY = size.height * 0.30;
    final shelfPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x44C4A882), Color(0x339C7E5A)],
      ).createShader(Rect.fromLTWH(size.width * 0.66, shelfY, size.width * 0.30, 6));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.66, shelfY, size.width * 0.30, 5),
        const Radius.circular(3),
      ),
      shelfPaint,
    );

    // Tea cups
    final cupPaint = Paint()..color = const Color(0x28FFFFFF);
    final cx = size.width * 0.72;
    // Cup 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx, shelfY - 16, 12, 16),
        const Radius.circular(3),
      ),
      cupPaint,
    );
    // Cup 2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 18, shelfY - 14, 10, 14),
        const Radius.circular(3),
      ),
      cupPaint,
    );
    // Jar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 36, shelfY - 22, 14, 22),
        const Radius.circular(4),
      ),
      cupPaint,
    );
  }

  void _paintCounter(Canvas canvas, Size size) {
    final counterTop = Rect.fromLTWH(
      0,
      size.height * 0.72,
      size.width,
      size.height * 0.29,
    );

    // Edge highlight
    final edgePaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFE8D4B0), Color(0xFFD4B896)],
      ).createShader(Rect.fromLTWH(0, counterTop.top, size.width, 6));
    canvas.drawRect(
      Rect.fromLTWH(0, counterTop.top, size.width, 6),
      edgePaint,
    );

    // Main surface
    final counterPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFFFEED2), Color(0xFFE8D0A8), Color(0xFFD4B896)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(counterTop);
    canvas.drawRect(
      Rect.fromLTWH(0, counterTop.top + 6, size.width, counterTop.height - 6),
      counterPaint,
    );

    // Diagonal wood grain
    final stripePaint = Paint()..color = const Color(0x12A66E38);
    const stripeGap = 34.0;
    for (
      double x = -size.height;
      x < size.width + size.height;
      x += stripeGap
    ) {
      final path = Path()
        ..moveTo(x, counterTop.top + 6)
        ..lineTo(x + 30, counterTop.top + 6)
        ..lineTo(x + 64, counterTop.bottom)
        ..lineTo(x + 34, counterTop.bottom)
        ..close();
      canvas.drawPath(path, stripePaint);
    }

    // Top shadow
    final shadowPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x18000000), Color(0x00000000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, counterTop.top + 6, size.width, 20));
    canvas.drawRect(
      Rect.fromLTWH(0, counterTop.top + 6, size.width, 20),
      shadowPaint,
    );
  }

  void _paintTeapot(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x22604830);
    final tx = size.width * 0.72;
    final ty = size.height * 0.72;

    // Body (rounded rect)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(tx, ty - 12), width: 32, height: 22),
        const Radius.circular(11),
      ),
      paint,
    );
    // Lid knob
    canvas.drawCircle(Offset(tx, ty - 24), 4, paint);
    // Spout
    final spout = Path()
      ..moveTo(tx + 16, ty - 14)
      ..quadraticBezierTo(tx + 28, ty - 22, tx + 26, ty - 28);
    canvas.drawPath(
      spout,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x22604830),
    );
    // Handle
    final handle = Path()
      ..moveTo(tx - 16, ty - 18)
      ..quadraticBezierTo(tx - 28, ty - 12, tx - 16, ty - 6);
    canvas.drawPath(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x22604830),
    );
  }

  void _paintRain(Canvas canvas, Size size) {
    final rainPaint = Paint()
      ..color = const Color(0x149CCDDE)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final rng = math.Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.7;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 2, y + 8 + rng.nextDouble() * 6),
        rainPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BritishKitchenPainter oldDelegate) => false;
}
