// File: lib/features/creative_studio/widgets/sticker_card.dart
import 'package:flutter/material.dart';

import '../creative_state.dart';

class StickerCard extends StatelessWidget {
  const StickerCard({super.key, required this.sticker, required this.onTap});

  final StickerItem sticker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(sticker.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(
                sticker.label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
