import 'package:flutter/material.dart';

import '../../../coloring_engine/brushes/brush_kind.dart';
import '../../../coloring_engine/brushes/brush_renderer.dart';
import '../../../coloring_engine/core/texture_cache.dart';
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
  final usesEraser =
      (activeStroke?.isEraser ?? false) ||
      strokes.any((stroke) => stroke.isEraser);
  if (usesEraser) {
    // Isolate only when eraser is present so BlendMode.clear affects strokes only.
    canvas.saveLayer(Offset.zero & size, Paint());
  }

  // Warm texture cache lazily (non-blocking).
  ColoringTextureCache.instance.ensureLoaded();

  for (final stroke in strokes) {
    _paintStroke(canvas, stroke);
  }
  if (activeStroke != null) {
    _paintStroke(canvas, activeStroke);
  }

  if (usesEraser) {
    canvas.restore();
  }
}

/// Renders a single stroke with smooth bezier curves.
void _paintStroke(Canvas canvas, Stroke stroke) {
  if (stroke.points.isEmpty) return;
  final brush = switch (stroke.brushType) {
    BrushType.crayon => BrushKind.crayon,
    BrushType.softBrush => BrushKind.soft,
    _ => BrushKind.marker,
  };
  paintBrushStroke(
    canvas,
    points: stroke.points,
    color: stroke.color,
    width: stroke.width,
    brush: brush,
    isEraser: stroke.isEraser,
  );
}
