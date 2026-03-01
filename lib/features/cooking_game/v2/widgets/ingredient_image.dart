import 'package:flutter/material.dart';

import '../models/v2_recipe.dart';

/// Renders an ingredient as a PNG image (from [V2Ingredient.assetPath])
/// or falls back to the emoji text when the asset is missing.
class IngredientImage extends StatelessWidget {
  const IngredientImage({
    super.key,
    required this.ingredient,
    this.size = 48,
  });

  final V2Ingredient ingredient;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = ingredient.assetPath;
    if (path == null) {
      return _EmojiText(emoji: ingredient.emoji, size: size);
    }
    return Image.asset(
      path,
      width: size,
      height: size,
      cacheWidth: (size * 2).toInt(),
      errorBuilder: (_, _, _) =>
          _EmojiText(emoji: ingredient.emoji, size: size),
    );
  }
}

class _EmojiText extends StatelessWidget {
  const _EmojiText({required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.7)),
      ),
    );
  }
}
