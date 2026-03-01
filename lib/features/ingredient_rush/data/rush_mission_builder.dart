import '../../cooking_game/data/recipes_ghana.dart';
import '../../cooking_game/models/recipe.dart';
import '../models/rush_mission.dart';

/// Builds [RushMission] instances from the shared [cookingRecipeRegistry].
class RushMissionBuilder {
  const RushMissionBuilder._();

  /// Build a mission for the given [recipeId].
  ///
  /// Returns `null` if the recipe is not found.
  static RushMission? buildMission(String recipeId) {
    final recipe = cookingRecipeRegistry[recipeId];
    if (recipe == null) return null;
    return _fromRecipe(recipe);
  }

  /// Build missions for every recipe in a country.
  static List<RushMission> missionsForCountry(String countryId) {
    return cookingRecipesForCountry(countryId)
        .map(_fromRecipe)
        .toList(growable: false);
  }

  static RushMission _fromRecipe(Recipe recipe) {
    final objectives = recipe.ingredients.map((ing) {
      return RushObjective(
        ingredientId: ing.id,
        name: ing.name,
        emoji: ing.emoji,
        targetCount: _targetCountFor(ing.id),
        assetPath: _ingredientAssetPath(recipe.countryId, ing.id),
      );
    }).toList(growable: false);

    final targetIds = recipe.ingredients.map((i) => i.id).toSet();

    // Build distractor pool from other recipes in the same country.
    final distractors = <RushObjective>[];
    final seenIds = <String>{...targetIds};
    for (final other in cookingRecipesForCountry(recipe.countryId)) {
      if (other.id == recipe.id) continue;
      for (final ing in other.ingredients) {
        if (seenIds.contains(ing.id)) continue;
        seenIds.add(ing.id);
        distractors.add(RushObjective(
          ingredientId: ing.id,
          name: ing.name,
          emoji: ing.emoji,
          targetCount: 0,
          assetPath: _ingredientAssetPath(recipe.countryId, ing.id),
        ));
      }
    }

    return RushMission(
      recipeId: recipe.id,
      recipeName: recipe.name,
      recipeEmoji: recipe.emoji,
      dishImagePath: _dishImagePath(recipe.id),
      countryId: recipe.countryId,
      characterName: _characterNameFor(recipe.countryId),
      objectives: objectives,
      allIngredientIds: targetIds,
      distractorPool: distractors,
    );
  }

  static int _targetCountFor(String ingredientId) {
    // Seasonings / small items need fewer.
    const smallItems = {'salt', 'oil', 'pepper', 'sugar', 'spice', 'ginger'};
    return smallItems.contains(ingredientId) ? 3 : 4;
  }

  static String _ingredientAssetPath(String countryId, String ingredientId) {
    return 'assets/cooking/v2/$countryId/ingredients/$ingredientId.webp';
  }

  static const _dishImages = <String, String>{
    // Ghana
    'ghana_jollof': 'assets/food/ghana/ghana_jollof_chef.webp',
    'ghana_waakye': 'assets/food/ghana/ghana_waakye_chef.webp',
    'ghana_banku': 'assets/food/ghana/ghana_banku_chef.webp',
    'ghana_fufu': 'assets/food/ghana/ghana_fufu_chef.webp',
    'ghana_koko': 'assets/food/ghana/ghana_koko_chef.webp',
    'ghana_kelewele': 'assets/food/ghana/ghana_kelewele_chef.webp',
    'ghana_peanut_butter_soup': 'assets/food/ghana/ghana_palmnut_soup_chef.webp',
    'ghana_palmnut': 'assets/food/ghana/ghana_palmnut_soup_chef.webp',
    'ghana_fried_rice': 'assets/food/ghana/ghana_fried_rice_chef.webp',
    // Nigeria
    'nigeria_jollof': 'assets/food/nigeria/ng_jollof_chef.webp',
    'nigeria_suya': 'assets/food/nigeria/ng_suya_chef.webp',
    'nigeria_pounded_yam': 'assets/food/nigeria/ng_pounded_yam_chef.webp',
    'nigeria_egusi': 'assets/food/nigeria/ng_egusi_chef.webp',
    'nigeria_chin_chin': 'assets/food/nigeria/ng_chin_chin_chef.webp',
    // UK
    'uk_fish_and_chips': 'assets/food/uk/fish_and_chips.webp',
    'uk_scones': 'assets/food/uk/Scones.webp',
    'uk_full_breakfast': 'assets/food/uk/English_breakfast.webp',
    'uk_shepherds_pie': 'assets/food/uk/Shepherds_pie.webp',
    'uk_trifle': 'assets/food/uk/Trifle.webp',
    'uk_crumpets': 'assets/food/uk/Crumpets.webp',
    'uk_bangers_and_mash': 'assets/food/uk/Bangers_and_mash.webp',
    'uk_yorkshire_pudding': 'assets/food/uk/Yorkshire_pudding.webp',
    'uk_cornish_pasty': 'assets/food/uk/Cornish_pasty.webp',
    'uk_sticky_toffee': 'assets/food/uk/sticky_toffee_pudding.webp',
    // USA
    'usa_burger': 'assets/food/usa/burgers.webp',
    'usa_pizza': 'assets/food/usa/pizza.webp',
    'usa_hotdog': 'assets/food/usa/hotdog.webp',
    'usa_pancakes': 'assets/food/usa/pancakes.webp',
    'usa_donut': 'assets/food/usa/donuts.webp',
    'usa_icecream': 'assets/food/usa/ice_cream.webp',
    'usa_friedchicken': 'assets/food/usa/fried_chicken.webp',
    'usa_applepie': 'assets/food/usa/apple_pie.webp',
    'usa_sandwich': 'assets/food/usa/sandwich.webp',
    'usa_milkshake': 'assets/food/usa/milkshake.webp',
  };

  static String? _dishImagePath(String recipeId) => _dishImages[recipeId];

  static String _characterNameFor(String countryId) {
    return switch (countryId.trim().toLowerCase()) {
      'ghana' => 'Afia',
      'nigeria' => 'Adetutu',
      'uk' || 'united_kingdom' => 'The Twins',
      'usa' || 'united_states' => 'Ava',
      _ => 'Chef',
    };
  }
}
