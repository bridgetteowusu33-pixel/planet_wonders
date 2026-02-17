import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/recipe.dart';

class IngredientTray extends StatelessWidget {
  const IngredientTray({
    super.key,
    required this.ingredients,
  });

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PWColors.mint.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Great job! All ingredients are in the pot.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return SizedBox(
      height: 124,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        scrollDirection: Axis.horizontal,
        itemCount: ingredients.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];
          return Draggable<Ingredient>(
            data: ingredient,
            feedback: _IngredientTile(
              ingredient: ingredient,
              elevated: true,
            ),
            childWhenDragging: Opacity(
              opacity: 0.35,
              child: _IngredientTile(ingredient: ingredient),
            ),
            child: _IngredientTile(ingredient: ingredient),
          );
        },
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    required this.ingredient,
    this.elevated = false,
  });

  final Ingredient ingredient;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 112,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PWColors.navy.withValues(alpha: 0.12),
          ),
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: PWColors.navy.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ingredient.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              ingredient.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
