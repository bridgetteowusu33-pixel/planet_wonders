import 'dart:convert';

import 'package:flutter/services.dart';

import 'puzzle_models.dart';

typedef CatalogLoader = Future<String> Function(String path);

class PuzzleCatalog {
  PuzzleCatalog({CatalogLoader? loader})
      : _loader = loader ?? rootBundle.loadString;

  static const String catalogAssetPath = 'assets/puzzles/catalog.json';

  final CatalogLoader _loader;

  Future<List<PuzzlePack>> loadPacks() async {
    try {
      final raw = await _loader(catalogAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return _fallbackPacks;
      final packsRaw = decoded['packs'];
      if (packsRaw is! List) return _fallbackPacks;

      final packs = packsRaw
          .whereType<Map>()
          .map((e) => PuzzlePack.fromJson(e.cast<String, dynamic>()))
          .where((pack) => pack.id.isNotEmpty && pack.puzzles.isNotEmpty)
          .toList(growable: false);

      return packs.isEmpty ? _fallbackPacks : packs;
    } catch (_) {
      return _fallbackPacks;
    }
  }
}

final List<PuzzlePack> _fallbackPacks = [
  PuzzlePack.fromJson(const {
    'id': 'ghana_pack',
    'title': 'Ghana Pack',
    'countryCode': 'GH',
    'thumbnail': 'assets/puzzles/ghana/thumbs/ghana_cover.webp',
    'difficultyTiers': ['easy', 'medium', 'hard'],
    'puzzles': [
      {
        'id': 'ghana_01_beach',
        'title': 'Beach Day',
        'image': 'assets/puzzles/ghana/full/ghana_01_beach.webp',
        'thumbnail': 'assets/puzzles/ghana/thumbs/ghana_01_beach.webp',
        'rows': 3,
        'cols': 3,
        'difficulty': 'easy',
        'targetTimeSec': 90,
        'unlockedByDefault': true,
      },
      {
        'id': 'ghana_02_market',
        'title': 'Busy Market',
        'image': 'assets/puzzles/ghana/full/ghana_02_market.webp',
        'thumbnail': 'assets/puzzles/ghana/thumbs/ghana_02_market.webp',
        'rows': 4,
        'cols': 4,
        'difficulty': 'easy',
        'targetTimeSec': 120,
        'unlockedByDefault': false,
      },
      {
        'id': 'ghana_03_kente',
        'title': 'Kente Cloth',
        'image': 'assets/puzzles/ghana/full/ghana_03_kente.webp',
        'thumbnail': 'assets/puzzles/ghana/thumbs/ghana_03_kente.webp',
        'rows': 4,
        'cols': 5,
        'difficulty': 'medium',
        'targetTimeSec': 180,
        'unlockedByDefault': false,
      },
      {
        'id': 'ghana_04_festival',
        'title': 'Festival Time',
        'image': 'assets/puzzles/ghana/full/ghana_04_festival.webp',
        'thumbnail': 'assets/puzzles/ghana/thumbs/ghana_04_festival.webp',
        'rows': 5,
        'cols': 5,
        'difficulty': 'medium',
        'targetTimeSec': 210,
        'unlockedByDefault': false,
      },
      {
        'id': 'ghana_05_cocoa',
        'title': 'Cocoa Farm',
        'image': 'assets/puzzles/ghana/full/ghana_05_cocoa.webp',
        'thumbnail': 'assets/puzzles/ghana/thumbs/ghana_05_cocoa.webp',
        'rows': 6,
        'cols': 5,
        'difficulty': 'hard',
        'targetTimeSec': 300,
        'unlockedByDefault': false,
      },
      {
        'id': 'ghana_06_flag',
        'title': 'Ghana Flag',
        'image': 'assets/puzzles/ghana/full/ghana_06_flag.webp',
        'thumbnail': 'assets/puzzles/ghana/thumbs/ghana_06_flag.webp',
        'rows': 6,
        'cols': 6,
        'difficulty': 'hard',
        'targetTimeSec': 360,
        'unlockedByDefault': false,
      },
    ],
  }),
];
