import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../painters/puzzle_painters.dart';

/// A single tile in the 3×3 sliding puzzle grid.
///
/// Shows a cropped region of a [PuzzlePainter] or asset image based on
/// [correctIndex]. Highlights with a green border when in the correct position.
class PuzzleTileWidget extends StatelessWidget {
  const PuzzleTileWidget({
    super.key,
    required this.correctIndex,
    required this.gridSize,
    required this.tileSize,
    required this.onTap,
    this.painter,
    this.imagePath,
    this.isCorrect = false,
  });

  final int correctIndex;
  final int gridSize;
  final PuzzlePainter? painter;
  final String? imagePath;
  final double tileSize;
  final VoidCallback onTap;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final row = correctIndex ~/ gridSize;
    final col = correctIndex % gridSize;

    // Alignment maps 0 → -1.0, 1 → 0.0, 2 → 1.0 for a 3×3 grid.
    final alignX = gridSize > 1 ? -1.0 + 2.0 * col / (gridSize - 1) : 0.0;
    final alignY = gridSize > 1 ? -1.0 + 2.0 * row / (gridSize - 1) : 0.0;

    final Widget content;
    if (imagePath != null) {
      // Use Stack+Positioned so the image renders at full grid size
      // and gets clipped to show only this tile's section.
      final gridSideLen = tileSize * gridSize;
      content = SizedBox(
        width: tileSize,
        height: tileSize,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -col * tileSize,
              top: -row * tileSize,
              width: gridSideLen,
              height: gridSideLen,
              child: Image.asset(imagePath!, fit: BoxFit.cover),
            ),
          ],
        ),
      );
    } else {
      content = ClipRect(
        child: Align(
          alignment: Alignment(alignX, alignY),
          widthFactor: 1.0 / gridSize,
          heightFactor: 1.0 / gridSize,
          child: CustomPaint(
            size: Size(tileSize * gridSize, tileSize * gridSize),
            painter: painter,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCorrect
                ? PWColors.mint
                : PWColors.navy.withValues(alpha: 0.15),
            width: isCorrect ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
