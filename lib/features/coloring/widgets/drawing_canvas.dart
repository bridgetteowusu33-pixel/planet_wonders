import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/drawing_state.dart';
import '../painters/stroke_painter.dart';
import '../providers/drawing_provider.dart';

/// The drawing surface — a GestureDetector feeding touch data into the
/// provider, rendered by a CustomPainter.
///
/// [canvasKey] is a GlobalKey on the RepaintBoundary so the parent can
/// capture the canvas as an image for saving.
class DrawingCanvas extends ConsumerWidget {
  const DrawingCanvas({super.key, required this.canvasKey});

  final GlobalKey canvasKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(
      drawingProvider.select((s) => (s.actions, s.activeStroke, s.currentTool)),
    );
    final actions = canvasState.$1;
    final activeStroke = canvasState.$2;
    final currentTool = canvasState.$3;
    final strokes = <Stroke>[
      for (final action in actions)
        if (action is StrokeAction) action.stroke,
    ];
    final revision = Object.hash(
      identityHashCode(actions),
      activeStroke?.points.length ?? 0,
    );

    return GestureDetector(
      onPanStart: currentTool == DrawingTool.fill
          ? null
          : (d) =>
                ref.read(drawingProvider.notifier).startStroke(d.localPosition),
      onPanUpdate: currentTool == DrawingTool.fill
          ? null
          : (d) => ref
                .read(drawingProvider.notifier)
                .updateStroke(d.localPosition),
      onPanEnd: currentTool == DrawingTool.fill
          ? null
          : (_) => ref.read(drawingProvider.notifier).endStroke(),
      child: RepaintBoundary(
        key: canvasKey,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            painter: _DrawingPainter(
              strokes: strokes,
              activeStroke: activeStroke,
              revision: revision,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _DrawingPainter extends CustomPainter {
  _DrawingPainter({
    required this.strokes,
    required this.revision,
    this.activeStroke,
  });

  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final int revision;

  @override
  void paint(Canvas canvas, Size size) {
    // White background.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Strokes in an isolated layer (eraser uses BlendMode.clear).
    paintStrokes(canvas, size, strokes: strokes, activeStroke: activeStroke);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter old) {
    return old.revision != revision;
  }
}
