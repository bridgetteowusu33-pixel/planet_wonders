import 'package:flutter/material.dart';

import '../models/rush_ingredient.dart';

/// A tappable floating ingredient card.
///
/// Shows the ingredient's PNG image with emoji fallback.
/// Minimum touch target is 56x56 for kid-friendliness.
class FloatingIngredientWidget extends StatelessWidget {
  const FloatingIngredientWidget({
    super.key,
    required this.ingredient,
    required this.onTap,
  });

  final RushIngredient ingredient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final path = ingredient.assetPath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(
        path,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _emojiLabel(),
      );
    }
    return _emojiLabel();
  }

  Widget _emojiLabel() {
    return Text(
      ingredient.emoji,
      style: const TextStyle(fontSize: 32),
    );
  }
}
