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
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImage(),
              const SizedBox(height: 4),
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

  Widget _buildImage() {
    final path = sticker.assetPath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(
        path,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(
          sticker.emoji,
          style: const TextStyle(fontSize: 32),
        ),
      );
    }
    return Text(sticker.emoji, style: const TextStyle(fontSize: 32));
  }
}
