import 'dart:math';

import 'package:flutter/material.dart';

/// CustomPainter outlines for the United States coloring pack.
///
/// Same approach as ghana_outlines.dart: black strokes on transparent,
/// layered on top of the kid's coloring.

final _outlinePaint = Paint()
  ..color = Colors.black
  ..strokeWidth = 2.5
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

// ---------------------------------------------------------------------------
// 1. American Landmarks — Statue of Liberty silhouette
// ---------------------------------------------------------------------------
void paintAmericanLandmarks(Canvas canvas, Size size) {
  final paint = _outlinePaint;
  final cx = size.width / 2;
  final baseY = size.height * 0.88;
  final topY = size.height * 0.08;

  // Pedestal
  final pedestal = Path()
    ..moveTo(cx - size.width * 0.18, baseY)
    ..lineTo(cx - size.width * 0.14, baseY - size.height * 0.18)
    ..lineTo(cx + size.width * 0.14, baseY - size.height * 0.18)
    ..lineTo(cx + size.width * 0.18, baseY)
    ..close();
  canvas.drawPath(pedestal, paint);

  // Body — tapered trapezoid
  final bodyBot = baseY - size.height * 0.18;
  final bodyTop = size.height * 0.3;
  final body = Path()
    ..moveTo(cx - size.width * 0.10, bodyBot)
    ..lineTo(cx - size.width * 0.07, bodyTop)
    ..lineTo(cx + size.width * 0.07, bodyTop)
    ..lineTo(cx + size.width * 0.10, bodyBot)
    ..close();
  canvas.drawPath(body, paint);

  // Head — circle
  final headR = size.width * 0.055;
  final headY = bodyTop - headR * 0.5;
  canvas.drawCircle(Offset(cx, headY), headR, paint);

  // Crown — 7 spikes
  final crownBase = headY - headR;
  for (var i = 0; i < 7; i++) {
    final angle = -pi + (pi * i / 6);
    final x = cx + headR * 1.6 * cos(angle);
    final y = crownBase + headR * 1.6 * sin(angle) - headR * 0.3;
    canvas.drawLine(Offset(cx, crownBase), Offset(x, y), paint);
  }

  // Torch — raised right arm
  final torchX = cx + size.width * 0.12;
  final torchY = topY + size.height * 0.04;
  canvas.drawLine(
    Offset(cx + size.width * 0.05, bodyTop + size.height * 0.04),
    Offset(torchX, torchY + size.height * 0.06),
    paint,
  );
  // Flame
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(torchX, torchY),
      width: size.width * 0.06,
      height: size.height * 0.06,
    ),
    paint,
  );

  // Tablet — left arm
  final tabX = cx - size.width * 0.10;
  final tabY = bodyTop + size.height * 0.12;
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(tabX, tabY),
      width: size.width * 0.08,
      height: size.height * 0.1,
    ),
    paint,
  );

  // Ground line
  canvas.drawLine(
    Offset(size.width * 0.1, baseY),
    Offset(size.width * 0.9, baseY),
    paint,
  );
}

