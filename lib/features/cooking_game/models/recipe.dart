import 'cooking_step.dart';

enum RecipeDifficulty { easy, medium }

class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.emoji,
  });

  final String id;
  final String name;
  final String emoji;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.countryId,
    required this.name,
    required this.emoji,
    required this.ingredients,
    required this.steps,
    required this.funFacts,
    this.difficulty = RecipeDifficulty.easy,
  });

  final String id;
  final String countryId;
  final String name;
  final String emoji;
  final List<Ingredient> ingredients;
  final List<CookingStep> steps;
  final List<String> funFacts;
  final RecipeDifficulty difficulty;

  int get stepCount => steps.length;

  CookingStep? stepFor(CookingState state) {
    for (final step in steps) {
      if (step.state == state) return step;
    }
    return null;
  }
}
