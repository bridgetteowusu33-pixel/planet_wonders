import 'package:flutter/material.dart';

/// Draws a modern American kitchen background.
///
/// Elements: subway tile walls, chrome fridge outline,
/// star-spangled window valance, pie on counter, clean white counter.
class UsaKitchenPainter extends CustomPainter {
  const UsaKitchenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // --- Clean light grey-blue wall ---
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFFF0F4F8),
            Color(0xFFE8EEF4),
            Color(0xFFDEE6EE),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );

    // --- Subway tile pattern ---
    final tilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = const Color(0x14A0B0C0);
    final wallBottom = size.height * 0.72;
    const tileH = 24.0;
    const tileW = 48.0;
    int row = 0;
    for (double y = 0; y < wallBottom; y += tileH) {
      final offset = (row % 2 == 0) ? 0.0 : tileW / 2;
      for (double x = -tileW + offset; x < size.width + tileW; x += tileW) {
        canvas.drawRect(Rect.fromLTWH(x, y, tileW, tileH), tilePaint);
      }
      row++;
    }

    // --- Window (rectangular, modern) ---
    final windowCenter = Offset(size.width * 0.5, size.height * 0.08);
    final windowRect = Rect.fromCenter(
      center: windowCenter,
      width: size.width * 0.30,
      height: size.height * 0.18,
    );
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x5587CEEB), Color(0x33E0F0FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(windowRect);
    final windowRRect = RRect.fromRectAndRadius(
      windowRect,
      const Radius.circular(6),
    );
    canvas.drawRRect(windowRRect, skyPaint);

    // Window frame
    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0x44607080);
    canvas.drawRRect(windowRRect, framePaint);
    // Cross bars
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top),
      Offset(windowRect.center.dx, windowRect.bottom),
      framePaint,
    );
    canvas.drawLine(
      Offset(windowRect.left, windowRect.center.dy),
      Offset(windowRect.right, windowRect.center.dy),
      framePaint,
    );

    // Star-spangled valance (top of window)
    final valanceRect = Rect.fromLTWH(
      windowRect.left - 6,
      windowRect.top - 8,
      windowRect.width + 12,
      12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(valanceRect, const Radius.circular(3)),
      Paint()..color = const Color(0x33B22234),
    );
    // Small stars on valance
    final starPaint = Paint()..color = const Color(0x55FFFFFF);
    for (int i = 0; i < 5; i++) {
      final sx = valanceRect.left + 10 + i * (valanceRect.width - 20) / 4;
      canvas.drawCircle(Offset(sx, valanceRect.center.dy), 2.5, starPaint);
    }

    // --- Chrome fridge outline (right side) ---
    final fridgeRect = Rect.fromLTWH(
      size.width * 0.82,
      size.height * 0.22,
      size.width * 0.14,
      size.height * 0.46,
    );
    final fridgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x22607080);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fridgeRect, const Radius.circular(6)),
      fridgePaint,
    );
    // Fridge handle
    final handleX = fridgeRect.left + 6;
    canvas.drawLine(
      Offset(handleX, fridgeRect.top + 14),
      Offset(handleX, fridgeRect.center.dy - 6),
      Paint()
        ..color = const Color(0x30808080)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    // Divider line
    canvas.drawLine(
      Offset(fridgeRect.left + 4, fridgeRect.center.dy),
      Offset(fridgeRect.right - 4, fridgeRect.center.dy),
      Paint()
        ..color = const Color(0x18607080)
        ..strokeWidth = 1,
    );

    // --- Shelf (left side) with pie ---
    final shelfY = size.height * 0.35;
    final shelfPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x33A0A8B0), Color(0x22808890)],
      ).createShader(Rect.fromLTWH(0, shelfY, size.width * 0.32, 8));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.04, shelfY, size.width * 0.28, 5),
        const Radius.circular(3),
      ),
      shelfPaint,
    );

    // Pie on shelf
    final pieX = size.width * 0.12;
    // Pie dish
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(pieX, shelfY - 6),
        width: 28,
        height: 14,
      ),
      0,
      3.14159,
      true,
      Paint()..color = const Color(0x30D4A060),
    );
    // Pie top (lattice look)
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(pieX, shelfY - 10),
        width: 24,
        height: 12,
      ),
      3.14159,
      3.14159,
      true,
      Paint()..color = const Color(0x25C88030),
    );

    // Cookie jar
    final jarPaint = Paint()..color = const Color(0x28607080);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.22, shelfY - 22, 16, 22),
        const Radius.circular(4),
      ),
      jarPaint,
    );
    // Jar lid
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.215, shelfY - 25, 20, 5),
        const Radius.circular(2),
      ),
      jarPaint,
    );

    // --- Red-white-blue accent stripe (top edge) ---
    final stripColors = <Color>[
      const Color(0x44B22234),
      const Color(0x30FFFFFF),
      const Color(0x443C3B6E),
    ];
    final stripeW = size.width / 3;
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(stripeW * i, 0, stripeW, 4),
        Paint()..color = stripColors[i],
      );
    }

    // --- Clean white counter ---
    final counterTop = Rect.fromLTWH(
      0,
      size.height * 0.72,
      size.width,
      size.height * 0.29,
    );
    final edgePaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFE0E4E8), Color(0xFFD0D6DC)],
      ).createShader(Rect.fromLTWH(0, counterTop.top, size.width, 6));
    canvas.drawRect(
      Rect.fromLTWH(0, counterTop.top, size.width, 6),
      edgePaint,
    );
    final counterPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[
          Color(0xFFF8FAFB),
          Color(0xFFEEF2F5),
          Color(0xFFE4EAF0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(counterTop);
    canvas.drawRect(
      Rect.fromLTWH(0, counterTop.top + 6, size.width, counterTop.height - 6),
      counterPaint,
    );

    // Subtle marble veins
    final veinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = const Color(0x0AA0B0C0);
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(
        Offset(x, counterTop.top + 10),
        Offset(x + 40, counterTop.bottom - 10),
        veinPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant UsaKitchenPainter oldDelegate) => false;
}
