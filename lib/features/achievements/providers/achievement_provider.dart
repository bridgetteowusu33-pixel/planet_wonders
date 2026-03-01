import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement.dart';

final achievementProvider =
    NotifierProvider<AchievementNotifier, AchievementState>(
      AchievementNotifier.new,
    );

class AchievementState {
  const AchievementState({
    required this.definitions,
    required this.unlockedIds,
    required this.completedStories,
    required this.completedRecipeStories,
    required this.completedCookingRecipes,
    required this.completedIngredientRush,
    required this.completedPackSuitcase,
    required this.pendingUnlockIds,
    required this.loading,
  });

  const AchievementState.initial()
    : definitions = const [],
      unlockedIds = const <String>{},
      completedStories = const <String>{},
      completedRecipeStories = const <String>{},
      completedCookingRecipes = const <String>{},
      completedIngredientRush = const <String>{},
      completedPackSuitcase = const <String>{},
      pendingUnlockIds = const [],
      loading = true;

  final List<Achievement> definitions;
  final Set<String> unlockedIds;
  final Set<String> completedStories;
  final Set<String> completedRecipeStories;
  final Set<String> completedCookingRecipes;
  final Set<String> completedIngredientRush;
  final Set<String> completedPackSuitcase;
  final List<String> pendingUnlockIds;
  final bool loading;

  int get totalCount => definitions.length;
  int get unlockedCount => unlockedIds.length;

  int get unlockedScore => definitions
      .where((a) => unlockedIds.contains(a.id))
      .fold<int>(0, (sum, a) => sum + a.score);

  Achievement? get pendingUnlockAchievement {
    if (pendingUnlockIds.isEmpty) return null;
    final id = pendingUnlockIds.first;
    for (final achievement in definitions) {
      if (achievement.id == id) return achievement;
    }
    return null;
  }

  List<Achievement> get unlockedAchievements {
    return definitions
        .where((achievement) => unlockedIds.contains(achievement.id))
        .toList(growable: false);
  }

  List<Achievement> unlockedAchievementsForCountry(String countryId) {
    return unlockedAchievements
        .where((achievement) {
          final condition = achievement.unlockCondition;
          if (condition.countryId == countryId) return true;
          final recipeId = condition.recipeId;
          if (recipeId == null) return false;
          if (recipeId.startsWith('${countryId}_')) return true;
          return false;
        })
        .toList(growable: false);
  }

  AchievementState copyWith({
    List<Achievement>? definitions,
    Set<String>? unlockedIds,
    Set<String>? completedStories,
    Set<String>? completedRecipeStories,
    Set<String>? completedCookingRecipes,
    Set<String>? completedIngredientRush,
    Set<String>? completedPackSuitcase,
    List<String>? pendingUnlockIds,
    bool? loading,
  }) {
    return AchievementState(
      definitions: definitions ?? this.definitions,
      unlockedIds: unlockedIds ?? this.unlockedIds,
      completedStories: completedStories ?? this.completedStories,
      completedRecipeStories:
          completedRecipeStories ?? this.completedRecipeStories,
      completedCookingRecipes:
          completedCookingRecipes ?? this.completedCookingRecipes,
      completedIngredientRush:
          completedIngredientRush ?? this.completedIngredientRush,
      completedPackSuitcase:
          completedPackSuitcase ?? this.completedPackSuitcase,
      pendingUnlockIds: pendingUnlockIds ?? this.pendingUnlockIds,
      loading: loading ?? this.loading,
    );
  }
}

class AchievementNotifier extends Notifier<AchievementState> {
  static const String _definitionsPath =
      'assets/achievements/achievements.json';

  static const String _kUnlockedIds = 'achievements_unlocked_ids';
  static const String _kStories = 'achievements_story_completed';
  static const String _kRecipeStories = 'achievements_recipe_story_completed';
  static const String _kCookingRecipes =
      'achievements_cooking_recipe_completed';
  static const String _kIngredientRush =
      'achievements_ingredient_rush_completed';
  static const String _kPackSuitcase =
      'achievements_pack_suitcase_completed';
  Future<void>? _loadingTask;

  @override
  AchievementState build() {
    _loadingTask ??= _load();
    return const AchievementState.initial();
  }

  Future<void> markStoryCompleted({required String countryId}) async {
    await _waitForInitialLoad();
    final key = '$countryId::story';
    if (state.completedStories.contains(key)) return;

    final stories = {...state.completedStories, key};
    state = state.copyWith(completedStories: stories);
    await _persistProgress();
    await _unlockEligible(queueNewUnlocks: true);
  }

