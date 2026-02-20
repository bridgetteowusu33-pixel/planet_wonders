import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../data/puzzle_models.dart';
import 'jigsaw_models.dart';
import 'piece_generator.dart';
import 'snapping.dart';

class JigsawEngine extends ChangeNotifier {
  JigsawEngine({required this.puzzle, required int seed}) : _seed = seed;

  final PuzzleItem puzzle;

  late Size _boardSize = Size.zero;
  JigsawLayout? _layout;

  int _seed;
  int _moves = 0;
  int _hintsUsed = 0;
  bool _completed = false;

  static const int maxHints = 5;

  final Map<String, JigsawPieceModel> _piecesById =
      <String, JigsawPieceModel>{};
  List<String> _trayOrder = const [];

  Size get boardSize => _boardSize;
  JigsawLayout? get layout => _layout;
  int get seed => _seed;
  int get moves => _moves;
  int get hintsUsed => _hintsUsed;
  bool get hintUsed => _hintsUsed >= maxHints;
  bool get completed => _completed;

  double get progress {
    if (_piecesById.isEmpty) return 0;
    return _placedPieceIds.length / _piecesById.length;
  }

  Set<String> get _placedPieceIds => _piecesById.entries
      .where((entry) => entry.value.isPlaced)
      .map((entry) => entry.key)
      .toSet();

  Set<String> get placedPieceIds => _placedPieceIds;

  List<JigsawPieceModel> get placedPieces =>
      _piecesById.values
          .where((piece) => piece.isPlaced)
          .toList(growable: false)
        ..sort((a, b) {
          if (a.row != b.row) return a.row.compareTo(b.row);
          return a.col.compareTo(b.col);
        });

  List<JigsawPieceModel> get remainingPieces {
    if (_trayOrder.isEmpty) return const [];
    return _trayOrder
        .map((id) => _piecesById[id])
        .whereType<JigsawPieceModel>()
        .where((piece) => !piece.isPlaced)
        .toList(growable: false);
  }

  void configureBoard(Size boardSize) {
    if (boardSize.width <= 0 || boardSize.height <= 0) return;

    final changed = _boardSize != boardSize || _piecesById.isEmpty;
    _boardSize = boardSize;
    if (!changed) return;

    final generated = generateJigsawPieces(
      puzzle: puzzle,
      boardSize: _boardSize,
    );
    _piecesById
      ..clear()
      ..addEntries(generated.map((piece) => MapEntry(piece.id, piece)));

    _trayOrder = shuffledPieceOrder(
      _piecesById.keys.toList(growable: false),
      seed: _seed,
    );

    _layout = JigsawLayout(
      boardSize: _boardSize,
      pieceSize: Size(
        _boardSize.width / puzzle.cols,
        _boardSize.height / puzzle.rows,
      ),
      snapThreshold: computeSnapThreshold(_boardSize),
    );

    _completed = false;
    _moves = 0;
    _hintsUsed = 0;
    notifyListeners();
  }

  void restoreProgress({
    required Set<String> placedPieceIds,
    required int moves,
    required int hintsUsed,
  }) {
    if (_piecesById.isEmpty) return;

    _moves = max(0, moves);
    _hintsUsed = hintsUsed.clamp(0, maxHints);
    _completed = false;

    final restored = <String, JigsawPieceModel>{};
    for (final entry in _piecesById.entries) {
      final piece = entry.value;
      final placed = placedPieceIds.contains(entry.key);
      restored[entry.key] = piece.copyWith(
        isPlaced: placed,
        currentOffset: placed ? piece.correctRect.topLeft : piece.currentOffset,
      );
    }

    _piecesById
      ..clear()
      ..addAll(restored);

    _completed = _piecesById.values.every((piece) => piece.isPlaced);
    notifyListeners();
  }

  void useHint() {
    if (_hintsUsed >= maxHints) return;
    _hintsUsed += 1;
    notifyListeners();
  }

  bool tryDropPiece({required String pieceId, required Offset dropPosition}) {
    final piece = _piecesById[pieceId];
    final localLayout = _layout;
    if (piece == null || localLayout == null || piece.isPlaced) {
      return false;
    }

    _moves += 1;

    final shouldSnap = shouldSnapToTarget(
      dropPosition: dropPosition,
      targetCenter: piece.center,
      threshold: localLayout.snapThreshold,
    );

    if (!shouldSnap) {
      notifyListeners();
      return false;
    }

    _piecesById[pieceId] = piece.copyWith(
      isPlaced: true,
      currentOffset: piece.correctRect.topLeft,
    );

    _completed = _piecesById.values.every((value) => value.isPlaced);
    notifyListeners();
    return true;
  }

  void reset({int? seed}) {
    if (_boardSize == Size.zero) return;
    _seed = seed ?? DateTime.now().microsecondsSinceEpoch;
    final currentSize = _boardSize;
    _boardSize = Size.zero;
    configureBoard(currentSize);
  }
}
