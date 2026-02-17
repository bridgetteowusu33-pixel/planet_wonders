import 'dart:math';
import 'dart:ui' as ui;

import '../core/spline_path.dart';
import '../core/texture_cache.dart';
import 'brush_kind.dart';

/// Paints a stroke path with the requested brush style.
void paintBrushStroke(
  ui.Canvas canvas, {
  required List<ui.Offset> points,
  required ui.Color color,
  required double width,
  required BrushKind brush,
  required bool isEraser,
}) {
  if (points.isEmpty) return;

  final path = buildSplinePath(points);
  final strokeCap = ui.StrokeCap.round;
  final strokeJoin = ui.StrokeJoin.round;

  if (isEraser) {
    final eraser = ui.Paint()
      ..color = const ui.Color(0x00000000)
      ..blendMode = ui.BlendMode.clear
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = strokeCap
      ..strokeJoin = strokeJoin;
    _drawPathOrDot(canvas, path, points, eraser, width);
    return;
  }

  switch (brush) {
    case BrushKind.marker:
      final paint = ui.Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = strokeCap
        ..strokeJoin = strokeJoin;
      _drawPathOrDot(canvas, path, points, paint, width);
      break;

    case BrushKind.crayon:
      final base = ui.Paint()
        ..color = color.withValues(alpha: 0.72)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = strokeCap
        ..strokeJoin = strokeJoin;
      _drawPathOrDot(canvas, path, points, base, width);

      // Texture layer with bitmap-noise shader for waxy crayon feel.
      final texture =
          ColoringTextureCache.instance.buildCrayonTexturePaint(color)
            ?..style = ui.PaintingStyle.stroke
            ..strokeWidth = width * 0.95
            ..strokeCap = strokeCap
            ..strokeJoin = strokeJoin;
      if (texture != null) {
        _drawPathOrDot(canvas, path, points, texture, width);
      } else {
        // Fallback stipple when texture is still warming up.
        _paintCrayonStipple(canvas, path, color, width);
      }
      break;

    case BrushKind.soft:
      final soft = ui.Paint()
        ..color = color.withValues(alpha: 0.30)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = width * 1.15
        ..strokeCap = strokeCap
        ..strokeJoin = strokeJoin
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, width * 0.55);
      final core = ui.Paint()
        ..color = color.withValues(alpha: 0.18)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = width * 0.9
        ..strokeCap = strokeCap
        ..strokeJoin = strokeJoin
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, width * 0.25);
      _drawPathOrDot(canvas, path, points, soft, width);
      _drawPathOrDot(canvas, path, points, core, width);
      break;
  }
}

void _drawPathOrDot(
  ui.Canvas canvas,
  ui.Path path,
  List<ui.Offset> points,
  ui.Paint paint,
  double width,
) {
  if (points.length == 1) {
    canvas.drawCircle(
      points.first,
      width / 2,
      paint..style = ui.PaintingStyle.fill,
    );
  } else {
    canvas.drawPath(path, paint);
  }
}

void _paintCrayonStipple(
  ui.Canvas canvas,
  ui.Path path,
  ui.Color color,
  double width,
) {
  final rng = Random(
    (path.hashCode ^ color.toARGB32() ^ width.round()) & 0x7fffffff,
  );
  final metrics = path.computeMetrics();
  final metric = metrics.isEmpty ? null : metrics.first;
  if (metric == null) return;
  final count = max(12, (metric.length / max(2.0, width)).round());
  final dotPaint = ui.Paint()
    ..color = color.withValues(alpha: 0.2)
    ..style = ui.PaintingStyle.fill;
  for (int i = 0; i < count; i++) {
    final t = metric.length * (i / count);
    final tangent = metric.getTangentForOffset(t);
    if (tangent == null) continue;
    final jitter = ui.Offset(
      (rng.nextDouble() - 0.5) * width * 0.35,
      (rng.nextDouble() - 0.5) * width * 0.35,
    );
    canvas.drawCircle(
      tangent.position + jitter,
      max(0.7, width * 0.08),
      dotPaint,
    );
  }
}
