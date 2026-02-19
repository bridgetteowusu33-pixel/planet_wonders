import 'package:flutter/material.dart';

import '../recipe_story/presentation/recipe_story_screen.dart';
import 'models/recipe.dart';

/// Legacy cooking route wrapper.
///
/// This now reuses the upgraded Recipe Story experience so all
/// entry points share the same premium story UI.
class CookingRecipeStoryScreen extends StatelessWidget {
  const CookingRecipeStoryScreen({
    super.key,
    required this.recipe,
    required this.countryId,
    required this.source,
  });

  final Recipe recipe;
  final String countryId;
  final String source;

  @override
  Widget build(BuildContext context) {
    return RecipeStoryScreen(
      countryId: countryId,
      recipeId: _storyRecipeId(recipe.id),
      source: source,
    );
  }

  String _storyRecipeId(String raw) {
    if (raw == 'ghana_jollof') return 'ghana_jollof_story';
    if (raw.endsWith('_story')) return raw;
    return raw;
  }
}
