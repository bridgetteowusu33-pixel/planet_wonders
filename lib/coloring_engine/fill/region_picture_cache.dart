import 'dart:collection';
import 'dart:ui' as ui;

import '../../features/coloring/painters/region_mask.dart';

typedef RegionColorKey = (int, int); // (regionId, argb32)

/// Caches pre-recorded pictures for region fills.
///
/// Rendering region fills from cached pictures avoids scanning the full mask
/// every frame and significantly reduces jank on large pages.
class RegionPictureCache {
  RegionPictureCache({this.maxEntries = 256});

  final int maxEntries;
  final LinkedHashMap<RegionColorKey, ui.Picture> _cache =
      LinkedHashMap<RegionColorKey, ui.Picture>();

  void clear() {
    for (final picture in _cache.values) {
      picture.dispose();
    }
    _cache.clear();
  }

  void dispose() => clear();

  ui.Picture getOrCreate({
    required RegionMask mask,
    required int regionId,
    required ui.Color color,
  }) {
    final key = (regionId, color.toARGB32());
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return cached;
    }

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.fill;

    // Scanline runs at 1:1 mask resolution.
    for (int y = 0; y < mask.height; y++) {
      int? runStart;
      for (int x = 0; x <= mask.width; x++) {
        final isMatch =
            (x < mask.width) && (mask.pixels[y * mask.width + x] == regionId);
        if (isMatch) {
          runStart ??= x;
        } else if (runStart != null) {
          canvas.drawRect(
            ui.Rect.fromLTRB(
              runStart.toDouble(),
              y.toDouble(),
              x.toDouble(),
              (y + 1).toDouble(),
            ),
            paint,
          );
          runStart = null;
        }
      }
    }

    final picture = recorder.endRecording();
    _cache[key] = picture;
    _evictIfNeeded();
    return picture;
  }

  void _evictIfNeeded() {
    while (_cache.length > maxEntries) {
      final oldestKey = _cache.keys.first;
      final picture = _cache.remove(oldestKey);
      picture?.dispose();
    }
  }
}

void paintRegionFillsFromCache(
  ui.Canvas canvas, {
  required ui.Rect destinationRect,
  required RegionMask mask,
  required Map<int, ui.Color> regionFills,
  required RegionPictureCache cache,
}) {
  if (regionFills.isEmpty ||
      destinationRect.width <= 0 ||
      destinationRect.height <= 0) {
    return;
  }

  canvas.save();
  canvas.translate(destinationRect.left, destinationRect.top);
  canvas.scale(
    destinationRect.width / mask.width,
    destinationRect.height / mask.height,
  );

  for (final entry in regionFills.entries) {
    final picture = cache.getOrCreate(
      mask: mask,
      regionId: entry.key,
      color: entry.value,
    );
    canvas.drawPicture(picture);
  }

  canvas.restore();
}
