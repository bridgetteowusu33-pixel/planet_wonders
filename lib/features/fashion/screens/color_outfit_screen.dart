import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/gallery_service.dart';
import '../../../core/theme/pw_theme.dart';
import '../../coloring/models/drawing_state.dart';
import '../../coloring/painters/flood_fill.dart';
import '../../coloring/painters/stroke_painter.dart';
import '../../coloring/providers/drawing_provider.dart';
import '../../coloring/widgets/brush_size_selector.dart';
import '../../coloring/widgets/color_palette.dart';
import '../../coloring/widgets/drawing_toolbar.dart';
import '../models/outfit_snapshot.dart';

/// Full-screen painting mode — draw on top of the dressed character.
///
/// Receives an [OutfitSnapshot] via GoRouter `extra` so the outfit base
/// is rendered read-only underneath a transparent drawing canvas.
class ColorOutfitScreen extends ConsumerStatefulWidget {
  const ColorOutfitScreen({super.key, required this.snapshot});

  final OutfitSnapshot snapshot;

  @override
  ConsumerState<ColorOutfitScreen> createState() => _ColorOutfitScreenState();
}

class _ColorOutfitScreenState extends ConsumerState<ColorOutfitScreen> {
  final _canvasKey = GlobalKey();
  bool _saving = false;

  Future<void> _handleFillTap(Offset localPosition) async {
    final notifier = ref.read(drawingProvider.notifier);
    final drawingState = ref.read(drawingProvider);

    if (drawingState.filling) return;
    notifier.setFilling(true);

    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        notifier.setFilling(false);
        return;
      }

      final pixelRatio = MediaQuery.devicePixelRatioOf(context);
      final image = await boundary.toImage(pixelRatio: pixelRatio);

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

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final boundary =
          _canvasKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null || !mounted) return;

      await GalleryService.saveDrawing(byteData.buffer.asUint8List());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to Gallery!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawingState = ref.watch(drawingProvider);
    final snapshot = widget.snapshot;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        title: const Text('Color Your Outfit'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            tooltip: 'Save to Gallery',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Canvas area ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            PWColors.blue.withValues(alpha: 0.12),
                            PWColors.mint.withValues(alpha: 0.12),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cW = constraints.maxWidth;
                          final cH = constraints.maxHeight;

                          const imgAspect = 1024 / 1536;
                          final containerAspect = cW / cH;

                          double bodyW, bodyH;
                          if (containerAspect > imgAspect) {
                            bodyH = cH;
                            bodyW = cH * imgAspect;
                          } else {
                            bodyW = cW;
                            bodyH = cW / imgAspect;
                          }

                          final dx = (cW - bodyW) / 2;
                          final dy = (cH - bodyH) / 2;

                          final isFillTool = drawingState.currentTool == DrawingTool.fill;

                          return Stack(
                            children: [
                              // Outfit base (read-only)
                              _OutfitBase(
                                snapshot: snapshot,
                                bodyW: bodyW,
                                bodyH: bodyH,
                                dx: dx,
                                dy: dy,
                              ),

                              // Transparent drawing canvas on top
                              Positioned.fill(
                                child: GestureDetector(
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
                                      : (_) => ref
                                          .read(drawingProvider.notifier)
                                          .endStroke(),
                                  child: Stack(
                                    children: [
                                      CustomPaint(
                                        painter: _TransparentStrokePainter(
                                          strokes: drawingState.strokes,
                                          activeStroke: drawingState.activeStroke,
                                          fillImages: drawingState.fillImages,
                                        ),
                                        child: const SizedBox.expand(),
                                      ),
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
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Toolbar: Brush, Fill, Eraser, Undo ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DrawingToolbar(),
                  SizedBox(width: 24),
                  BrushSizeSelector(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Color palette ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ColorPalette(),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Outfit base — read-only rendering of body + clothing layers
// ---------------------------------------------------------------------------

class _OutfitBase extends StatelessWidget {
  const _OutfitBase({
    required this.snapshot,
    required this.bodyW,
    required this.bodyH,
    required this.dx,
    required this.dy,
  });

  final OutfitSnapshot snapshot;
  final double bodyW;
  final double bodyH;
  final double dx;
  final double dy;

  @override
  Widget build(BuildContext context) {
    final bw = bodyW * snapshot.bodyScale;
    final bh = bodyH * snapshot.bodyScale;

    return Stack(
      children: [
        // Body
        Positioned(
          left: dx + (bodyW - bw) / 2,
          top: dy + bodyH * snapshot.bodyShiftY,
          width: bw,
          height: bh,
          child: Image.asset(snapshot.bodyAsset, fit: BoxFit.contain),
        ),

        // Clothing layers
        for (final layer in snapshot.layers)
          Positioned(
            left: dx + (bodyW - bodyW * layer.scale) / 2,
            top: dy + bodyH * layer.shiftY,
            width: bodyW * layer.scale,
            height: bodyH * layer.scale,
            child: Image.asset(layer.assetPath, fit: BoxFit.contain),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Transparent stroke painter — no white background
// ---------------------------------------------------------------------------

class _TransparentStrokePainter extends CustomPainter {
  _TransparentStrokePainter({
    required this.strokes,
    this.activeStroke,
    required this.fillImages,
  });

  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final List<ui.Image> fillImages;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    // Fill images (flood-fill results, scaled from pixel coords).
    for (final img in fillImages) {
      final src = Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
      canvas.drawImageRect(img, src, bounds, Paint());
    }

    // Strokes — no white background so the outfit shows through.
    paintStrokes(canvas, size, strokes: strokes, activeStroke: activeStroke);
  }

  @override
  bool shouldRepaint(covariant _TransparentStrokePainter old) => true;
}
