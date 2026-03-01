import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/pack_item.dart';

/// A single item tile — draggable + tappable.
///
/// Shows the item's PNG asset (with emoji fallback). If already packed, renders
/// a green checkmark overlay and becomes non-draggable.
class PackItemCard extends StatelessWidget {
  const PackItemCard({
    super.key,
    required this.item,
    required this.isPacked,
    this.onTap,
    this.isTablet = false,
  });

  final PackItem item;
  final bool isPacked;
  final VoidCallback? onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final child = _buildCard();

    if (isPacked) return child;

    return Draggable<String>(
      data: item.id,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.12, child: child),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }

  Widget _buildCard() {
    final cardW = isTablet ? 110.0 : 88.0;
    final iconSize = isTablet ? 86.0 : 68.0;
    return RepaintBoundary(
      child: SizedBox(
        width: cardW,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: isPacked
                    ? PWColors.mint.withValues(alpha: 0.18)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPacked
                      ? PWColors.mint.withValues(alpha: 0.5)
                      : PWColors.navy.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: isPacked
                    ? null
                    : [
                        BoxShadow(
                          color: PWColors.navy.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildItemImage(),
                  if (isPacked)
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: PWColors.mint.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: PWColors.mint,
                        size: isTablet ? 38 : 30,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Name
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTablet ? 13 : 11,
                fontWeight: FontWeight.w600,
                color: isPacked
                    ? PWColors.navy.withValues(alpha: 0.45)
                    : PWColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    if (item.assetPath != null) {
      return Image.asset(
        item.assetPath!,
        width: isTablet ? 56 : 44,
        height: isTablet ? 56 : 44,
        errorBuilder: (_, _, _) => _emojiWidget(),
      );
    }
    return _emojiWidget();
  }

  Widget _emojiWidget() {
    return Text(
      item.emoji,
      style: TextStyle(fontSize: isTablet ? 44 : 34),
    );
  }
}
