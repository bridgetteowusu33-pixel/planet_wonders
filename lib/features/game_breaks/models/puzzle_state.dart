import '../painters/puzzle_painters.dart';

/// Represents one tile in the 3×3 sliding puzzle grid.
class PuzzleTile {
  const PuzzleTile({
    required this.correctIndex,
    required this.currentIndex,
  });

  /// Which piece of the image this tile shows (0-7), or 8 for the empty slot.
  final int correctIndex;

  /// Where this tile currently sits in the grid (0-8).
  final int currentIndex;

  bool get isInCorrectPosition => correctIndex == currentIndex;
  bool get isEmpty => correctIndex == 8;
}

/// Full state for one sliding puzzle session.
class SlidingPuzzleState {
  const SlidingPuzzleState({
    this.tiles = const [],
    this.gridSize = 3,
    this.moveCount = 0,
    this.completed = false,
    this.painter,
    this.imagePath,
    this.imageLabel,
    this.historyFact,
    this.elapsedSeconds = 0,
  });

  final List<PuzzleTile> tiles;
  final int gridSize;
  final int moveCount;
  final bool completed;
  final PuzzlePainter? painter;
  final String? imagePath;
  final String? imageLabel;
  final String? historyFact;
  final int elapsedSeconds;

  /// Grid index of the empty slot.
  int get emptyIndex {
    for (final t in tiles) {
      if (t.isEmpty) return t.currentIndex;
    }
    return 8;
  }

  /// Look up the tile currently at [gridIndex].
  PuzzleTile? tileAt(int gridIndex) {
    for (final t in tiles) {
      if (t.currentIndex == gridIndex) return t;
    }
    return null;
  }

  /// Whether this puzzle uses an asset image (vs a programmatic painter).
  bool get usesImage => imagePath != null;

  SlidingPuzzleState copyWith({
    List<PuzzleTile>? tiles,
    int? gridSize,
    int? moveCount,
    bool? completed,
    PuzzlePainter? painter,
    String? imagePath,
    String? imageLabel,
    String? historyFact,
    int? elapsedSeconds,
  }) {
    return SlidingPuzzleState(
      tiles: tiles ?? this.tiles,
      gridSize: gridSize ?? this.gridSize,
      moveCount: moveCount ?? this.moveCount,
      completed: completed ?? this.completed,
      painter: painter ?? this.painter,
      imagePath: imagePath ?? this.imagePath,
      imageLabel: imageLabel ?? this.imageLabel,
      historyFact: historyFact ?? this.historyFact,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
