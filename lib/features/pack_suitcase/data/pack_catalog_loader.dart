import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/suitcase_pack.dart';

/// Loads and caches [SuitcasePack] data from the JSON catalog asset.
class PackCatalogLoader {
  PackCatalogLoader._();

  static const _catalogPath = 'assets/games/pack_suitcase/catalog.json';

  static List<SuitcasePack>? _cache;

  /// Load all packs from the catalog (cached after first call).
  static Future<List<SuitcasePack>> loadAll() async {
    if (_cache != null) return _cache!;

    try {
      final raw = await rootBundle.loadString(_catalogPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final packs = decoded['packs'] as List? ?? [];

      _cache = packs
          .whereType<Map<String, dynamic>>()
          .map(SuitcasePack.fromJson)
          .toList(growable: false);
    } catch (e) {
      // Fail gracefully — return empty list so the screen can show a fallback.
      _cache = const [];
    }

    return _cache!;
  }

  /// Return only packs for [countryId].
  static Future<List<SuitcasePack>> packsForCountry(String countryId) async {
    final all = await loadAll();
    return all
        .where((p) => p.countryId == countryId)
        .toList(growable: false);
  }

  /// Find a single pack by [packId], or null.
  static Future<SuitcasePack?> findPack(String packId) async {
    final all = await loadAll();
    for (final p in all) {
      if (p.packId == packId) return p;
    }
    return null;
  }
}
