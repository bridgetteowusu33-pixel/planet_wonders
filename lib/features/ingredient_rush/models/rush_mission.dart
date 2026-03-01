/// A single objective within an Ingredient Rush mission.
class RushObjective {
  const RushObjective({
    required this.ingredientId,
    required this.name,
    required this.emoji,
    required this.targetCount,
    this.assetPath,
  });

  final String ingredientId;
  final String name;
  final String emoji;
  final int targetCount;

  /// Optional PNG path; falls back to emoji if null or missing.
  final String? assetPath;
}

/// A complete Ingredient Rush mission built from a cooking recipe.
class RushMission {
  const RushMission({
    required this.recipeId,
    required this.recipeName,
    required this.recipeEmoji,
    this.dishImagePath,
    required this.countryId,
    required this.characterName,
    required this.objectives,
    required this.allIngredientIds,
    required this.distractorPool,
  });

  final String recipeId;
  final String recipeName;
  final String recipeEmoji;

  /// Illustrated dish image; falls back to [recipeEmoji] when null or missing.
  final String? dishImagePath;
  final String countryId;
  final String characterName;

  /// Ordered list of objectives the player must complete.
  final List<RushObjective> objectives;

  /// All ingredient IDs that are valid targets across all objectives.
  final Set<String> allIngredientIds;

  /// Ingredient entries (id, name, emoji, assetPath) for distractors.
  final List<RushObjective> distractorPool;

  int get totalIngredientCount =>
      objectives.fold<int>(0, (sum, o) => sum + o.targetCount);
}
