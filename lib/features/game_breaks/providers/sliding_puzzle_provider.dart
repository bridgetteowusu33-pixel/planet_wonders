import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sliding_puzzle_registry.dart';
import '../models/puzzle_state.dart';

final slidingPuzzleProvider =
    NotifierProvider.autoDispose<SlidingPuzzleNotifier, SlidingPuzzleState>(
  SlidingPuzzleNotifier.new,
);

class SlidingPuzzleNotifier extends Notifier<SlidingPuzzleState> {
  Timer? _timer;

  @override
  SlidingPuzzleState build() {
    ref.onDispose(() => _timer?.cancel());
    return const SlidingPuzzleState();
  }

  /// Initialize with a country's puzzle image. Call once on screen mount.
  void setup(String countryId, {String? imageId}) {
    final data = findSlidingPuzzleData(countryId) ?? fallbackSlidingPuzzle;
    final rng = Random();
    final entry = (imageId != null)
        ? data.puzzleImages.firstWhere(
            (e) => e.id == imageId,
            orElse: () => data.puzzleImages.first,
          )
        : data.puzzleImages[rng.nextInt(data.puzzleImages.length)];

    // Start from solved state, then shuffle via valid moves.
    final tiles = List.generate(
      9,
      (i) => PuzzleTile(correctIndex: i, currentIndex: i),
    );

    state = SlidingPuzzleState(
      tiles: tiles,
      painter: entry.painter,
      imagePath: entry.imagePath,
      imageLabel: entry.label,
      historyFact: entry.historyFact,
    );

    _shuffleByMoves(80 + rng.nextInt(40));
    _startTimer();
  }

  /// Shuffle by performing [count] random valid moves from the current state.
  /// This guarantees the resulting configuration is always solvable.
  void _shuffleByMoves(int count) {
    final rng = Random();
    var emptyIdx = state.emptyIndex;
    int? lastEmpty;

    var tiles = [...state.tiles];

    for (var i = 0; i < count; i++) {
      final neighbors = _adjacentIndices(emptyIdx);
      // Avoid immediately undoing the previous move.
      if (lastEmpty != null) neighbors.remove(lastEmpty);
      if (neighbors.isEmpty) continue;

      final pick = neighbors[rng.nextInt(neighbors.length)];

      // Swap the picked tile with the empty tile.
      tiles = _swapTiles(tiles, emptyIdx, pick);
      lastEmpty = emptyIdx;
      emptyIdx = pick;
    }

    state = state.copyWith(tiles: tiles, moveCount: 0, elapsedSeconds: 0);
  }

  /// Tap a tile at [tappedGridIndex]. Slides it if adjacent to the empty slot.
  void tapTile(int tappedGridIndex) {
    if (state.completed) return;

    final emptyIdx = state.emptyIndex;
    if (!_adjacentIndices(emptyIdx).contains(tappedGridIndex)) return;

    final newTiles = _swapTiles([...state.tiles], emptyIdx, tappedGridIndex);
    final newMoveCount = state.moveCount + 1;
    final allCorrect = newTiles.every((t) => t.isInCorrectPosition);

    state = state.copyWith(
      tiles: newTiles,
      moveCount: newMoveCount,
      completed: allCorrect,
    );

    if (allCorrect) _timer?.cancel();
  }

  /// Reset with the same image.
  void reset() {
    _timer?.cancel();
    if (state.painter == null && state.imagePath == null) return;

    final tiles = List.generate(
      9,
      (i) => PuzzleTile(correctIndex: i, currentIndex: i),
    );

    state = SlidingPuzzleState(
      tiles: tiles,
      painter: state.painter,
      imagePath: state.imagePath,
      imageLabel: state.imageLabel,
      historyFact: state.historyFact,
    );

    _shuffleByMoves(80 + Random().nextInt(40));
    _startTimer();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.completed) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  /// Returns grid indices adjacent to [index] in a 3×3 grid.
  static List<int> _adjacentIndices(int index) {
    final row = index ~/ 3;
    final col = index % 3;
    final result = <int>[];
    if (row > 0) result.add(index - 3); // up
    if (row < 2) result.add(index + 3); // down
    if (col > 0) result.add(index - 1); // left
    if (col < 2) result.add(index + 1); // right
    return result;
  }

  /// Swap the tiles at two grid positions, returning a new list.
  static List<PuzzleTile> _swapTiles(
    List<PuzzleTile> tiles,
    int indexA,
    int indexB,
  ) {
    final a = tiles.indexWhere((t) => t.currentIndex == indexA);
    final b = tiles.indexWhere((t) => t.currentIndex == indexB);
    tiles[a] = PuzzleTile(
      correctIndex: tiles[a].correctIndex,
      currentIndex: indexB,
    );
    tiles[b] = PuzzleTile(
      correctIndex: tiles[b].correctIndex,
      currentIndex: indexA,
    );
    return tiles;
  }
}
