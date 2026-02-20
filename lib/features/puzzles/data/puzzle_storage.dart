import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'puzzle_models.dart';

class PuzzleStorage {
  static const String _kProgress = 'pw_puzzle_progress_v1';
  static const String _kResume = 'pw_puzzle_resume_v1';
  static const String _kLastOpenedPuzzle = 'pw_puzzle_last_opened';
  static const int _maxResumeEntries = 30;

  Future<Map<String, PuzzleProgress>> loadProgressMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProgress);
    if (raw == null || raw.isEmpty) return const {};
    return decodeProgressMap(raw);
  }

  Future<void> saveProgress(PuzzleProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final current = Map<String, PuzzleProgress>.of(await loadProgressMap());
    current[progress.puzzleId] = progress;
    await prefs.setString(_kProgress, encodeProgressMap(current));
  }

  Future<PuzzleResumeState?> loadResumeState(String puzzleId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kResume);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    final entry = decoded[puzzleId];
    if (entry is! Map<String, dynamic>) return null;
    final resume = PuzzleResumeState.fromJson(entry);
    if (resume.puzzleId.isEmpty) return null;
    return resume;
  }

  Future<void> saveResumeState(PuzzleResumeState resume) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kResume);

    Map<String, dynamic> decoded;
    if (raw == null || raw.isEmpty) {
      decoded = <String, dynamic>{};
    } else {
      final value = jsonDecode(raw);
      decoded = value is Map<String, dynamic> ? value : <String, dynamic>{};
    }

    decoded[resume.puzzleId] = resume.toJson();

    if (decoded.length > _maxResumeEntries) {
      final sorted = decoded.entries.toList()
        ..sort((a, b) {
          final aDate = _extractResumeDate(a.value);
          final bDate = _extractResumeDate(b.value);
          return bDate.compareTo(aDate);
        });
      decoded = {
        for (final entry in sorted.take(_maxResumeEntries))
          entry.key: entry.value,
      };
    }

    await prefs.setString(_kResume, jsonEncode(decoded));
  }

  Future<void> clearResumeState(String puzzleId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kResume);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;

    if (decoded.remove(puzzleId) != null) {
      await prefs.setString(_kResume, jsonEncode(decoded));
    }
  }

  Future<void> setLastOpenedPuzzle(String puzzleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastOpenedPuzzle, puzzleId);
  }

  Future<String?> getLastOpenedPuzzle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastOpenedPuzzle);
  }

  DateTime _extractResumeDate(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    final dateRaw = raw['lastSavedAt'];
    if (dateRaw is! String) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.tryParse(dateRaw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
