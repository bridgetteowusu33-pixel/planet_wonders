import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/coloring_page.dart';
import '../models/drawing_state.dart';
import '../painters/flood_fill.dart';
import '../painters/stroke_painter.dart';
import '../providers/drawing_provider.dart';

/// A canvas that layers:
///   1. White background
///   2. Faint line-art guide (15% opacity outline — visible under coloring)
///   3. Fill images (flood-fill results)
///   4. Kid's brush strokes
///   5. Bold outline on top (always visible, like a real coloring book)
class ColoringCanvas extends ConsumerStatefulWidget {
  const ColoringCanvas({
    super.key,
    required this.canvasKey,
    required this.paintOutline,
  });

  final GlobalKey canvasKey;
  final OutlinePainter paintOutline;

  @override
  ConsumerState<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends ConsumerState<ColoringCanvas> {
  Future<void> _handleFillTap(Offset localPosition) async {
    final notifier = ref.read(drawingProvider.notifier);
    final drawingState = ref.read(drawingProvider);

    // Prevent multiple fills at once.
    if (drawingState.filling) return;
    notifier.setFilling(true);

    try {
      // Capture the current canvas as a bitmap.
      final boundary = widget.canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        notifier.setFilling(false);
        return;
      }

      final pixelRatio = MediaQuery.devicePixelRatioOf(context);
      final image = await boundary.toImage(pixelRatio: pixelRatio);

      // Convert tap position to pixel coordinates.
      final startX = (localPosition.dx * pixelRatio).round();
      final startY = (localPosition.dy * pixelRatio).round();

      final fillResult = await floodFill(
        source: image,
        startX: startX,
        startY: startY,
        fillColor: ref.read(drawingProvider).currentColor,
      );

      image.dispose();

      if (fillResult != null && mounted) {
        notifier.addFillImage(fillResult);
      } else {
        notifier.setFilling(false);
      }
    } catch (_) {
      if (mounted) notifier.setFilling(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawingState = ref.watch(drawingProvider);
    final isFillTool = drawingState.currentTool == DrawingTool.fill;

    return GestureDetector(
      onTapDown: isFillTool
          ? (d) => _handleFillTap(d.localPosition)
          : null,
      onPanStart: isFillTool
          ? null
          : (d) => ref
              .read(drawingProvider.notifier)
              .startStroke(d.localPosition),
      onPanUpdate: isFillTool
          ? null
          : (d) => ref
              .read(drawingProvider.notifier)
              .updateStroke(d.localPosition),
      onPanEnd: isFillTool
          ? null
          : (_) => ref.read(drawingProvider.notifier).endStroke(),
      child: RepaintBoundary(
        key: widget.canvasKey,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              CustomPaint(
                painter: _ColoringPainter(
                  strokes: drawingState.strokes,
                  activeStroke: drawingState.activeStroke,
                  fillImages: drawingState.fillImages,
                  paintOutline: widget.paintOutline,
                ),
                child: const SizedBox.expand(),
              ),
              // Show a subtle spinner while fill is processing.
              if (drawingState.filling)
                const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Color matrix that preserves RGB but scales alpha to 15%.
/// Used to render the outline as a faint background guide.
const _guideFilter = ColorFilter.matrix(<double>[
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 0.15, 0, //
]);

class _ColoringPainter extends CustomPainter {
  _ColoringPainter({
    required this.strokes,
    this.activeStroke,
    required this.fillImages,
    required this.paintOutline,
  });

  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final List<ui.Image> fillImages;
  final OutlinePainter paintOutline;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    // 1. White background
    canvas.drawRect(bounds, Paint()..color = Colors.white);

    // 2. Faint line-art guide (15% opacity)
    canvas.saveLayer(bounds, Paint()..colorFilter = _guideFilter);
    paintOutline(canvas, size);
    canvas.restore();

    // 3. Fill images (flood-fill results, scaled down from pixel coords)
    for (final img in fillImages) {
      final src = Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
      canvas.drawImageRect(img, src, bounds, Paint());
    }

    // 4. Kid's strokes in an isolated layer (eraser uses BlendMode.clear)
    paintStrokes(canvas, size, strokes: strokes, activeStroke: activeStroke);

    // 5. Bold outline on top — always visible
    paintOutline(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _ColoringPainter old) => true;
}