// ---------------------------------------------------------------------------
// 2. Kids of America — three stick-figure children holding hands
// ---------------------------------------------------------------------------
void paintKidsOfAmerica(Canvas canvas, Size size) {
  final paint = _outlinePaint;
  final groundY = size.height * 0.82;
  final spacing = size.width / 4;

  for (var i = 0; i < 3; i++) {
    final cx = spacing * (i + 1);
    final headY = size.height * 0.28;
    final headR = size.width * 0.06;

    // Head
    canvas.drawCircle(Offset(cx, headY), headR, paint);

    // Smile
    final smileRect = Rect.fromCenter(
      center: Offset(cx, headY + headR * 0.2),
      width: headR * 0.8,
      height: headR * 0.6,
    );
    canvas.drawArc(smileRect, 0.2, pi * 0.6, false, paint);

    // Body
    final bodyTop = headY + headR;
    final bodyBot = size.height * 0.58;
    canvas.drawLine(Offset(cx, bodyTop), Offset(cx, bodyBot), paint);

    // Legs
    canvas.drawLine(
      Offset(cx, bodyBot),
      Offset(cx - size.width * 0.06, groundY),
      paint,
    );
    canvas.drawLine(
      Offset(cx, bodyBot),
      Offset(cx + size.width * 0.06, groundY),
      paint,
    );

    // Arms (reaching toward neighbors)
    final armY = bodyTop + (bodyBot - bodyTop) * 0.25;
    canvas.drawLine(
      Offset(cx, armY),
      Offset(cx - spacing * 0.42, armY - size.height * 0.02),
      paint,
    );
    canvas.drawLine(
      Offset(cx, armY),
      Offset(cx + spacing * 0.42, armY - size.height * 0.02),
      paint,
    );
  }

  // Ground
  canvas.drawLine(
    Offset(size.width * 0.08, groundY),
    Offset(size.width * 0.92, groundY),
    paint,
  );

  // Small hearts between kids
  for (var i = 0; i < 2; i++) {
    final hx = spacing * (i + 1) + spacing * 0.5;
    final hy = size.height * 0.2;
    _drawHeart(canvas, Offset(hx, hy), size.width * 0.035, paint);
  }
}

void _drawHeart(Canvas canvas, Offset center, double r, Paint paint) {
  final path = Path()
    ..moveTo(center.dx, center.dy + r)
    ..cubicTo(
      center.dx - r * 1.5, center.dy - r * 0.5,
      center.dx - r * 0.5, center.dy - r * 1.5,
      center.dx, center.dy - r * 0.5,
    )
    ..cubicTo(
      center.dx + r * 0.5, center.dy - r * 1.5,
      center.dx + r * 1.5, center.dy - r * 0.5,
      center.dx, center.dy + r,
    );
  canvas.drawPath(path, paint);
}

// ---------------------------------------------------------------------------
// 3. Music & Jazz — saxophone outline
// ---------------------------------------------------------------------------
void paintMusicJazz(Canvas canvas, Size size) {
  final paint = _outlinePaint;
  final cx = size.width / 2;

  // Saxophone body — a curved tube shape
  final saxBody = Path()
    ..moveTo(cx + size.width * 0.05, size.height * 0.12)
    ..quadraticBezierTo(
      cx + size.width * 0.2, size.height * 0.25,
      cx + size.width * 0.18, size.height * 0.45,
    )
    ..quadraticBezierTo(
      cx + size.width * 0.15, size.height * 0.6,
      cx - size.width * 0.05, size.height * 0.7,
    )
    ..quadraticBezierTo(
      cx - size.width * 0.2, size.height * 0.78,
      cx - size.width * 0.15, size.height * 0.85,
    );
  canvas.drawPath(saxBody, paint);

  // Bell (flared end)
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(cx - size.width * 0.12, size.height * 0.87),
      width: size.width * 0.2,
      height: size.height * 0.08,
    ),
    paint,
  );

  // Mouthpiece
  canvas.drawLine(
    Offset(cx + size.width * 0.05, size.height * 0.12),
    Offset(cx - size.width * 0.02, size.height * 0.06),
    paint,
  );

  // Keys — small circles along the body
  for (var i = 0; i < 5; i++) {
    final t = 0.25 + i * 0.1;
    final kx = cx + size.width * (0.17 - i * 0.05);
    final ky = size.height * t;
    canvas.drawCircle(Offset(kx, ky), size.width * 0.02, paint);
  }

  // Musical notes floating around
  _drawMusicNote(canvas, Offset(size.width * 0.18, size.height * 0.2), size.width * 0.04, paint);
  _drawMusicNote(canvas, Offset(size.width * 0.78, size.height * 0.15), size.width * 0.035, paint);
  _drawMusicNote(canvas, Offset(size.width * 0.82, size.height * 0.35), size.width * 0.04, paint);
  _drawMusicNote(canvas, Offset(size.width * 0.22, size.height * 0.5), size.width * 0.03, paint);
}

