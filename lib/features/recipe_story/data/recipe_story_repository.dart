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
    if (recipeId == 'ghana_jollof') return 'ghana_jollof_story';
    if (recipeId == 'ghana_waakye') return 'waakye';
    if (recipeId == 'jollof') return 'ghana_jollof_story';
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
