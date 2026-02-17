import 'cooking_step.dart';

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
  });

  final String id;
  final String countryId;
  final String name;
  final String emoji;
  final List<Ingredient> ingredients;
  final List<CookingStep> steps;
  final List<String> funFacts;

  CookingStep? stepFor(CookingState state) {
    for (final step in steps) {
      if (step.state == state) return step;
    }
    return null;
  }
}