void _drawMusicNote(Canvas canvas, Offset pos, double r, Paint paint) {
  // Note head (filled oval)
  canvas.drawOval(
    Rect.fromCenter(center: pos, width: r * 2, height: r * 1.4),
    paint,
  );
  // Stem
  canvas.drawLine(
    Offset(pos.dx + r, pos.dy),
    Offset(pos.dx + r, pos.dy - r * 3),
    paint,
  );
  // Flag
  canvas.drawArc(
    Rect.fromLTWH(pos.dx + r, pos.dy - r * 3, r * 1.5, r * 1.5),
    -pi / 2,
    pi / 2,
    false,
    paint,
  );
}

// ---------------------------------------------------------------------------
// 4. National Parks — mountain landscape with trees
// ---------------------------------------------------------------------------
void paintNationalParks(Canvas canvas, Size size) {
  final paint = _outlinePaint;
  final groundY = size.height * 0.75;

  // Mountain 1 (left, taller)
  final m1 = Path()
    ..moveTo(size.width * 0.05, groundY)
    ..lineTo(size.width * 0.3, size.height * 0.12)
    ..lineTo(size.width * 0.55, groundY);
  canvas.drawPath(m1, paint);

  // Snow cap on mountain 1
  final snow1 = Path()
    ..moveTo(size.width * 0.22, size.height * 0.22)
    ..lineTo(size.width * 0.3, size.height * 0.12)
    ..lineTo(size.width * 0.38, size.height * 0.22)
    ..lineTo(size.width * 0.34, size.height * 0.25)
    ..lineTo(size.width * 0.3, size.height * 0.22)
    ..lineTo(size.width * 0.26, size.height * 0.25)
    ..close();
  canvas.drawPath(snow1, paint);

  // Mountain 2 (right, shorter)
  final m2 = Path()
    ..moveTo(size.width * 0.4, groundY)
    ..lineTo(size.width * 0.68, size.height * 0.25)
    ..lineTo(size.width * 0.95, groundY);
  canvas.drawPath(m2, paint);

  // Snow cap on mountain 2
  final snow2 = Path()
    ..moveTo(size.width * 0.62, size.height * 0.33)
    ..lineTo(size.width * 0.68, size.height * 0.25)
    ..lineTo(size.width * 0.74, size.height * 0.33)
    ..close();
  canvas.drawPath(snow2, paint);

  // Pine trees in foreground
  for (final tx in [0.12, 0.25, 0.72, 0.85]) {
    _drawPineTree(
      canvas,
      Offset(size.width * tx, groundY),
      size.width * 0.06,
      size.height * 0.15,
      paint,
    );
  }

  // Sun
  canvas.drawCircle(
    Offset(size.width * 0.82, size.height * 0.12),
    size.width * 0.06,
    paint,
  );
  // Sun rays
  for (var i = 0; i < 8; i++) {
    final angle = i * pi / 4;
    final sx = size.width * 0.82;
    final sy = size.height * 0.12;
    final r1 = size.width * 0.075;
    final r2 = size.width * 0.1;
    canvas.drawLine(
      Offset(sx + r1 * cos(angle), sy + r1 * sin(angle)),
      Offset(sx + r2 * cos(angle), sy + r2 * sin(angle)),
      paint,
    );
  }

  // Ground line
  canvas.drawLine(
    Offset(size.width * 0.02, groundY),
    Offset(size.width * 0.98, groundY),
    paint,
  );
}

void _drawPineTree(
    Canvas canvas, Offset base, double w, double h, Paint paint) {
  // Trunk
  canvas.drawLine(base, Offset(base.dx, base.dy - h), paint);
  // Three triangle layers
  for (var i = 0; i < 3; i++) {
    final y = base.dy - h * (0.4 + i * 0.22);
    final spread = w * (1.0 - i * 0.2);
    final tri = Path()
      ..moveTo(base.dx, y - h * 0.2)
      ..lineTo(base.dx - spread, y)
      ..lineTo(base.dx + spread, y)
      ..close();
    canvas.drawPath(tri, paint);
  }
}

