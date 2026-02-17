import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../coloring_engine/core/texture_cache.dart';
import '../../../coloring_engine/fill/region_picture_cache.dart';
import '../../../coloring_engine/ui/zoom_controller.dart';
import '../models/coloring_page.dart';
import '../models/drawing_state.dart';
import '../painters/region_mask.dart';
import '../painters/stroke_painter.dart';
import '../providers/drawing_provider.dart';

/// A canvas that layers:
///   1. White background
///   2. Faint line-art guide (15% opacity outline — visible under coloring)
///   3. Region fills (from mask-based fill system)
///   4. Kid's brush strokes
///   5. Bold outline on top (always visible, like a real coloring book)
class ColoringCanvas extends ConsumerStatefulWidget {
  const ColoringCanvas({
    super.key,
    required this.canvasKey,
    required this.paintOutline,
    this.regionMask, // NEW: region mask for fill tool
  });

  final GlobalKey canvasKey;
  final OutlinePainter paintOutline;
  final RegionMask? regionMask; // null for pages without mask support

  @override
  ConsumerState<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends ConsumerState<ColoringCanvas> {
  final _zoomController = ZoomController(maxScale: 4.0);
  final _regionPictureCache = RegionPictureCache();
  int _activePointers = 0;
  bool _isTransformGesture = false;

  @override
  void initState() {
    super.initState();
    ColoringTextureCache.instance.ensureLoaded();
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _regionPictureCache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interactionState = ref.watch(
      drawingProvider.select(
        (s) => (
          s.currentTool == DrawingTool.fill,
          s.precisionMode,
          s.currentColor,
        ),
      ),
    );
    final paintState = ref.watch(
      drawingProvider.select(
        (s) => (s.actions, s.activeStroke, s.paperTextureEnabled, s.filling),
      ),
    );
    final isFillTool = interactionState.$1;
    final precisionMode = interactionState.$2;
    final currentColor = interactionState.$3;
    final actions = paintState.$1;
    final derived = _deriveActionData(actions);
    final strokes = derived.strokes;
    final activeStroke = paintState.$2;
    final regionFills = derived.regionFills;
    final fillImages = derived.fillImages;
    final paperTextureEnabled = paintState.$3;
    final filling = paintState.$4;
    final revision = Object.hash(
      identityHashCode(actions),
      activeStroke?.points.length ?? 0,
      regionFills.length,
      fillImages.length,
      paperTextureEnabled,
    );

    return Listener(
      onPointerDown: (_) => _activePointers++,
      onPointerUp: (_) {
        _activePointers = (_activePointers - 1).clamp(0, 10);
      },
      onPointerCancel: (_) {
        _activePointers = (_activePointers - 1).clamp(0, 10);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: isFillTool
            ? (d) {
                final targetScale = precisionMode ? 3.0 : 2.0;
                if (_zoomController.scale < targetScale) {
                  _zoomController.zoomToPoint(
                    d.localPosition,
                    targetScale: targetScale,
                  );
                }
                _handleFillTap(
                  _zoomController.toCanvas(d.localPosition),
                  selectedColor: currentColor,
                );
              }
            : null,
        onScaleStart: (d) {
          if (_activePointers >= 2) {
            _isTransformGesture = true;
            _zoomController.startGesture(d.localFocalPoint);
            ref.read(drawingProvider.notifier).endStroke();
            return;
          }

          if (!isFillTool) {
            ref
                .read(drawingProvider.notifier)
                .startStroke(_zoomController.toCanvas(d.localFocalPoint));
          }
        },
        onScaleUpdate: (d) {
          // Transition to transform mode if second pointer joins mid-gesture.
          if ((_activePointers >= 2 || d.scale != 1.0) &&
              !_isTransformGesture) {
            _isTransformGesture = true;
            _zoomController.startGesture(d.localFocalPoint);
            ref.read(drawingProvider.notifier).endStroke();
          }

          if (_isTransformGesture) {
            _zoomController.updateGesture(
              focalPoint: d.localFocalPoint,
              gestureScale: d.scale,
              focalDelta: d.focalPointDelta,
            );
            return;
          }

          if (!isFillTool) {
            ref
                .read(drawingProvider.notifier)
                .updateStroke(_zoomController.toCanvas(d.localFocalPoint));
          }
        },
        onScaleEnd: (_) {
          if (_isTransformGesture) {
            _isTransformGesture = false;
            return;
          }
          if (!isFillTool) {
            ref.read(drawingProvider.notifier).endStroke();
          }
        },
        child: RepaintBoundary(
          key: widget.canvasKey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AnimatedBuilder(
              animation: _zoomController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Transform(
                      alignment: Alignment.topLeft,
                      transform: _zoomController.matrix,
                      child: CustomPaint(
                        painter: _ColoringPainter(
                          strokes: strokes,
                          activeStroke: activeStroke,
                          regionFills: regionFills,
                          fillImages: fillImages,
                          regionMask: widget.regionMask,
                          paintOutline: widget.paintOutline,
                          regionPictureCache: _regionPictureCache,
                          paperTextureEnabled: paperTextureEnabled,
                          revision: revision,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    if (filling)
                      const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Handles fill tap using region mask lookup.
  ///
  /// Instant and deterministic: look up the tapped region ID and fill it.
  Future<void> _handleFillTap(
    Offset canvasPosition, {
    required Color selectedColor,
  }) async {
    final mask = widget.regionMask;
    if (mask == null) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final canvasSize = box.size;
    final maskPoint = _maskPixelFromCanvasPoint(
      canvasPosition,
      canvasSize,
      mask,
    );
    if (maskPoint == null) return;

    final regionId = mask.regionAt(maskPoint.$1, maskPoint.$2);
    if (regionId == 0) return;

    ref.read(drawingProvider.notifier).fillRegion(regionId, selectedColor);
  }

  _CanvasActionData _deriveActionData(List<DrawingAction> actions) {
    final strokes = <Stroke>[];
    final regionFills = <int, Color>{};
    final fillImages = <ui.Image>[];

    for (final action in actions) {
      if (action is StrokeAction) {
        strokes.add(action.stroke);
        continue;
      }
      if (action is RegionFillAction) {
        regionFills[action.regionId] = action.color;
        continue;
      }
      if (action is BitmapFillAction) {
        fillImages.add(action.image);
      }
    }

    return _CanvasActionData(
      strokes: strokes,
      regionFills: regionFills,
      fillImages: fillImages,
    );
  }
}

class _CanvasActionData {
  const _CanvasActionData({
    required this.strokes,
    required this.regionFills,
    required this.fillImages,
  });

  final List<Stroke> strokes;
  final Map<int, Color> regionFills;
  final List<ui.Image> fillImages;
}

Rect _fittedMaskRect(Size canvasSize, RegionMask mask) {
  final maskAspect = mask.width / mask.height;
  final canvasAspect = canvasSize.width / canvasSize.height;

  double destW;
  double destH;
  if (maskAspect > canvasAspect) {
    destW = canvasSize.width;
    destH = destW / maskAspect;
  } else {
    destH = canvasSize.height;
    destW = destH * maskAspect;
  }

  return Rect.fromCenter(
    center: Offset(canvasSize.width / 2, canvasSize.height / 2),
    width: destW,
    height: destH,
  );
}

(int, int)? _maskPixelFromCanvasPoint(
  Offset canvasPoint,
  Size canvasSize,
  RegionMask mask,
) {
  final fittedRect = _fittedMaskRect(canvasSize, mask);
  if (!fittedRect.contains(canvasPoint)) return null;

  final normalizedX = (canvasPoint.dx - fittedRect.left) / fittedRect.width;
  final normalizedY = (canvasPoint.dy - fittedRect.top) / fittedRect.height;

  final mx = (normalizedX * mask.width).floor().clamp(0, mask.width - 1);
  final my = (normalizedY * mask.height).floor().clamp(0, mask.height - 1);
  return (mx, my);
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
    required this.regionFills,
    required this.fillImages,
    this.regionMask,
    required this.paintOutline,
    required this.regionPictureCache,
    required this.paperTextureEnabled,
    required this.revision,
  });

  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final Map<int, Color> regionFills; // NEW: region fills instead of images
  final List<ui.Image> fillImages; // Fallback flood-fill overlays
  final RegionMask? regionMask; // NEW: mask for rendering fills
  final OutlinePainter paintOutline;
  final RegionPictureCache regionPictureCache;
  final bool paperTextureEnabled;
  final int revision;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    // 1. White background
    canvas.drawRect(bounds, Paint()..color = Colors.white);

    // 2. Faint line-art guide (15% opacity)
    canvas.saveLayer(bounds, Paint()..colorFilter = _guideFilter);
    paintOutline(canvas, size);
    canvas.restore();

    // 3. Region fills (rendered from mask + regionFills map)
    if (regionMask != null && regionFills.isNotEmpty) {
      final fittedRect = _fittedMaskRect(size, regionMask!);
      paintRegionFillsFromCache(
        canvas,
        destinationRect: fittedRect,
        mask: regionMask!,
        regionFills: regionFills,
        cache: regionPictureCache,
      );
    }

    // 3b. Bitmap fills from flood-fill fallback (for pages without masks).
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

    // Optional subtle paper texture.
    if (paperTextureEnabled) {
      final paperPaint = ColoringTextureCache.instance.buildPaperPaint(bounds);
      if (paperPaint != null) {
        canvas.drawRect(bounds, paperPaint);
      }
    }

    // 5. Bold outline on top — always visible
    paintOutline(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _ColoringPainter old) {
    return old.revision != revision;
  }
}
