import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/achievements_service.dart';
import '../data/quiz_catalog.dart';
import '../data/quiz_models.dart';
import '../data/quiz_storage.dart';

// ---------------------------------------------------------------------------
// Catalog & storage singletons
// ---------------------------------------------------------------------------

final quizCatalogProvider = Provider<QuizCatalog>((ref) => QuizCatalog());

final quizStorageProvider = Provider<QuizStorage>((ref) => QuizStorage());

// ---------------------------------------------------------------------------
// Load all quiz items from JSON
// ---------------------------------------------------------------------------

final quizItemsProvider = FutureProvider<List<QuizItem>>((ref) async {
  return ref.watch(quizCatalogProvider).loadQuizzes();
});

// ---------------------------------------------------------------------------
// Quizzes filtered by country — use this from country-scoped screens
// ---------------------------------------------------------------------------

final quizItemsByCountryProvider =
    FutureProvider.family<List<QuizItem>, String>((ref, countryId) async {
  final all = await ref.watch(quizItemsProvider.future);
  return all.where((q) => q.countryId == countryId).toList(growable: false);
});

// ---------------------------------------------------------------------------
// Load persisted progress
// ---------------------------------------------------------------------------

final quizProgressMapProvider =
    FutureProvider<Map<String, QuizProgress>>((ref) async {
  return ref.watch(quizStorageProvider).loadProgressMap();
});

// ---------------------------------------------------------------------------
// Daily quiz rotation
// ---------------------------------------------------------------------------

final quizDailyProvider =
    NotifierProvider<QuizDailyNotifier, QuizDailyState>(
  QuizDailyNotifier.new,
);

class QuizDailyNotifier extends Notifier<QuizDailyState> {
  @override
  QuizDailyState build() {
    _loadFromStorage();
    return const QuizDailyState();
  }

  Future<void> _loadFromStorage() async {
    final storage = ref.read(quizStorageProvider);
    final saved = await storage.loadDailyState();
    state = saved;
  }

  /// Refresh the daily quiz. Call this when quizzes are loaded.
  void refreshDaily(List<QuizItem> allQuizzes) {
    if (allQuizzes.isEmpty) return;

    final today = DateTime.now().day;
    if (state.lastSeenDay == today && state.featuredQuizId.isNotEmpty) return;

    final index = today % allQuizzes.length;
    state = QuizDailyState(
      lastSeenDay: today,
      featuredQuizId: allQuizzes[index].id,
    );
    _persist();
  }

  Future<void> _persist() async {
    final storage = ref.read(quizStorageProvider);
    await storage.saveDailyState(state);
  }
}

// ---------------------------------------------------------------------------
// Quiz actions (complete quiz, check badges)
// ---------------------------------------------------------------------------

final quizActionsProvider = Provider<QuizActions>((ref) => QuizActions(ref));

class QuizActions {
  const QuizActions(this._ref);

  final Ref _ref;

  QuizStorage get _storage => _ref.read(quizStorageProvider);

  /// Mark a quiz as completed and check for badge unlocks.
  /// Returns list of newly unlocked badge IDs (empty if none).
  Future<List<String>> completeQuiz(String quizId, String countryId) async {
    // Save progress
    final progress = QuizProgress(
      quizId: quizId,
      countryId: countryId,
      completed: true,
      completedAt: DateTime.now(),
    );
    await _storage.saveProgress(progress);

    // Refresh the progress provider
    _ref.invalidate(quizProgressMapProvider);

    // Check badges — count per-country
    final allProgress = await _storage.loadProgressMap();
    final totalCompleted =
        allProgress.values.where((p) => p.completed).length;
    final countryCompleted = allProgress.values
        .where((p) => p.completed && p.countryId == countryId)
        .length;

    return AchievementsService.onQuizCompleted(
      totalCorrect: totalCompleted,
      countryId: countryId,
      countryCorrect: countryCompleted,
    );
  }
}
