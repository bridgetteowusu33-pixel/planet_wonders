import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/recipe.dart';
import '../domain/recipe_album_entry.dart';
import '../domain/step_reward.dart';

/// Provider for the recipe album — completed recipes the player has earned.
final recipeAlbumProvider =
    NotifierProvider<RecipeAlbumNotifier, RecipeAlbumState>(
  RecipeAlbumNotifier.new,
);

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class RecipeAlbumState {
  const RecipeAlbumState({
    this.entries = const [],
    this.loading = true,
  });

  final List<RecipeAlbumEntry> entries;
  final bool loading;

  RecipeAlbumState copyWith({
    List<RecipeAlbumEntry>? entries,
    bool? loading,
  }) {
    return RecipeAlbumState(
      entries: entries ?? this.entries,
      loading: loading ?? this.loading,
    );
  }

  /// Check if a recipe has been completed.
  bool hasCompleted(String recipeId) =>
      entries.any((e) => e.recipeId == recipeId);

  /// Get the album entry for a specific recipe.
  RecipeAlbumEntry? entryFor(String recipeId) {
    for (final entry in entries) {
      if (entry.recipeId == recipeId) return entry;
    }
    return null;
  }

  /// Total unique recipes completed.
  int get totalRecipes => entries.length;

  /// Total micro-rewards earned across all recipes.
  int get totalRewards =>
      entries.fold(0, (sum, e) => sum + e.earnedRewards.length);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class RecipeAlbumNotifier extends Notifier<RecipeAlbumState> {
  static const String _kAlbumEntries = 'recipe_album_entries';

  @override
  RecipeAlbumState build() {
    _loadFromPrefs();
    return const RecipeAlbumState();
  }

  /// Save a completed recipe to the album.
  ///
  /// If the recipe was already completed, increments the play count
  /// and merges any new rewards.
  Future<void> saveCompletion({
    required RecipeStory recipe,
    required String countryId,
    required List<StepReward> earnedRewards,
  }) async {
    await _waitForLoad();

    final existing = state.entryFor(recipe.id);
    final updatedEntries = [...state.entries];

    if (existing != null) {
      // Replay — increment play count, merge rewards.
      final merged = existing.copyWith(
        playCount: existing.playCount + 1,
        earnedRewards: _mergeRewards(existing.earnedRewards, earnedRewards),
      );
      final index = updatedEntries.indexWhere((e) => e.recipeId == recipe.id);
      if (index >= 0) updatedEntries[index] = merged;
    } else {
      // First completion.
      updatedEntries.add(RecipeAlbumEntry(
        recipeId: recipe.id,
        countryId: countryId,
        title: recipe.title,
        emoji: recipe.emoji,
        completedAt: DateTime.now(),
        stars: 3,
        badgeTitle: recipe.badgeTitle,
        earnedRewards: earnedRewards,
      ));
    }

    state = state.copyWith(entries: updatedEntries);
    await _persist();
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_kAlbumEntries) ?? const [];

    final entries = <RecipeAlbumEntry>[];
    for (final raw in rawList) {
      final entry = RecipeAlbumEntry.decode(raw);
      if (entry != null) entries.add(entry);
    }

    state = RecipeAlbumState(entries: entries, loading: false);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        state.entries.map((e) => e.encode()).toList(growable: false);
    await prefs.setStringList(_kAlbumEntries, encoded);
  }

  Future<void> _waitForLoad() async {
    if (!state.loading) return;
    for (int i = 0; i < 50; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (!state.loading) return;
    }
  }

  /// Merge two reward lists, deduplicating by ID.
  List<StepReward> _mergeRewards(
    List<StepReward> existing,
    List<StepReward> incoming,
  ) {
    final ids = existing.map((r) => r.id).toSet();
    final merged = [...existing];
    for (final reward in incoming) {
      if (!ids.contains(reward.id)) {
        merged.add(reward);
        ids.add(reward.id);
      }
    }
    return merged;
  }
}
