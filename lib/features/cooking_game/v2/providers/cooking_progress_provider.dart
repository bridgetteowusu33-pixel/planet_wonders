import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final cookingProgressProvider =
    NotifierProvider<CookingProgressNotifier, CookingProgress>(
  CookingProgressNotifier.new,
);

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class CookingProgress {
  const CookingProgress({
    this.bestStars = const <String, int>{},
    this.completedRecipes = const <String>{},
    this.totalDishesCooked = 0,
    this.loading = true,
  });

  /// recipeId → best star count (1-3).
  final Map<String, int> bestStars;

  /// Set of recipe IDs that have been completed at least once.
  final Set<String> completedRecipes;

  /// Total number of recipes completed (including replays).
  final int totalDishesCooked;

  /// Whether the initial load from disk is still in progress.
  final bool loading;

  CookingProgress copyWith({
    Map<String, int>? bestStars,
    Set<String>? completedRecipes,
    int? totalDishesCooked,
    bool? loading,
  }) {
    return CookingProgress(
      bestStars: bestStars ?? this.bestStars,
      completedRecipes: completedRecipes ?? this.completedRecipes,
      totalDishesCooked: totalDishesCooked ?? this.totalDishesCooked,
      loading: loading ?? this.loading,
    );
  }

  /// Best star count for a recipe, or 0 if never completed.
  int starsFor(String recipeId) => bestStars[recipeId] ?? 0;

  /// Whether a recipe has been completed at least once.
  bool hasCompleted(String recipeId) => completedRecipes.contains(recipeId);

  /// Number of unique recipes completed.
  int get uniqueRecipes => completedRecipes.length;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class CookingProgressNotifier extends Notifier<CookingProgress> {
  static const String _kStars = 'cooking_v2_stars';
  static const String _kCompleted = 'cooking_v2_completed';
  static const String _kTotal = 'cooking_v2_total';

  @override
  CookingProgress build() {
    _loadFromPrefs();
    return const CookingProgress();
  }

  /// Record a recipe completion. Updates best stars if improved.
  Future<void> recordCompletion({
    required String recipeId,
    required int stars,
  }) async {
    await _waitForLoad();

    final currentBest = state.bestStars[recipeId] ?? 0;
    final updatedStars = <String, int>{
      ...state.bestStars,
      recipeId: stars > currentBest ? stars : currentBest,
    };
    final updatedCompleted = <String>{...state.completedRecipes, recipeId};

    state = state.copyWith(
      bestStars: updatedStars,
      completedRecipes: updatedCompleted,
      totalDishesCooked: state.totalDishesCooked + 1,
    );

    await _persist();
  }

  // ---- Persistence --------------------------------------------------------

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Stars: JSON-encoded map { "recipeId": 3 }
    final starsJson = prefs.getString(_kStars);
    final starsMap = <String, int>{};
    if (starsJson != null) {
      final decoded = jsonDecode(starsJson);
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          if (entry.value is int) {
            starsMap[entry.key as String] = entry.value as int;
          }
        }
      }
    }

    // Completed: string list of recipe IDs.
    final completedList = prefs.getStringList(_kCompleted) ?? const [];
    final completedSet = <String>{...completedList};

    // Total dishes cooked.
    final total = prefs.getInt(_kTotal) ?? 0;

    state = CookingProgress(
      bestStars: starsMap,
      completedRecipes: completedSet,
      totalDishesCooked: total,
      loading: false,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStars, jsonEncode(state.bestStars));
    await prefs.setStringList(
      _kCompleted,
      state.completedRecipes.toList(growable: false),
    );
    await prefs.setInt(_kTotal, state.totalDishesCooked);
  }

  Future<void> _waitForLoad() async {
    if (!state.loading) return;
    for (int i = 0; i < 50; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (!state.loading) return;
    }
  }
}
