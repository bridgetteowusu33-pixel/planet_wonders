import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/sticker.dart';

/// Shows a collected sticker at large size with its fun fact.
Future<void> showStickerDetailSheet(
  BuildContext context, {
  required Sticker sticker,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _StickerDetailContent(sticker: sticker),
  );
}

class _StickerDetailContent extends StatelessWidget {
  const _StickerDetailContent({required this.sticker});

  final Sticker sticker;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PWColors.navy.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Large sticker image
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: PWColors.yellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: PWColors.yellow.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Image.asset(
                  sticker.assetPath,
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Text(
                    sticker.emoji,
                    style: const TextStyle(fontSize: 96),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Label
            Text(
              sticker.label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: PWColors.navy,
              ),
            ),
            const SizedBox(height: 8),

            // Fun fact
            if (sticker.funFact.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PWColors.mint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '\u{1F4A1} ${sticker.funFact}', // 💡
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PWColors.navy,
                    height: 1.4,
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
