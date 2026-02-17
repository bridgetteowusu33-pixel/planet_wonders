import 'dart:ui';

/// Builds a smooth path through [points] using Catmull-Rom -> cubic conversion.
///
/// This yields smoother kid strokes than polyline/quadratic midpoint approaches
/// while staying stable for short strokes.
Path buildSplinePath(List<Offset> points) {
  final path = Path();
  if (points.isEmpty) return path;
  if (points.length == 1) {
    path.addOval(Rect.fromCircle(center: points.first, radius: 0.5));
    return path;
  }
  if (points.length == 2) {
    path
      ..moveTo(points.first.dx, points.first.dy)
      ..lineTo(points.last.dx, points.last.dy);
    return path;
  }

  path.moveTo(points.first.dx, points.first.dy);

  for (int i = 0; i < points.length - 1; i++) {
    final p0 = i == 0 ? points[i] : points[i - 1];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = (i + 2 < points.length) ? points[i + 2] : p2;

    // Catmull-Rom to cubic Bezier conversion.
    final c1 = Offset(
      p1.dx + (p2.dx - p0.dx) / 6.0,
      p1.dy + (p2.dy - p0.dy) / 6.0,
    );
    final c2 = Offset(
      p2.dx - (p3.dx - p1.dx) / 6.0,
      p2.dy - (p3.dy - p1.dy) / 6.0,
    );

    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }

  return path;
}

