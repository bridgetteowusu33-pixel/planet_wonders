// File: lib/features/creative_studio/sticker_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'creative_controller.dart';
import 'creative_state.dart';
import 'widgets/sticker_card.dart';

class StickerPanel extends ConsumerWidget {
  const StickerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(creativeControllerProvider.notifier);

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
            Text('Stickers', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Tap a sticker to place it on the canvas, then drag/resize it.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF708499),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 280,
              child: GridView.builder(
                itemCount: kStickerItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.92,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final sticker = kStickerItems[index];
                  return StickerCard(
                    sticker: sticker,
                    onTap: () {
                      controller.addSticker(
                        sticker,
                        position: const Offset(220, 220),
                      );
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
