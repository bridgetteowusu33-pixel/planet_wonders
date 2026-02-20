import 'dart:ui';

class JigsawPieceModel {
  const JigsawPieceModel({
    required this.id,
    required this.row,
    required this.col,
    required this.correctRect,
    required this.currentOffset,
    required this.isPlaced,
  });

  final String id;
  final int row;
  final int col;
  final Rect correctRect;
  final Offset currentOffset;
  final bool isPlaced;

  Offset get center => correctRect.center;

  JigsawPieceModel copyWith({
    Rect? correctRect,
    Offset? currentOffset,
    bool? isPlaced,
  }) {
    return JigsawPieceModel(
      id: id,
      row: row,
      col: col,
      correctRect: correctRect ?? this.correctRect,
      currentOffset: currentOffset ?? this.currentOffset,
      isPlaced: isPlaced ?? this.isPlaced,
    );
  }
}

class JigsawLayout {
  const JigsawLayout({
    required this.boardSize,
    required this.pieceSize,
    required this.snapThreshold,
  });

  final Size boardSize;
  final Size pieceSize;
  final double snapThreshold;
}
