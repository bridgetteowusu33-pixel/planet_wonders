import 'passport_service.dart';

class AchievementsService {
  static Future<void> onPuzzleCompleted({
    required String puzzleId,
    required String packId,
    required int stars,
    required int completedTimeMs,
  }) async {
    // Placeholder hook for the achievements system. This keeps puzzle-complete
    // events centralized so future unlock logic can be added without touching
    // puzzle UI code.
    await PassportService.unlockBadge('puzzle_${packId}_$puzzleId');

    if (stars == 3) {
      await PassportService.unlockBadge('puzzle_perfect_$packId');
    }
  }

  /// Called when a quiz is completed. Returns list of newly unlocked badge IDs.
  ///
  /// Badge rules (per-country):
  /// - `quiz_explorer_<countryId>` — complete 3+ quizzes for a country
  /// - `quiz_master_<countryId>` — complete ALL quizzes for a country (5+)
  /// - `quiz_history_star` — complete 3+ quizzes across any countries
  static Future<List<String>> onQuizCompleted({
    required int totalCorrect,
    required String countryId,
    required int countryCorrect,
  }) async {
    final existing = await PassportService.unlockedBadges();
    final newBadges = <String>[];

    // Global badge: 3+ total quizzes completed
    if (totalCorrect >= 3 && !existing.contains('quiz_history_star')) {
      await PassportService.unlockBadge('quiz_history_star');
      newBadges.add('quiz_history_star');
    }

    // Per-country badge: 3+ quizzes for this country
    final explorerBadge = 'quiz_explorer_$countryId';
    if (countryCorrect >= 3 && !existing.contains(explorerBadge)) {
      await PassportService.unlockBadge(explorerBadge);
      newBadges.add(explorerBadge);
    }

    // Per-country badge: all quizzes for this country (5+)
    final masterBadge = 'quiz_master_$countryId';
    if (countryCorrect >= 5 && !existing.contains(masterBadge)) {
      await PassportService.unlockBadge(masterBadge);
      newBadges.add(masterBadge);
    }

    return newBadges;
  }
}
