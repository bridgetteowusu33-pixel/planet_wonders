import 'package:flutter/material.dart';

import 'region_mask.dart';

/// Paints filled regions onto the canvas using scanline rendering.
///
/// For each (regionId, color) pair in `regionFills`, this function finds all
/// pixels in the mask with that region ID and renders them as filled rectangles.
///
/// Uses scanline algorithm: iterate rows, find horizontal runs of matching
/// region ID, draw them as rectangles. This is fast enough for 1024×1024 masks
/// with <40 regions.
///
/// The mask coordinates are scaled to fit `canvasSize`.
void paintRegionFills(
  Canvas canvas,
  Size canvasSize, {
  required RegionMask mask,
  required Map<int, Color> regionFills,
  Rect? destinationRect,
}) {
  if (regionFills.isEmpty) return;
  final targetRect =
      destinationRect ?? Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height);
  if (targetRect.width <= 0 || targetRect.height <= 0) return;

  // Scale factors from mask pixel coords to canvas coords
  final scaleX = targetRect.width / mask.width;
  final scaleY = targetRect.height / mask.height;

  // For each filled region, render its pixels
  for (final entry in regionFills.entries) {
    final regionId = entry.key;
    final color = entry.value;

    _paintRegionScanline(
      canvas,
      mask,
      regionId,
      color,
      scaleX,
      scaleY,
      targetRect.left,
      targetRect.top,
    );
  }
}

/// Renders a single region using scanline algorithm.
///
/// Iterates through mask rows, finds horizontal runs of pixels with matching
/// regionId, and draws them as rectangles on the canvas.
void _paintRegionScanline(
  Canvas canvas,
  RegionMask mask,
  int regionId,
  Color color,
  double scaleX,
  double scaleY,
  double offsetX,
  double offsetY,
) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  // Scanline rendering: iterate each row, find horizontal runs
  for (int y = 0; y < mask.height; y++) {
    int? runStart;

    for (int x = 0; x <= mask.width; x++) {
      final isMatch = (x < mask.width) && (mask.pixels[y * mask.width + x] == regionId);

      if (isMatch) {
        // Start or continue a run
        runStart ??= x;
      } else if (runStart != null) {
        // End of run — draw rectangle from runStart to x-1
        final rect = Rect.fromLTRB(
          offsetX + (runStart * scaleX),
          offsetY + (y * scaleY),
          offsetX + (x * scaleX),
          offsetY + ((y + 1) * scaleY),
        );
        canvas.drawRect(rect, paint);
        runStart = null;
      }
    }
  }
}

/// Alternative: Renders a single region using a cached ui.Image.
///
/// This approach pre-renders each (regionId, color) combination to a ui.Image
/// and draws it on the canvas. Faster for regions that are filled with the
/// same color repeatedly, but adds memory overhead and async complexity.
///
/// For Phase 1, we use the simpler scanline approach above. This cached
/// version can be added in Phase 4 for optimization if needed.
///
/// Example cache structure:
/// ```dart
/// class RegionFillCache {
///   final Map<(int, int), ui.Image> _cache = {}; // (regionId, colorValue) → image
///
///   Future<ui.Image> getOrCreate(RegionMask mask, int regionId, Color color, Size size) async {
///     final key = (regionId, color.value);
///     if (_cache.containsKey(key)) return _cache[key]!;
///
///     final recorder = ui.PictureRecorder();
///     final canvas = Canvas(recorder);
///     _paintRegionScanline(canvas, mask, regionId, color, ...);
///     final picture = recorder.endRecording();
///     final image = await picture.toImage(size.width.ceil(), size.height.ceil());
///     picture.dispose();
///     _cache[key] = image;
///     return image;
///   }
///
///   void dispose() {
///     for (final img in _cache.values) img.dispose();
///     _cache.clear();
///   }
/// }
/// ```