// ---------------------------------------------------------------------------
// 5. Food Favorites — burger, hot dog, pizza slice, donut
// ---------------------------------------------------------------------------
void paintFoodFavorites(Canvas canvas, Size size) {
  final paint = _outlinePaint;

  // Burger (top-left quadrant)
  final bCx = size.width * 0.28;
  final bCy = size.height * 0.28;
  final bW = size.width * 0.2;
  final bH = size.height * 0.08;
  // Top bun
  canvas.drawArc(
    Rect.fromCenter(center: Offset(bCx, bCy - bH), width: bW * 2, height: bH * 2),
    pi,
    pi,
    false,
    paint,
  );
  canvas.drawLine(
    Offset(bCx - bW, bCy - bH),
    Offset(bCx + bW, bCy - bH),
    paint,
  );
  // Patty
  canvas.drawLine(
    Offset(bCx - bW * 0.9, bCy - bH * 0.3),
    Offset(bCx + bW * 0.9, bCy - bH * 0.3),
    paint,
  );
  // Bottom bun
  canvas.drawLine(
    Offset(bCx - bW, bCy),
    Offset(bCx + bW, bCy),
    paint,
  );
  canvas.drawArc(
    Rect.fromCenter(center: Offset(bCx, bCy), width: bW * 2, height: bH),
    0,
    pi,
    false,
    paint,
  );

  // Pizza slice (top-right quadrant)
  final pCx = size.width * 0.72;
  final pCy = size.height * 0.28;
  final pR = size.width * 0.16;
  final slice = Path()
    ..moveTo(pCx, pCy + pR * 0.4)
    ..lineTo(pCx - pR * 0.6, pCy - pR)
    ..arcToPoint(
      Offset(pCx + pR * 0.6, pCy - pR),
      radius: Radius.circular(pR),
    )
    ..close();
  canvas.drawPath(slice, paint);
  // Pepperoni circles
  canvas.drawCircle(Offset(pCx - pR * 0.15, pCy - pR * 0.3), pR * 0.08, paint);
  canvas.drawCircle(Offset(pCx + pR * 0.15, pCy - pR * 0.5), pR * 0.08, paint);
  canvas.drawCircle(Offset(pCx, pCy - pR * 0.1), pR * 0.08, paint);

  // Hot dog (bottom-left quadrant)
  final hCx = size.width * 0.28;
  final hCy = size.height * 0.68;
  final hW = size.width * 0.2;
  final hH = size.height * 0.04;
  // Bun
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(hCx, hCy), width: hW * 2, height: hH * 2.5),
      Radius.circular(hH),
    ),
    paint,
  );
  // Sausage line
  canvas.drawLine(
    Offset(hCx - hW * 0.85, hCy),
    Offset(hCx + hW * 0.85, hCy),
    Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke,
  );

  // Donut (bottom-right quadrant)
  final dCx = size.width * 0.72;
  final dCy = size.height * 0.68;
  final dR = size.width * 0.11;
  // Outer ring
  canvas.drawCircle(Offset(dCx, dCy), dR, paint);
  // Inner hole
  canvas.drawCircle(Offset(dCx, dCy), dR * 0.4, paint);
  // Icing drip (wavy top half)
  for (var i = 0; i < 6; i++) {
    final angle = pi + (pi * i / 5);
    final x = dCx + dR * 0.85 * cos(angle);
    final y = dCy + dR * 0.85 * sin(angle);
    canvas.drawCircle(Offset(x, y), dR * 0.08, paint);
  }
}

