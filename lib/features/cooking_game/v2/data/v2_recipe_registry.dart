import '../models/step_type.dart';
import '../models/v2_recipe.dart';
import '../models/v2_recipe_step.dart';
import '../../data/recipes_ghana.dart' as legacy_data;
import '../../models/recipe.dart' as legacy;
import 'v2_recipes_ghana.dart';
import 'v2_recipes_nigeria.dart';

// ---------------------------------------------------------------------------
// V2 recipe registry
// ---------------------------------------------------------------------------

/// All V2 recipes: hand-crafted showcase recipes first, then auto-upgraded
/// legacy recipes (skipping any whose upgraded ID clashes with a showcase).
final Map<String, V2Recipe> v2RecipeRegistry = () {
  final map = <String, V2Recipe>{
    for (final r in ghanaV2Recipes) r.id: r,
    for (final r in nigeriaV2Recipes) r.id: r,
  };
  // Auto-upgrade all legacy recipes.
  for (final legacyRecipe in legacy_data.cookingRecipeRegistry.values) {
    final upgraded = upgradeRecipe(legacyRecipe);
    // Don't overwrite hand-crafted showcase recipes.
    map.putIfAbsent(upgraded.id, () => upgraded);
  }
  return map;
}();

List<V2Recipe> v2RecipesForCountry(String countryId) {
  return v2RecipeRegistry.values
      .where((r) => r.countryId == countryId)
      .toList(growable: false);
}

V2Recipe? findV2Recipe(String recipeId) => v2RecipeRegistry[recipeId];

// ---------------------------------------------------------------------------
// Legacy adapter — upgrades a V1 Recipe to V2 with sensible defaults
// ---------------------------------------------------------------------------

/// Character name lookup matching the premium engine.
String _characterFor(String countryId) {
  return switch (countryId.trim().toLowerCase()) {
    'ghana' => 'Afia',
    'nigeria' => 'Adetutu',
    'uk' || 'united_kingdom' => 'Heze & Aza',
    'usa' || 'united_states' => 'Ava',
    _ => 'Chef',
  };
}

/// Converts a legacy 3-step Recipe into a V2Recipe with varied step types.
V2Recipe upgradeRecipe(legacy.Recipe recipe) {
  final character = _characterFor(recipe.countryId);

  final ingredients = recipe.ingredients
      .map((i) => V2Ingredient(id: i.id, name: i.name, emoji: i.emoji))
      .toList(growable: false);

  // Build a richer step sequence from the simple 3-step pattern.
  final steps = <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag all the ingredients into the pot!',
      chefLine: '$character says: Let\u{2019}s get started!',
      factText: recipe.funFacts.isNotEmpty ? recipe.funFacts[0] : null,
    ),
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to chop the ingredients!',
      chefLine: '$character says: Chop chop chop!',
      targetCount: 4,
      ingredientIds: ingredients.map((i) => i.id).toList(growable: false),
      factText: recipe.funFacts.length > 1 ? recipe.funFacts[1] : null,
    ),
    V2RecipeStep(
      type: V2StepType.boil,
      instruction: 'Hold to boil until ready!',
      chefLine: '$character says: Let it bubble!',
      durationMs: 3000,
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Stir in circles until everything is mixed!',
      chefLine: '$character says: Round and round!',
    ),
    V2RecipeStep(
      type: V2StepType.season,
      instruction: 'Tap to add the perfect seasoning!',
      chefLine: '$character says: A little spice makes it nice!',
      targetCount: 2,
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Scoop and serve!',
      chefLine: '$character says: Beautiful plating!',
      targetCount: 2,
      factText: recipe.funFacts.length > 2 ? recipe.funFacts[2] : null,
    ),
  ];

  return V2Recipe(
    id: '${recipe.id}_v2',
    countryId: recipe.countryId,
    name: recipe.name,
    emoji: recipe.emoji,
    ingredients: ingredients,
    steps: steps,
    characterName: character,
    difficulty: switch (recipe.difficulty) {
      legacy.RecipeDifficulty.easy => V2Difficulty.easy,
      legacy.RecipeDifficulty.medium => V2Difficulty.medium,
    },
    funFacts: recipe.funFacts,
  );
}
