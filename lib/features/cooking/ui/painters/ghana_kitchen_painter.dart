import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a warm Ghanaian kitchen background.
///
/// Elements: terracotta walls, wooden mortar & pestle on shelf,
/// charcoal stove glow, palm tree through window, kente pattern border.
class GhanaKitchenPainter extends CustomPainter {
  const GhanaKitchenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // --- Warm terracotta wall ---
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFFF2D4B0),
            Color(0xFFE8C49A),
            Color(0xFFDEB888),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );

    // --- Subtle wall texture (horizontal lines) ---
    final texturePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4
      ..color = const Color(0x0AC07040);
    final wallBottom = size.height * 0.72;
    for (double y = 0; y < wallBottom; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), texturePaint);
    }

    // --- Window (arched, top-center) with palm tree ---
    final windowCenter = Offset(size.width * 0.5, size.height * 0.08);
    final windowRect = Rect.fromCenter(
      center: windowCenter,
      width: size.width * 0.28,
      height: size.height * 0.18,
    );
    // Sky through window
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x5587CEEB), Color(0x33FFF8DC)],
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

    // Palm tree trunk
    final trunkPaint = Paint()
      ..color = const Color(0x448B7355)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final trunkBase = Offset(windowRect.center.dx + 8, windowRect.bottom);
    final trunkTop = Offset(windowRect.center.dx + 4, windowRect.top + 20);
    canvas.drawLine(trunkBase, trunkTop, trunkPaint);

    // Palm leaves
    final leafPaint = Paint()
      ..color = const Color(0x3348A14D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (int i = -2; i <= 2; i++) {
      final angle = i * 0.5;
      final endX = trunkTop.dx + math.cos(angle) * 28;
      final endY = trunkTop.dy - math.sin(angle).abs() * 14 + i.abs() * 4;
      canvas.drawLine(trunkTop, Offset(endX, endY), leafPaint);
    }

    // Window frame
    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0x55A0784A);
    canvas.drawPath(windowPath, framePaint);
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top + 10),
      Offset(windowRect.center.dx, windowRect.bottom),
      framePaint,
    );

    // --- Shelf with mortar & pestle ---
    final shelfY = size.height * 0.35;
    final shelfPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x55A08060), Color(0x44886844)],
      ).createShader(Rect.fromLTWH(0, shelfY, size.width * 0.32, 8));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.04, shelfY, size.width * 0.28, 6),
        const Radius.circular(3),
      ),
      shelfPaint,
    );

    // Mortar (bowl shape)
    final mortarPaint = Paint()..color = const Color(0x40705030);
    final mortarX = size.width * 0.10;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(mortarX, shelfY - 10),
        width: 28,
        height: 22,
      ),
      0,
      math.pi,
      true,
      mortarPaint,
    );

    // Pestle (diagonal line)
    final pestlePaint = Paint()
      ..color = const Color(0x40604020)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(mortarX - 4, shelfY - 18),
      Offset(mortarX + 14, shelfY - 30),
      pestlePaint,
    );

    // Calabash on shelf
    final calabashPaint = Paint()..color = const Color(0x30C88C32);
    canvas.drawCircle(
      Offset(size.width * 0.22, shelfY - 12),
      10,
      calabashPaint,
    );

    // --- Right shelf with spice jars ---
    final shelfY2 = size.height * 0.28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, shelfY2, size.width * 0.28, 6),
        const Radius.circular(3),
      ),
      shelfPaint,
    );
    final jarPaint = Paint()..color = const Color(0x30D4A560);
    final jar2X = size.width * 0.72;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(jar2X, shelfY2 - 24, 16, 24),
        const Radius.circular(4),
      ),
      jarPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(jar2X + 22, shelfY2 - 18, 14, 18),
        const Radius.circular(3),
      ),
      jarPaint,
    );

    // --- Charcoal stove glow (bottom-left) ---
    final glowCenter = Offset(size.width * 0.18, size.height * 0.66);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: const <Color>[
          Color(0x33FF6B2B),
          Color(0x18FF4500),
          Color(0x00FF4500),
        ],
      ).createShader(
        Rect.fromCircle(center: glowCenter, radius: 50),
      );
    canvas.drawCircle(glowCenter, 50, glowPaint);

    // --- Kente pattern border (top edge) ---
    final kentePaint = Paint()..strokeWidth = 3;
    const kenteColors = <Color>[
      Color(0x55FFD700),
      Color(0x55FF4500),
      Color(0x5548A14D),
      Color(0x551E90FF),
    ];
    const stripeW = 20.0;
    for (double x = 0; x < size.width; x += stripeW) {
      final colorIndex = (x ~/ stripeW) % kenteColors.length;
      kentePaint.color = kenteColors[colorIndex];
      canvas.drawRect(
        Rect.fromLTWH(x, 0, stripeW, 5),
        kentePaint,
      );
    }

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

    // Wood grain stripes
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
  bool shouldRepaint(covariant GhanaKitchenPainter oldDelegate) => false;
}
