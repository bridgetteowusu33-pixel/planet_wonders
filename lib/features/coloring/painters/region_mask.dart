import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;

/// Loaded region mask for a coloring page.
///
/// Each pixel's value (0-255) is the region ID.
/// - Value `0` = outline/border (not fillable)
/// - Values `1-N` = distinct fillable regions
///
/// Provides O(1) region lookup by pixel coordinate.
class RegionMask {
  RegionMask({
    required this.width,
    required this.height,
    required this.pixels,
  });

  final int width;
  final int height;

  /// Single-channel grayscale pixel data.
  /// Length = width * height.
  /// Each byte is a region ID (0-255).
  final Uint8List pixels;

  /// Returns the region ID at the given pixel coordinate.
  /// Returns 0 if out of bounds or if the coordinate is on an outline/border.
  int regionAt(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return 0;
    return pixels[y * width + x];
  }

  /// Returns all unique non-zero region IDs in this mask.
  /// Cached after first computation.
  Set<int>? _allRegionsCache;

  Set<int> get allRegions {
    if (_allRegionsCache != null) return _allRegionsCache!;

    final regions = <int>{};
    for (final pixel in pixels) {
      if (pixel > 0) regions.add(pixel);
    }

    _allRegionsCache = regions;
    return regions;
  }

  /// Returns the bounding Rect (in pixel coords) for a given region ID.
  /// Cached after first computation.
  final Map<int, ui.Rect> _boundsCache = {};

  ui.Rect boundsForRegion(int regionId) {
    if (_boundsCache.containsKey(regionId)) {
      return _boundsCache[regionId]!;
    }

    // Find min/max x,y for all pixels with this region ID
    int minX = width, minY = height, maxX = 0, maxY = 0;
    bool found = false;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (pixels[y * width + x] == regionId) {
          found = true;
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    final rect = found
        ? ui.Rect.fromLTRB(
            minX.toDouble(),
            minY.toDouble(),
            (maxX + 1).toDouble(),
            (maxY + 1).toDouble(),
          )
        : ui.Rect.zero;

    _boundsCache[regionId] = rect;
    return rect;
  }
}

/// Loads a region mask from an asset path.
///
/// Decodes the PNG to raw grayscale bytes and returns a [RegionMask].
/// The PNG must be single-channel (grayscale) with pixel values = region IDs.
///
/// Example:
/// ```dart
/// final mask = await loadRegionMask('assets/coloring/usa/masks/usa_01_map_mask.png');
/// final regionId = mask.regionAt(512, 768);
/// ```
Future<RegionMask> loadRegionMask(String assetPath) async {
  // Load asset bytes
  final data = await rootBundle.load(assetPath);
  final buffer = data.buffer.asUint8List();

  // Decode PNG to ui.Image
  final codec = await ui.instantiateImageCodec(buffer);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final w = image.width;
  final h = image.height;

  // Extract raw pixel data as RGBA
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) {
    image.dispose();
    throw Exception('Failed to decode mask image: $assetPath');
  }

  // Extract R channel (grayscale PNG has R=G=B, so just take R)
  final rgba = byteData.buffer.asUint8List();
  final grayscale = Uint8List(w * h);

  for (int i = 0; i < w * h; i++) {
    grayscale[i] = rgba[i * 4]; // R channel = region ID
  }

  image.dispose();

  return RegionMask(width: w, height: h, pixels: grayscale);
}
