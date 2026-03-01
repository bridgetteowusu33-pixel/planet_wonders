import 'package:flutter/material.dart';

import '../models/v2_recipe.dart';
import 'ingredient_image.dart';

/// A horizontal scrollable toolbar showing ingredient icons.
/// Interactive during addIngredients step (tap to add), passive otherwise.
class IngredientToolbar extends StatelessWidget {
  const IngredientToolbar({
    super.key,
    required this.ingredients,
    this.addedIds = const <String>{},
    this.interactive = false,
    this.onIngredientTap,
  });

  final List<V2Ingredient> ingredients;
  final Set<String> addedIds;
  final bool interactive;
  final void Function(String ingredientId)? onIngredientTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFF9E6), Color(0xFFFFF3C4)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ingredients.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];
          final isAdded = addedIds.contains(ingredient.id);

          return GestureDetector(
            onTap: interactive && !isAdded
                ? () => onIngredientTap?.call(ingredient.id)
                : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isAdded ? 0.35 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IngredientImage(ingredient: ingredient, size: 36),
                  const SizedBox(height: 2),
                  Text(
                    ingredient.name,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
