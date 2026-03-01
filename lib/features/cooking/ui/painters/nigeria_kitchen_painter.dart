import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a vibrant Nigerian kitchen background.
///
/// Elements: orange-green walls, market baskets on shelf,
/// calabash decorations, sunny window, ankara pattern accents.
class NigeriaKitchenPainter extends CustomPainter {
  const NigeriaKitchenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // --- Vibrant warm wall ---
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFFFFF0D4),
            Color(0xFFFFE4B8),
            Color(0xFFF8D8A0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );

    // --- Subtle wall pattern ---
    final texturePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4
      ..color = const Color(0x0AE08040);
    final wallBottom = size.height * 0.72;
    for (double y = 0; y < wallBottom; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), texturePaint);
    }

    // --- Window (arched) with bright sun ---
    final windowCenter = Offset(size.width * 0.5, size.height * 0.08);
    final windowRect = Rect.fromCenter(
      center: windowCenter,
      width: size.width * 0.28,
      height: size.height * 0.18,
    );
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x5587CEEB), Color(0x44FFFACD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(windowRect);
    final windowPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        windowRect,
        topLeft: const Radius.circular(60),
        topRight: const Radius.circular(60),
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      ));
    canvas.drawPath(windowPath, skyPaint);

    // Sun through window
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: const <Color>[
          Color(0x55FFD700),
          Color(0x22FFA500),
          Color(0x00FFA500),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(windowRect.right - 16, windowRect.top + 20),
          radius: 18,
        ),
      );
    canvas.drawCircle(
      Offset(windowRect.right - 16, windowRect.top + 20),
      18,
      sunPaint,
    );
    canvas.drawCircle(
      Offset(windowRect.right - 16, windowRect.top + 20),
      7,
      Paint()..color = const Color(0x44FFD700),
    );

    // Window frame
    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0x55A07848);
    canvas.drawPath(windowPath, framePaint);
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top + 10),
      Offset(windowRect.center.dx, windowRect.bottom),
      framePaint,
    );

    // --- Shelf with market baskets ---
    final shelfY = size.height * 0.35;
    final shelfPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x55A08050), Color(0x44886838)],
      ).createShader(Rect.fromLTWH(0, shelfY, size.width * 0.32, 8));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.04, shelfY, size.width * 0.28, 6),
        const Radius.circular(3),
      ),
      shelfPaint,
    );

    // Woven basket (left)
    final basketPaint = Paint()
      ..color = const Color(0x40C4943C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final basketX = size.width * 0.09;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(basketX, shelfY - 12),
        width: 26,
        height: 24,
      ),
      0,
      math.pi,
      false,
      basketPaint,
    );
    // Basket handle
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(basketX, shelfY - 18),
        width: 18,
        height: 14,
      ),
      math.pi,
      math.pi,
      false,
      basketPaint,
    );

    // Round calabash
    final calabashPaint = Paint()..color = const Color(0x30D4843C);
    canvas.drawCircle(
      Offset(size.width * 0.22, shelfY - 11),
      9,
      calabashPaint,
    );

    // --- Right shelf with jars ---
    final shelfY2 = size.height * 0.28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, shelfY2, size.width * 0.28, 6),
        const Radius.circular(3),
      ),
      shelfPaint,
    );
    final jarPaint = Paint()..color = const Color(0x30E09040);
    final jar2X = size.width * 0.73;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(jar2X, shelfY2 - 22, 16, 22),
        const Radius.circular(4),
      ),
      jarPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(jar2X + 22, shelfY2 - 16, 14, 16),
        const Radius.circular(3),
      ),
      jarPaint,
    );

    // --- Ankara accent circles (decorative, mid-wall) ---
    final ankaraPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const ankaraColors = <Color>[
      Color(0x2AFF6B00),
      Color(0x2A00AA44),
      Color(0x2AFF4488),
    ];
    for (int i = 0; i < 3; i++) {
      ankaraPaint.color = ankaraColors[i];
      final cx = size.width * (0.15 + i * 0.35);
      final cy = size.height * 0.55;
      canvas.drawCircle(Offset(cx, cy), 16, ankaraPaint);
      canvas.drawCircle(Offset(cx, cy), 8, ankaraPaint);
    }

    // --- Green-white-green border (Nigerian flag inspired, top edge) ---
    final borderPaint = Paint();
    // Green stripe
    borderPaint.color = const Color(0x55008751);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.33, 5), borderPaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.67, 0, size.width * 0.33, 5),
      borderPaint,
    );
    // White stripe
    borderPaint.color = const Color(0x44FFFFFF);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.33, 0, size.width * 0.34, 5),
      borderPaint,
    );

    // --- Wooden counter ---
    final counterTop = Rect.fromLTWH(
      0,
      size.height * 0.72,
      size.width,
      size.height * 0.29,
    );
    final edgePaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFD4A870), Color(0xFFC09060)],
      ).createShader(Rect.fromLTWH(0, counterTop.top, size.width, 6));
    canvas.drawRect(
      Rect.fromLTWH(0, counterTop.top, size.width, 6),
      edgePaint,
    );
    final counterPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[
          Color(0xFFE8C89C),
          Color(0xFFD4A870),
          Color(0xFFC09060),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(counterTop);
    canvas.drawRect(
      Rect.fromLTWH(0, counterTop.top + 6, size.width, counterTop.height - 6),
      counterPaint,
    );

    // Wood grain
    final stripePaint = Paint()..color = const Color(0x12805020);
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
  }

  @override
  bool shouldRepaint(covariant NigeriaKitchenPainter oldDelegate) => false;
}
