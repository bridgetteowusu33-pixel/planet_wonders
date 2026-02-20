import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/puzzle_models.dart';
import '../../domain/puzzle_engine/jigsaw_engine.dart';
import '../../domain/puzzle_engine/jigsaw_models.dart';

class PuzzleBoard extends StatefulWidget {
  const PuzzleBoard({
    super.key,
    required this.puzzle,
    required this.engine,
    required this.showHint,
    required this.onPieceDropped,
  });

  final PuzzleItem puzzle;
  final JigsawEngine engine;
  final bool showHint;
  final void Function(String pieceId, Offset localDropPosition) onPieceDropped;

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  final GlobalKey _boardKey = GlobalKey();
  Size _lastConfiguredSize = Size.zero;

  void _ensureBoardConfigured(Size boardSize) {
    if (boardSize == _lastConfiguredSize) return;
    _lastConfiguredSize = boardSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.engine.configureBoard(boardSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortest = math.min(constraints.maxWidth, constraints.maxHeight);
        final boardSide = shortest.clamp(220.0, 640.0);
        const padding = 10.0;
        final innerSide = boardSide - padding * 2;
        final innerSize = Size(innerSide, innerSide);
        _ensureBoardConfigured(innerSize);

        return RepaintBoundary(
          child: Center(
            child: SizedBox(
              width: boardSide,
              height: boardSide,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE9F3FF), Color(0xFFDDEBFF)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1E000000),
                            blurRadius: 14,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _PuzzleGridPainter(
                                  rows: widget.puzzle.rows,
                                  cols: widget.puzzle.cols,
                                ),
                              ),
                            ),
                            if (widget.showHint)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Opacity(
                                    opacity: 0.28,
                                    child: Image.asset(
                                      widget.puzzle.imagePath,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.low,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const ColoredBox(
                                          color: Color(0xFFD1E4FF),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ...widget.engine.placedPieces.map(
                              (piece) => _PlacedPiece(
                                piece: piece,
                                boardSize: innerSize,
                                rows: widget.puzzle.rows,
                                cols: widget.puzzle.cols,
                                imagePath: widget.puzzle.imagePath,
                              ),
                            ),
                            Positioned.fill(
                              child: DragTarget<String>(
                                onWillAcceptWithDetails: (_) => true,
                                onAcceptWithDetails: (details) {
                                  final render = _boardKey.currentContext
                                      ?.findRenderObject();
                                  if (render is! RenderBox) return;
                                  final local =
                                      render.globalToLocal(details.offset);

                                  // Snap to nearest cell center so the
                                  // coordinate matches piece.center exactly.
                                  final cellW =
                                      innerSize.width / widget.puzzle.cols;
                                  final cellH =
                                      innerSize.height / widget.puzzle.rows;
                                  final col = (local.dx / cellW)
                                      .floor()
                                      .clamp(0, widget.puzzle.cols - 1);
                                  final row = (local.dy / cellH)
                                      .floor()
                                      .clamp(0, widget.puzzle.rows - 1);
                                  final cellCenter = Offset(
                                    (col + 0.5) * cellW,
                                    (row + 0.5) * cellH,
                                  );

                                  widget.onPieceDropped(
                                      details.data, cellCenter);
                                },
                                builder: (context, _, _) {
                                  return Container(key: _boardKey);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlacedPiece extends StatelessWidget {
  const _PlacedPiece({
    required this.piece,
    required this.boardSize,
    required this.rows,
    required this.cols,
    required this.imagePath,
  });

  final JigsawPieceModel piece;
  final Size boardSize;
  final int rows;
  final int cols;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final pieceWidth = boardSize.width / cols;
    final pieceHeight = boardSize.height / rows;

    return Positioned(
      left: piece.correctRect.left,
      top: piece.correctRect.top,
      width: piece.correctRect.width,
      height: piece.correctRect.height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: -piece.col * pieceWidth,
            top: -piece.row * pieceHeight,
            width: boardSize.width,
            height: boardSize.height,
            child: Image.asset(
              imagePath,
              width: boardSize.width,
              height: boardSize.height,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              errorBuilder: (context, error, stackTrace) => Container(
                width: boardSize.width,
                height: boardSize.height,
                color: const Color(0xFFBFD7FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PuzzleGridPainter extends CustomPainter {
  const _PuzzleGridPainter({required this.rows, required this.cols});

  final int rows;
  final int cols;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF9AB6EA);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFC7D8F6);

    final rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    canvas.drawRRect(rRect, outline);

    for (var r = 1; r < rows; r++) {
      final y = size.height * (r / rows);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    for (var c = 1; c < cols; c++) {
      final x = size.width * (c / cols);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
  }

  @override
  bool shouldRepaint(covariant _PuzzleGridPainter oldDelegate) {
    return oldDelegate.rows != rows || oldDelegate.cols != cols;
  }
}