  Future<void> markRecipeStoryCompleted({
    required String countryId,
    required String recipeId,
  }) async {
    await _waitForInitialLoad();
    final key = _completionKey(countryId: countryId, recipeId: recipeId);
    if (state.completedRecipeStories.contains(key)) {
      return;
    }

    final stories = {...state.completedRecipeStories, key};
    state = state.copyWith(completedRecipeStories: stories);
    await _persistProgress();
    await _unlockEligible(queueNewUnlocks: true);
  }

  Future<void> markCookingRecipeCompleted({
    required String countryId,
    required String recipeId,
  }) async {
    await _waitForInitialLoad();
    final key = _completionKey(countryId: countryId, recipeId: recipeId);
    if (state.completedCookingRecipes.contains(key)) {
      return;
    }

    final recipes = {...state.completedCookingRecipes, key};
    state = state.copyWith(completedCookingRecipes: recipes);
    await _persistProgress();
    await _unlockEligible(queueNewUnlocks: true);
  }

  Future<void> markIngredientRushCompleted({
    required String countryId,
    required String recipeId,
    required int wrongTaps,
    required double timerFractionRemaining,
  }) async {
    await _waitForInitialLoad();
    final key = _completionKey(countryId: countryId, recipeId: recipeId);

    final rush = {...state.completedIngredientRush, key};
    // Store special markers for perfect/speedy runs.
    if (wrongTaps == 0) {
      rush.add('$key::perfect');
    }
    if (timerFractionRemaining > 0.5) {
      rush.add('$key::speedy');
    }

    state = state.copyWith(completedIngredientRush: rush);
    await _persistProgress();
    await _unlockEligible(queueNewUnlocks: true);
  }

  Future<void> markPackSuitcaseCompleted({
    required String countryId,
    required String packId,
    required int wrongDrops,
  }) async {
    await _waitForInitialLoad();
    final key = '$countryId::$packId';

    final packs = {...state.completedPackSuitcase, key};
    if (wrongDrops == 0) {
      packs.add('$key::perfect');
    }

    state = state.copyWith(completedPackSuitcase: packs);
    await _persistProgress();
    await _unlockEligible(queueNewUnlocks: true);
  }

  void consumePendingUnlock() {
    if (state.pendingUnlockIds.isEmpty) return;
    final queue = [...state.pendingUnlockIds]..removeAt(0);
    state = state.copyWith(pendingUnlockIds: queue);
  }

