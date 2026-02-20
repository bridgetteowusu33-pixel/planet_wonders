import 'dart:math';
import 'dart:ui';

import '../../data/puzzle_models.dart';
import 'jigsaw_models.dart';

List<JigsawPieceModel> generateJigsawPieces({
  required PuzzleItem puzzle,
  required Size boardSize,
}) {
  final pieceWidth = boardSize.width / puzzle.cols;
  final pieceHeight = boardSize.height / puzzle.rows;

  final pieces = <JigsawPieceModel>[];
  for (var row = 0; row < puzzle.rows; row++) {
    for (var col = 0; col < puzzle.cols; col++) {
      final id = 'r${row}_c$col';
      final rect = Rect.fromLTWH(
        col * pieceWidth,
        row * pieceHeight,
        pieceWidth,
        pieceHeight,
      );
      pieces.add(
        JigsawPieceModel(
          id: id,
          row: row,
          col: col,
          correctRect: rect,
          currentOffset: rect.topLeft,
          isPlaced: false,
        ),
      );
    }
  }

  return pieces;
}

List<String> shuffledPieceOrder(List<String> ids, {required int seed}) {
  final random = Random(seed);
  final copy = [...ids];
  copy.shuffle(random);
  return copy;
}
