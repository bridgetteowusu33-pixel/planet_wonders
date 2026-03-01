import 'package:flutter/foundation.dart';

import 'v2_recipe_step.dart';

enum V2Difficulty { easy, medium, hard }

@immutable
class V2Ingredient {
  const V2Ingredient({
    required this.id,
    required this.name,
    required this.emoji,
    this.assetPath,
  });

  final String id;
  final String name;
  final String emoji;

  /// Optional PNG asset override. Falls back to emoji when null.
  final String? assetPath;
}

@immutable
class V2Recipe {
  const V2Recipe({
    required this.id,
    required this.countryId,
    required this.name,
    required this.emoji,
    required this.ingredients,
    required this.steps,
    required this.characterName,
    this.difficulty = V2Difficulty.easy,
    this.funFacts = const <String>[],
    this.dishImagePath,
  });

  final String id;
  final String countryId;
  final String name;
  final String emoji;
  final List<V2Ingredient> ingredients;
  final List<V2RecipeStep> steps;

  /// Country character name, e.g. "Afia".
  final String characterName;

  final V2Difficulty difficulty;
  final List<String> funFacts;

  /// Optional dish illustration PNG. Falls back to [emoji] when null or missing.
  final String? dishImagePath;
}
