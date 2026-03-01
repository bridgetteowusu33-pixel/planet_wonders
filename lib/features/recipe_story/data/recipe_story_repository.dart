import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/recipe.dart';

class RecipeStoryRepository {
  RecipeStoryRepository._();

  static final RecipeStoryRepository instance = RecipeStoryRepository._();

  static const Map<String, List<String>> _baseAssetsByCountry = {
    'ghana': [
      'assets/recipe_story/ghana_recipes.json',
      'lib/features/recipe_story/data/ghana_recipes.json',
    ],
    'nigeria': [
      'lib/features/recipe_story/data/nigeria_recipes.json',
    ],
    'uk': [
      'lib/features/recipe_story/data/uk_recipes.json',
    ],
    'usa': [
      'lib/features/recipe_story/data/usa_recipes.json',
    ],
  };

  static const Map<String, List<String>> _recipePatchAssetsByCountry = {
    'ghana': ['assets/recipes/ghana_waakye.json'],
  };

  final Map<String, List<RecipeStory>> _cache = {};

  Future<List<RecipeStory>> loadRecipesForCountry(String countryId) async {
    if (_cache.containsKey(countryId)) {
      return _cache[countryId]!;
    }

    final mergedById = <String, RecipeStory>{};

    final baseAssets = _baseAssetsByCountry[countryId] ?? const <String>[];
    final patchAssets =
        _recipePatchAssetsByCountry[countryId] ?? const <String>[];

    for (final assetPath in [...baseAssets, ...patchAssets]) {
      final loaded = await _tryLoadFromAsset(assetPath);
      for (final recipe in loaded) {
        mergedById[recipe.id] = recipe;
      }
    }

    final recipes = mergedById.values.toList(growable: false);
    _cache[countryId] = recipes;
    return recipes;
  }

  Future<RecipeStory?> loadRecipe({
    required String countryId,
    required String recipeId,
  }) async {
    final recipes = await loadRecipesForCountry(countryId);

    for (final recipe in recipes) {
      if (recipe.id == recipeId) {
        return recipe;
      }
    }

    final alias = _recipeAlias(recipeId);
    if (alias != null) {
      for (final recipe in recipes) {
        if (recipe.id == alias) {
          return recipe;
        }
      }
    }

    return null;
  }

  String? _recipeAlias(String recipeId) {
    // Ghana cooking-game IDs → recipe-story IDs
    if (recipeId == 'ghana_jollof') return 'ghana_jollof_story';
    if (recipeId == 'ghana_waakye') return 'waakye';
    if (recipeId == 'jollof') return 'ghana_jollof_story';
    if (recipeId == 'ghana_banku') return 'banku_tilapia';
    if (recipeId == 'ghana_fufu') return 'ghana_fufu_story';
    if (recipeId == 'ghana_koko') return 'ghana_koko_story';
    if (recipeId == 'ghana_kelewele') return 'kelewele';
    if (recipeId == 'ghana_peanut_butter_soup') return 'ghana_peanut_butter_soup_story';
    if (recipeId == 'ghana_palmnut') return 'ghana_palmnut_story';
    if (recipeId == 'ghana_fried_rice') return 'fried_rice';
    // Nigeria cooking-game IDs → recipe-story IDs
    if (recipeId == 'nigeria_jollof') return 'nigeria_jollof_story';
    if (recipeId == 'nigeria_suya') return 'nigeria_suya_story';
    if (recipeId == 'nigeria_pounded_yam') return 'nigeria_pounded_yam_story';
    if (recipeId == 'nigeria_egusi') return 'nigeria_egusi_story';
    if (recipeId == 'nigeria_chin_chin') return 'nigeria_chin_chin_story';
    // UK cooking-game IDs → recipe-story IDs
    if (recipeId == 'uk_fish_and_chips') return 'uk_fish_and_chips_story';
    if (recipeId == 'uk_scones') return 'uk_scones_story';
    if (recipeId == 'uk_full_breakfast') return 'uk_full_breakfast_story';
    if (recipeId == 'uk_shepherds_pie') return 'uk_shepherds_pie_story';
    if (recipeId == 'uk_trifle') return 'uk_trifle_story';
    if (recipeId == 'uk_crumpets') return 'uk_crumpets_story';
    if (recipeId == 'uk_bangers_and_mash') return 'uk_bangers_and_mash_story';
    if (recipeId == 'uk_yorkshire_pudding') return 'uk_yorkshire_pudding_story';
    if (recipeId == 'uk_cornish_pasty') return 'uk_cornish_pasty_story';
    if (recipeId == 'uk_sticky_toffee') return 'uk_sticky_toffee_story';
    // USA cooking-game IDs → recipe-story IDs
    if (recipeId == 'usa_burger') return 'usa_burger_story';
    if (recipeId == 'usa_pizza') return 'usa_pizza_story';
    if (recipeId == 'usa_hotdog') return 'usa_hotdog_story';
    if (recipeId == 'usa_pancakes') return 'usa_pancakes_story';
    if (recipeId == 'usa_donut') return 'usa_donut_story';
    if (recipeId == 'usa_icecream') return 'usa_icecream_story';
    if (recipeId == 'usa_friedchicken') return 'usa_friedchicken_story';
    if (recipeId == 'usa_applepie') return 'usa_applepie_story';
    if (recipeId == 'usa_sandwich') return 'usa_sandwich_story';
    if (recipeId == 'usa_milkshake') return 'usa_milkshake_story';
    return null;
  }

  Future<List<RecipeStory>> _tryLoadFromAsset(String assetPath) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      return _parseRecipes(decoded);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('RecipeStoryRepository: failed loading $assetPath: $error');
      }
      return const [];
    }
  }

  List<RecipeStory> _parseRecipes(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      return const [];
    }

    final rootCountry = decoded['country'] is String
        ? (decoded['country'] as String).trim()
        : '';

    RecipeStory? parseEntry(Map<String, dynamic> entry) {
      // Some assets store `country` only at root level.
      final merged = <String, dynamic>{
        ...entry,
        if ((entry['country'] as String?)?.trim().isEmpty ?? true)
          'country': rootCountry,
      };
      try {
        return RecipeStory.fromJson(merged);
      } catch (error) {
        if (kDebugMode) {
          final id = entry['id'];
          debugPrint(
            'RecipeStoryRepository: invalid recipe entry ($id): $error',
          );
        }
        return null;
      }
    }

    final recipesNode = decoded['recipes'];
    if (recipesNode is List) {
      final recipes = <RecipeStory>[];
      for (final entry in recipesNode.whereType<Map>()) {
        final recipe = parseEntry(entry.cast<String, dynamic>());
        if (recipe != null) {
          recipes.add(recipe);
        }
      }
      return recipes;
    }

    if (decoded.containsKey('id')) {
      final recipe = parseEntry(decoded);
      return recipe == null ? const [] : [recipe];
    }

    return const [];
  }
}
