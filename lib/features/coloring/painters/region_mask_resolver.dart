import 'dart:collection';

import '../models/coloring_page.dart';
import 'region_mask.dart';
import 'region_mask_generator.dart';

/// Shared resolver for region masks across all coloring pages.
///
/// Resolution order:
/// 1) Try loading precomputed mask asset (fastest, deterministic)
/// 2) Fallback to runtime mask generation from the page outline painter
///
/// Results are memoized per page key to avoid repeated heavy preprocessing.
class RegionMaskResolver {
  RegionMaskResolver._();

  static final RegionMaskResolver instance = RegionMaskResolver._();
  static const int _maxCacheEntries = 40;

  final LinkedHashMap<String, Future<RegionMask>> _cache =
      LinkedHashMap<String, Future<RegionMask>>();

  Future<RegionMask> resolve({
    required String pageKey,
    required OutlinePainter outlinePainter,
    String? maskAssetPath,
  }) {
    final cached = _cache.remove(pageKey);
    if (cached != null) {
      _cache[pageKey] = cached;
      return cached;
    }

    final future = (() async {
      if (maskAssetPath != null && maskAssetPath.isNotEmpty) {
        try {
          return await loadRegionMask(maskAssetPath);
        } catch (_) {
          // Fall back to runtime generation when an asset is missing/corrupt.
        }
      }

      return generateRegionMaskFromOutline(
        paintOutline: outlinePainter,
        width: 1024,
        height: 1024,
        lineThreshold: 210,
        dilateIterations: 1,
        minRegionSize: 48,
      );
    })();

    _cache[pageKey] = future;
    _evictIfNeeded();
    return future;
  }

  void evict(String pageKey) {
    _cache.remove(pageKey);
  }

  void clear() {
    _cache.clear();
  }

  void _evictIfNeeded() {
    while (_cache.length > _maxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
  }
}
