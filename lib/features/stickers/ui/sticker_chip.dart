import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/sticker.dart';

/// Small inline sticker chip for the story complete screen and similar contexts.
///
/// Shows the sticker image (48×48, emoji fallback) + label. Collected stickers
/// are full-colour; locked stickers appear greyscale with a lock icon.
class StickerChip extends StatelessWidget {
  const StickerChip({
    super.key,
    required this.sticker,
    required this.isCollected,
  });

  final Sticker sticker;
  final bool isCollected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: isCollected
            ? Border.all(
                color: PWColors.yellow.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildImage(),
          const SizedBox(width: 6),
          Text(
            sticker.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isCollected
                  ? PWColors.navy
                  : PWColors.navy.withValues(alpha: 0.4),
            ),
          ),
          if (!isCollected) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.lock_rounded,
              size: 12,
              color: PWColors.navy.withValues(alpha: 0.3),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage() {
    Widget image = Image.asset(
      sticker.assetPath,
      width: 28,
      height: 28,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Text(
        sticker.emoji,
        style: const TextStyle(fontSize: 18),
      ),
    );

    if (!isCollected) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 0.35, 0,
        ]),
        child: image,
      );
    }

    return image;
  }
}