// ---------------------------------------------------------------------------
// 6. Transportation & Cities — taxi, bus, city skyline
// ---------------------------------------------------------------------------
void paintTransportCities(Canvas canvas, Size size) {
  final paint = _outlinePaint;
  final groundY = size.height * 0.78;

  // City skyline in background
  final buildings = [
    [0.08, 0.32], [0.18, 0.22], [0.28, 0.38],
    [0.38, 0.18], [0.50, 0.28], [0.60, 0.15],
    [0.70, 0.30], [0.80, 0.25], [0.90, 0.35],
  ];
  final bWidth = size.width * 0.08;
  for (final b in buildings) {
    final x = size.width * b[0];
    final topY = size.height * b[1];
    canvas.drawRect(
      Rect.fromLTRB(x - bWidth / 2, topY, x + bWidth / 2, groundY * 0.7),
      paint,
    );
    // Windows
    for (var wy = topY + 8; wy < groundY * 0.7 - 8; wy += 12) {
      canvas.drawRect(
        Rect.fromLTWH(x - bWidth * 0.2, wy, bWidth * 0.15, 6),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + bWidth * 0.08, wy, bWidth * 0.15, 6),
        paint,
      );
    }
  }

  // Road
  canvas.drawLine(
    Offset(0, groundY),
    Offset(size.width, groundY),
    paint,
  );

  // Taxi (left side)
  final tCx = size.width * 0.3;
  final tY = groundY - size.height * 0.04;
  _drawCar(canvas, Offset(tCx, tY), size.width * 0.18, size.height * 0.08, paint);

  // Bus (right side)
  final busCx = size.width * 0.72;
  final busY = groundY - size.height * 0.05;
  final busW = size.width * 0.22;
  final busH = size.height * 0.1;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(busCx, busY), width: busW, height: busH),
      const Radius.circular(6),
    ),
    paint,
  );
  // Bus windows
  for (var i = 0; i < 4; i++) {
    final wx = busCx - busW * 0.35 + i * busW * 0.22;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(wx, busY - busH * 0.15),
        width: busW * 0.15,
        height: busH * 0.35,
      ),
      paint,
    );
  }
  // Bus wheels
  canvas.drawCircle(Offset(busCx - busW * 0.3, busY + busH * 0.5), size.width * 0.02, paint);
  canvas.drawCircle(Offset(busCx + busW * 0.3, busY + busH * 0.5), size.width * 0.02, paint);
}

void _drawCar(Canvas canvas, Offset center, double w, double h, Paint paint) {
  // Body
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      const Radius.circular(4),
    ),
    paint,
  );
  // Roof
  final roofPath = Path()
    ..moveTo(center.dx - w * 0.3, center.dy - h * 0.5)
    ..lineTo(center.dx - w * 0.15, center.dy - h)
    ..lineTo(center.dx + w * 0.15, center.dy - h)
    ..lineTo(center.dx + w * 0.3, center.dy - h * 0.5);
  canvas.drawPath(roofPath, paint);
  // Wheels
  canvas.drawCircle(Offset(center.dx - w * 0.3, center.dy + h * 0.5), w * 0.08, paint);
  canvas.drawCircle(Offset(center.dx + w * 0.3, center.dy + h * 0.5), w * 0.08, paint);
}

