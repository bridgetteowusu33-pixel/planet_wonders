// File: lib/features/creative_studio/sticker_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/pw_theme.dart';
import '../stickers/providers/sticker_provider.dart';
import 'creative_controller.dart';
import 'creative_state.dart';
import 'widgets/sticker_card.dart';

class StickerPanel extends ConsumerWidget {
  const StickerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(creativeControllerProvider.notifier);
    final stickerState = ref.watch(stickerProvider);

    final generalStickers = stickerState.stickersForCountry('general');
    final collected = generalStickers
        .where((s) => stickerState.isCollected(s.id))
        .toList();
    final lockedCount = generalStickers.length - collected.length;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFD9E3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('My Stickers', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Tap a sticker to place it on the canvas, then drag/resize it.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF708499),
              ),
            ),
            const SizedBox(height: 10),
            if (collected.isEmpty)
              _EmptyState()
            else
              SizedBox(
                height: 280,
                child: GridView.builder(
                  itemCount: collected.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.92,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final sticker = collected[index];
                    final item = StickerItem(
                      id: sticker.id,
                      label: sticker.label,
                      emoji: sticker.emoji,
                      assetPath: sticker.assetPath,
                    );
                    return StickerCard(
                      sticker: item,
                      onTap: () {
                        controller.addSticker(
                          item,
                          position: const Offset(220, 220),
                        );
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            if (lockedCount > 0) ...[
              const SizedBox(height: 12),
              _EarnMoreBanner(lockedCount: lockedCount),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: PWColors.navy.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('\u{1F31F}', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text(
            'No stickers yet!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: PWColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete stories, cook recipes, and play games\nto earn stickers you can use here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PWColors.navy.withValues(alpha: 0.5),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnMoreBanner extends StatelessWidget {
  const _EarnMoreBanner({required this.lockedCount});

  final int lockedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: PWColors.yellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PWColors.yellow.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Text('\u{1F513}', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$lockedCount more sticker${lockedCount == 1 ? '' : 's'} to earn! '
              'Complete activities to unlock them.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: PWColors.navy.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
