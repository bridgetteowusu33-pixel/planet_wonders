import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/sticker.dart';

/// A single sticker cell in the album grid.
///
/// Three visual states:
/// - **Collected**: full-colour image + label
/// - **New**: collected but unseen — yellow "NEW" badge
/// - **Locked**: greyscale silhouette + lock overlay
class StickerCell extends StatelessWidget {
  const StickerCell({
    super.key,
    required this.sticker,
    required this.isCollected,
    required this.isNew,
    this.onTap,
    this.isTablet = false,
  });

  final Sticker sticker;
  final bool isCollected;
  final bool isNew;
  final VoidCallback? onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final imageSize = isTablet ? 80.0 : 64.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: imageSize + 16,
                height: imageSize + 16,
                decoration: BoxDecoration(
                  color: isCollected
                      ? Colors.white
                      : PWColors.navy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCollected
                        ? PWColors.yellow.withValues(alpha: 0.5)
                        : PWColors.navy.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: isCollected
                      ? [
                          BoxShadow(
                            color: PWColors.yellow.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCollected
                      ? _buildStickerImage(imageSize)
                      : _buildLockedImage(imageSize),
                ),
              ),

              // "NEW" badge
              if (isNew)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: PWColors.coral,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

              // Lock icon for uncollected
              if (!isCollected)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: isTablet ? 16 : 14,
                      color: PWColors.navy.withValues(alpha: 0.35),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sticker.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              fontWeight: FontWeight.w600,
              color: isCollected
                  ? PWColors.navy
                  : PWColors.navy.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerImage(double size) {
    return Image.asset(
      sticker.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Text(
        sticker.emoji,
        style: TextStyle(fontSize: size * 0.65),
      ),
    );
  }

  Widget _buildLockedImage(double size) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0, //
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 0.35, 0,
      ]),
      child: Image.asset(
        sticker.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(
          sticker.emoji,
          style: TextStyle(
            fontSize: size * 0.65,
            color: PWColors.navy.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}
