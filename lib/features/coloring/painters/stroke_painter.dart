import 'package:flutter/material.dart';

import '../models/drawing_state.dart';

/// Paints a list of strokes (+ an optional in-progress stroke) onto [canvas].
///
/// Uses [saveLayer] so eraser strokes with [BlendMode.clear] punch
/// transparent holes in the stroke layer without affecting the background.
/// Call this AFTER painting the white background.
void paintStrokes(
  Canvas canvas,
  Size size, {
  required List<Stroke> strokes,
  Stroke? activeStroke,
}) {
  // Isolate all strokes in a layer so BlendMode.clear only
  // erases within this layer, revealing the background beneath.
  canvas.saveLayer(Offset.zero & size, Paint());

  for (final stroke in strokes) {
    _paintStroke(canvas, stroke);
  }
  if (activeStroke != null) {
    _paintStroke(canvas, activeStroke);
  }

  canvas.restore();
}

/// Renders a single stroke with smooth bezier curves.
void _paintStroke(Canvas canvas, Stroke stroke) {
  if (stroke.points.isEmpty) return;

  final paint = Paint()
    ..strokeWidth = stroke.width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  // Eraser: BlendMode.clear removes pixels from the layer.
  if (stroke.isEraser) {
    paint
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;
  } else {
    paint.color = stroke.color;
  }

  // Single tap → draw a dot.
  if (stroke.points.length == 1) {
    canvas.drawCircle(
      stroke.points.first,
      stroke.width / 2,
      paint..style = PaintingStyle.fill,
    );
    return;
  }

  // Two points → straight line (not enough data for bezier).
  if (stroke.points.length == 2) {
    canvas.drawLine(stroke.points[0], stroke.points[1], paint);
    return;
  }

  // 3+ points → smooth quadratic bezier through midpoints.
  //
  // Instead of jagged lineTo segments, we compute the midpoint between
  // each pair of raw touch samples and draw a quadratic bezier curve
  // that uses the original sample as the control point.  The result
  // passes smoothly through every midpoint — much nicer for kids'
  // freehand drawing.
  final pts = stroke.points;
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);

  for (var i = 1; i < pts.length - 1; i++) {
    final mid = Offset(
      (pts[i].dx + pts[i + 1].dx) / 2,
      (pts[i].dy + pts[i + 1].dy) / 2,
    );
    path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
  }
  // Connect to the final point.
  path.lineTo(pts.last.dx, pts.last.dy);

  canvas.drawPath(path, paint);
}
