import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../painters/puzzle_painters.dart';

/// Small thumbnail showing the complete puzzle image as a reference hint.
class PuzzleReferenceImage extends StatelessWidget {
  const PuzzleReferenceImage({
    super.key,
    this.painter,
    this.imagePath,
    this.size = 80,
  });

  final PuzzlePainter? painter;
  final String? imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (imagePath != null) {
      content = Image.asset(
        imagePath!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (painter != null) {
      content = CustomPaint(
        size: Size(size, size),
        painter: painter,
      );
    } else {
      content = SizedBox(width: size, height: size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PWColors.navy.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