// ---------------------------------------------------------------------------
// 7. US Map — simplified outline of the continental US
// ---------------------------------------------------------------------------
void paintUSMap(Canvas canvas, Size size) {
  final paint = _outlinePaint..strokeWidth = 2.5;
  // Simplified continental US outline scaled to canvas
  final sx = size.width;
  final sy = size.height;
  final padX = sx * 0.08;
  final padY = sy * 0.12;
  final w = sx - padX * 2;
  final h = sy - padY * 2;

  // Simplified US polygon (proportional points)
  final points = [
    Offset(padX + w * 0.02, padY + h * 0.22), // WA top-left
    Offset(padX + w * 0.14, padY + h * 0.02), // WA top
    Offset(padX + w * 0.35, padY + h * 0.03), // MT/ND border
    Offset(padX + w * 0.5, padY + h * 0.05),  // MN
    Offset(padX + w * 0.65, padY + h * 0.1),  // WI/MI
    Offset(padX + w * 0.72, padY + h * 0.08), // MI
    Offset(padX + w * 0.78, padY + h * 0.15), // NY
    Offset(padX + w * 0.92, padY + h * 0.18), // ME
    Offset(padX + w * 0.95, padY + h * 0.22), // New England
    Offset(padX + w * 0.88, padY + h * 0.3),  // NJ/DE
    Offset(padX + w * 0.85, padY + h * 0.38), // VA
    Offset(padX + w * 0.82, padY + h * 0.45), // NC
    Offset(padX + w * 0.78, padY + h * 0.52), // SC
    Offset(padX + w * 0.75, padY + h * 0.6),  // GA
    Offset(padX + w * 0.78, padY + h * 0.72), // FL panhandle
    Offset(padX + w * 0.82, padY + h * 0.9),  // FL tip
    Offset(padX + w * 0.72, padY + h * 0.72), // FL west
    Offset(padX + w * 0.55, padY + h * 0.7),  // Gulf coast
    Offset(padX + w * 0.45, padY + h * 0.75), // LA
    Offset(padX + w * 0.38, padY + h * 0.82), // TX south
    Offset(padX + w * 0.22, padY + h * 0.92), // TX tip
    Offset(padX + w * 0.18, padY + h * 0.78), // TX west
    Offset(padX + w * 0.08, padY + h * 0.72), // NM
    Offset(padX + w * 0.04, padY + h * 0.55), // AZ
    Offset(padX + w * 0.0, padY + h * 0.45),  // CA south
    Offset(padX + w * 0.0, padY + h * 0.3),   // CA north
  ];

  final mapPath = Path()..moveTo(points.first.dx, points.first.dy);
  for (var i = 1; i < points.length; i++) {
    mapPath.lineTo(points[i].dx, points[i].dy);
  }
  mapPath.close();
  canvas.drawPath(mapPath, paint);

  // Star in the center (capital area)
  final starCx = padX + w * 0.48;
  final starCy = padY + h * 0.42;
  _drawStar(canvas, Offset(starCx, starCy), w * 0.04, paint);

  // Small Alaska inset (bottom-left)
  final akX = padX + w * 0.05;
  final akY = padY + h * 0.82;
  final akW = w * 0.12;
  final akH = h * 0.12;
  canvas.drawRect(
    Rect.fromLTWH(akX - 4, akY - 4, akW + 8, akH + 8),
    paint,
  );
  final ak = Path()
    ..moveTo(akX, akY + akH * 0.3)
    ..lineTo(akX + akW * 0.3, akY)
    ..lineTo(akX + akW * 0.7, akY + akH * 0.1)
    ..lineTo(akX + akW, akY + akH * 0.5)
    ..lineTo(akX + akW * 0.6, akY + akH)
    ..lineTo(akX, akY + akH * 0.7)
    ..close();
  canvas.drawPath(ak, paint);

  // Small Hawaii inset
  final hiX = padX + w * 0.2;
  final hiY = padY + h * 0.85;
  canvas.drawRect(
    Rect.fromLTWH(hiX - 4, hiY - 4, w * 0.1 + 8, h * 0.1 + 8),
    paint,
  );
  for (var i = 0; i < 4; i++) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(hiX + w * 0.02 + i * w * 0.022, hiY + h * 0.05),
        width: w * 0.02,
        height: h * 0.03,
      ),
      paint,
    );
  }
}

void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
  final innerR = r * 0.4;
  final star = Path();
  for (var i = 0; i < 10; i++) {
    final rad = i.isEven ? r : innerR;
    final angle = (i * pi / 5) - (pi / 2);
    final x = center.dx + rad * cos(angle);
    final y = center.dy + rad * sin(angle);
    if (i == 0) {
      star.moveTo(x, y);
    } else {
      star.lineTo(x, y);
    }
  }
  star.close();
  canvas.drawPath(star, paint);
}
