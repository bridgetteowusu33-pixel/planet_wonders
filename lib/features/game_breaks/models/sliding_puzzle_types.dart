import 'dart:ui';

import '../painters/puzzle_painters.dart';

/// Country-themed data for one sliding puzzle round.
class SlidingPuzzleData {
  const SlidingPuzzleData({
    required this.countryId,
    required this.title,
    required this.bgColor,
    required this.puzzleImages,
  });

  final String countryId;
  final String title;
  final Color bgColor;
  final List<PuzzleImageEntry> puzzleImages;
}

/// A single puzzle image available for a country.
///
/// Provide either [imagePath] (asset image) or [painter] (programmatic).
class PuzzleImageEntry {
  const PuzzleImageEntry({
    required this.id,
    required this.label,
    this.painter,
    this.imagePath,
    this.historyFact,
  }) : assert(painter != null || imagePath != null);

  final String id;
  final String label;
  final PuzzlePainter? painter;
  final String? imagePath;
  final String? historyFact;
}
