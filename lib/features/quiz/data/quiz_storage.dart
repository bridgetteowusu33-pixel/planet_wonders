import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_models.dart';

/// Persists quiz progress and daily state via SharedPreferences.
class QuizStorage {
  static const String _kProgress = 'pw_quiz_progress_v1';
  static const String _kDaily = 'pw_quiz_daily_v1';

  // ---------------------------------------------------------------------------
  // Progress
  // ---------------------------------------------------------------------------

  Future<Map<String, QuizProgress>> loadProgressMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProgress);
    if (raw == null || raw.isEmpty) return const {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          QuizProgress.fromJson(
              (value as Map).cast<String, dynamic>()),
        ),
      );
    } catch (_) {
      return const {};
    }
  }

  Future<void> saveProgress(QuizProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final current = Map<String, QuizProgress>.of(await loadProgressMap());
    current[progress.quizId] = progress;
    await prefs.setString(_kProgress, _encodeProgressMap(current));
  }

  static String _encodeProgressMap(Map<String, QuizProgress> map) {
    return jsonEncode(
      map.map((key, value) => MapEntry(key, value.toJson())),
    );
  }

  // ---------------------------------------------------------------------------
  // Daily state
  // ---------------------------------------------------------------------------

  Future<QuizDailyState> loadDailyState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDaily);
    if (raw == null || raw.isEmpty) return const QuizDailyState();

    try {
      return QuizDailyState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const QuizDailyState();
    }
  }

  Future<void> saveDailyState(QuizDailyState daily) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDaily, jsonEncode(daily.toJson()));
  }
}
