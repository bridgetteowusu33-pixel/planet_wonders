import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/gallery_service.dart';
import '../../../core/theme/pw_theme.dart';
import '../../coloring/models/drawing_state.dart';
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

  // TODO: Fashion Studio fill tool needs migration to region mask system or separate drawing provider.
  // For now, fill tool is disabled in Fashion Studio.
  Future<void> _handleFillTap(Offset localPosition) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill tool temporarily unavailable in Fashion Studio'),
          duration: Duration(seconds: 2),
        ),
      );
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
      backgroundColor: Colors.transparent,
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
                                  child: CustomPaint(
                                    painter: _TransparentStrokePainter(
                                      strokes: drawingState.strokes,
                                      activeStroke: drawingState.activeStroke,
                                    ),
                                    child: const SizedBox.expand(),
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

// TODO: This painter needs migration to support region fills or a separate drawing state.
class _TransparentStrokePainter extends CustomPainter {
  _TransparentStrokePainter({
    required this.strokes,
    this.activeStroke,
  });

  final List<Stroke> strokes;
  final Stroke? activeStroke;

  @override
  void paint(Canvas canvas, Size size) {
    // Strokes — no white background so the outfit shows through.
    paintStrokes(canvas, size, strokes: strokes, activeStroke: activeStroke);
  }

  @override
  bool shouldRepaint(covariant _TransparentStrokePainter old) => true;
}