  Future<void> _load() async {
    try {
      final defs = await _loadDefinitions();
      final prefs = await SharedPreferences.getInstance();

      state = state.copyWith(
        definitions: defs,
        unlockedIds: (prefs.getStringList(_kUnlockedIds) ?? const []).toSet(),
        completedStories:
            (prefs.getStringList(_kStories) ?? const []).toSet(),
        completedRecipeStories:
            (prefs.getStringList(_kRecipeStories) ?? const []).toSet(),
        completedCookingRecipes:
            (prefs.getStringList(_kCookingRecipes) ?? const []).toSet(),
        completedIngredientRush:
            (prefs.getStringList(_kIngredientRush) ?? const []).toSet(),
        completedPackSuitcase:
            (prefs.getStringList(_kPackSuitcase) ?? const []).toSet(),
        loading: false,
      );

      await _unlockEligible(queueNewUnlocks: false);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Achievement load failed: $error');
        debugPrint('$stackTrace');
      }
      state = state.copyWith(loading: false);
    }
  }

  Future<void> _waitForInitialLoad() async {
    _loadingTask ??= _load();
    await _loadingTask;
  }

  Future<List<Achievement>> _loadDefinitions() async {
    final raw = await rootBundle.loadString(_definitionsPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Achievements JSON root must be an object.');
    }

    final entries = decoded['achievements'];
    if (entries is! List) {
      throw const FormatException(
        'Achievements JSON must contain achievements list.',
      );
    }

    return entries
        .whereType<Map>()
        .map((entry) => Achievement.fromJson(entry.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<void> _unlockEligible({required bool queueNewUnlocks}) async {
    if (state.definitions.isEmpty) return;

    var unlocked = {...state.unlockedIds};
    final queue = [...state.pendingUnlockIds];
    var changed = false;

    for (final achievement in state.definitions) {
      if (unlocked.contains(achievement.id)) {
        continue;
      }

      if (_isUnlocked(achievement)) {
        unlocked.add(achievement.id);
        changed = true;
        if (queueNewUnlocks) {
          queue.add(achievement.id);
        }
      }
    }

    if (!changed) return;

    state = state.copyWith(unlockedIds: unlocked, pendingUnlockIds: queue);
    await _persistProgress();
  }

  bool _isUnlocked(Achievement achievement) {
    final condition = achievement.unlockCondition;
    switch (condition.type) {
      case 'story_completed':
        final storyCount = _countMatchingCompletions(
          completions: state.completedStories,
          countryId: condition.countryId,
          recipeId: null,
        );
        if (storyCount < condition.minCount) return false;
        if (condition.minCountries > 0) {
          final countries = state.completedStories
              .map((k) => k.split('::').first)
              .where((v) => v.isNotEmpty)
              .toSet();
          return countries.length >= condition.minCountries;
        }
        return true;
      case 'recipe_story_completed':
        final count = _countMatchingCompletions(
          completions: state.completedRecipeStories,
          countryId: condition.countryId,
          recipeId: condition.recipeId,
        );
        return count >= condition.minCount;
      case 'cooking_recipe_completed':
        final count = _countMatchingCompletions(
          completions: state.completedCookingRecipes,
          countryId: condition.countryId,
          recipeId: condition.recipeId,
        );
        return count >= condition.minCount;
      case 'any_recipe_completed':
        final all = {
          ...state.completedRecipeStories,
          ...state.completedCookingRecipes,
        };
        if (all.length < condition.minCount) {
          return false;
        }
        if (condition.minCountries > 0) {
          final countries = all
              .map((key) => key.split('::').first)
              .where((value) => value.isNotEmpty)
              .toSet();
          return countries.length >= condition.minCountries;
        }
        return true;
      case 'ingredient_rush_completed':
        final count = _countMatchingCompletions(
          completions: state.completedIngredientRush,
          countryId: condition.countryId,
          recipeId: condition.recipeId,
        );
        if (count < condition.minCount) return false;
        // Check for special qualifiers (perfect, speedy).
        final qualifier = condition.qualifier;
        if (qualifier != null && qualifier.isNotEmpty) {
          return state.completedIngredientRush
              .any((key) => key.endsWith('::$qualifier'));
        }
        return true;
      case 'pack_suitcase_completed':
        final packCount = _countMatchingCompletions(
          completions: state.completedPackSuitcase,
          countryId: condition.countryId,
          recipeId: null,
        );
        if (packCount < condition.minCount) return false;
        if (condition.minCountries > 0) {
          final countries = state.completedPackSuitcase
              .where((k) => !k.contains('::perfect'))
              .map((k) => k.split('::').first)
              .where((v) => v.isNotEmpty)
              .toSet();
          if (countries.length < condition.minCountries) return false;
        }
        final packQualifier = condition.qualifier;
        if (packQualifier != null && packQualifier.isNotEmpty) {
          return state.completedPackSuitcase
              .any((key) => key.endsWith('::$packQualifier'));
        }
        return true;
      default:
        return false;
    }
  }

  int _countMatchingCompletions({
    required Set<String> completions,
    String? countryId,
    String? recipeId,
  }) {
    var count = 0;
    for (final value in completions) {
      final parts = value.split('::');
      if (parts.length != 2) continue;
      final cId = parts[0];
      final rId = parts[1];

      final countryMatches = countryId == null || countryId == cId;
      final recipeMatches = recipeId == null || recipeId == rId;
      if (countryMatches && recipeMatches) {
        count++;
      }
    }
    return count;
  }

  Future<void> _persistProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kUnlockedIds, state.unlockedIds.toList());
    await prefs.setStringList(
      _kStories,
      state.completedStories.toList(),
    );
    await prefs.setStringList(
      _kRecipeStories,
      state.completedRecipeStories.toList(),
    );
    await prefs.setStringList(
      _kCookingRecipes,
      state.completedCookingRecipes.toList(),
    );
    await prefs.setStringList(
      _kIngredientRush,
      state.completedIngredientRush.toList(),
    );
    await prefs.setStringList(
      _kPackSuitcase,
      state.completedPackSuitcase.toList(),
    );
  }

  String _completionKey({required String countryId, required String recipeId}) {
    return '$countryId::$recipeId';
  }
}
