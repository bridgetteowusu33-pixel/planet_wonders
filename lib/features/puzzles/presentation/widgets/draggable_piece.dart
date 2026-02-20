import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/puzzle_engine/jigsaw_models.dart';

class DraggablePiece extends StatefulWidget {
  const DraggablePiece({
    super.key,
    required this.piece,
    required this.puzzleImagePath,
    required this.boardSize,
    required this.rows,
    required this.cols,
    required this.size,
    this.onDragStarted,
    this.onDragEnd,
  });

  final JigsawPieceModel piece;
  final String puzzleImagePath;
  final Size boardSize;
  final int rows;
  final int cols;
  final double size;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  State<DraggablePiece> createState() => _DraggablePieceState();
}

class _DraggablePieceState extends State<DraggablePiece> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1, end: _dragging ? 1.08 : 1),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Draggable<String>(
          data: widget.piece.id,
          onDragStarted: () {
            HapticFeedback.selectionClick();
            setState(() => _dragging = true);
            widget.onDragStarted?.call();
          },
          onDragEnd: (_) {
            if (mounted) {
              setState(() => _dragging = false);
            }
            widget.onDragEnd?.call();
          },
          feedback: Material(
            color: Colors.transparent,
            child: _pieceShell(
              size: widget.size,
              child: _pieceImage(),
              borderColor: const Color(0xFFFFE49D),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.25,
            child: _pieceShell(
              size: widget.size,
              child: _pieceImage(),
              borderColor: const Color(0xFFE6D9B1),
            ),
          ),
          child: _pieceShell(
            size: widget.size,
            child: _pieceImage(),
            borderColor: const Color(0xFFF4F7FF),
          ),
        ),
      ),
    );
  }

  Widget _pieceShell({
    required double size,
    required Widget child,
    required Color borderColor,
  }) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(9), child: child),
    );
  }

  Widget _pieceImage() {
    final pieceWidth = widget.boardSize.width / widget.cols;
    final pieceHeight = widget.boardSize.height / widget.rows;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: pieceWidth,
          height: pieceHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: -widget.piece.col * pieceWidth,
                top: -widget.piece.row * pieceHeight,
                width: widget.boardSize.width,
                height: widget.boardSize.height,
                child: Image.asset(
                  widget.puzzleImagePath,
                  width: widget.boardSize.width,
                  height: widget.boardSize.height,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: widget.boardSize.width,
                    height: widget.boardSize.height,
                    color: const Color(0xFFE6F0FF),
                    alignment: Alignment.center,
                    child: const Text('🧩', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
