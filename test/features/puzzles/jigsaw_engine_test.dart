import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:planet_wonders/features/puzzles/data/puzzle_models.dart';
import 'package:planet_wonders/features/puzzles/domain/puzzle_engine/jigsaw_engine.dart';

void main() {
  const puzzle = PuzzleItem(
    id: 'ghana_01_beach',
    packId: 'ghana_pack',
    title: 'Beach Day',
    imagePath: 'assets/puzzles/ghana/full/ghana_01_beach.jpg',
    thumbnailPath: 'assets/puzzles/ghana/thumbs/ghana_01_beach.png',
    rows: 2,
    cols: 2,
    difficulty: PuzzleDifficulty.easy,
    targetTimeSec: 90,
    unlockedByDefault: true,
  );

  test('snap threshold scales with board size', () {
    final engine = JigsawEngine(puzzle: puzzle, seed: 7);
    engine.configureBoard(const Size(240, 240));
    final smallThreshold = engine.layout!.snapThreshold;

    engine.configureBoard(const Size(520, 520));
    final bigThreshold = engine.layout!.snapThreshold;

    expect(bigThreshold, greaterThanOrEqualTo(smallThreshold));
  });

  test('piece snaps when dropped near target and marks completion', () {
    final engine = JigsawEngine(puzzle: puzzle, seed: 7);
    engine.configureBoard(const Size(320, 320));

    expect(engine.completed, isFalse);

    final dropTooFar = engine.tryDropPiece(
      pieceId: 'r0_c0',
      dropPosition: const Offset(300, 300),
    );
    expect(dropTooFar, isFalse);

    final firstSnap = engine.tryDropPiece(
      pieceId: 'r0_c0',
      dropPosition: const Offset(80, 80),
    );
    expect(firstSnap, isTrue);

    final second = engine.tryDropPiece(
      pieceId: 'r0_c1',
      dropPosition: const Offset(240, 80),
    );
    final third = engine.tryDropPiece(
      pieceId: 'r1_c0',
      dropPosition: const Offset(80, 240),
    );
    final fourth = engine.tryDropPiece(
      pieceId: 'r1_c1',
      dropPosition: const Offset(240, 240),
    );

    expect(second, isTrue);
    expect(third, isTrue);
    expect(fourth, isTrue);
    expect(engine.completed, isTrue);
    expect(engine.placedPieceIds.length, 4);
  });
}
