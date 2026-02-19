import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../achievements/providers/achievement_provider.dart';
import '../../world_explorer/data/world_data.dart';
import '../models/learning_stats.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final learningStatsProvider =
    NotifierProvider<LearningStatsNotifier, LearningStats>(
      LearningStatsNotifier.new,
    );

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class LearningStatsNotifier extends Notifier<LearningStats> {
  static const String _kActivityLog = 'lr_activity_log';
  static const int _maxEntries = 200;

  List<ActivityLogEntry> _allEntries = [];
  Future<void>? _loadingTask;

  @override
  LearningStats build() {
    _loadingTask ??= _load();
    return const LearningStats();
  }

  /// Log a new activity completion.
  Future<void> logActivity(ActivityLogEntry entry) async {
    await _waitForLoad();
    _allEntries = [entry, ..._allEntries];
    if (_allEntries.length > _maxEntries) {
      _allEntries = _allEntries.sublist(0, _maxEntries);
    }
    await _persist();
    _recompute();
  }

  /// Recompute stats (called when data changes or on initial load).
  void _recompute() {
    final entries = _allEntries;

    // Skill points
    final points = <SkillType, int>{};
    for (final entry in entries) {
      for (final kv in skillPointsFor(entry.type).entries) {
        points[kv.key] = (points[kv.key] ?? 0) + kv.value;
      }
    }

    // Normalise: max possible = total activities * 2 (each activity gives ~2 points)
    // Use a reasonable ceiling so bars aren't always tiny.
    final maxPoints = (entries.length * 2).clamp(1, 1 << 30);
    final skills = SkillType.values.map((type) {
      final raw = (points[type] ?? 0) / maxPoints;
      return buildSkillScore(type, raw);
    }).toList(growable: false);

    // Countries explored (from world data)
    final countriesExplored = worldContinents
        .expand((c) => c.countries)
        .where((c) => c.isUnlocked)
        .length;

    // Badges (from achievement provider, if loaded)
    final achievementState = ref.read(achievementProvider);
    final badgesEarned = achievementState.unlockedCount;

    state = LearningStats(
      activitiesCompleted: entries.length,
      countriesExplored: countriesExplored,
      badgesEarned: badgesEarned,
      skills: skills,
      recentActivities: entries,
      loading: false,
    );
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kActivityLog);
      if (raw != null && raw.isNotEmpty) {
        _allEntries = ActivityLogEntry.decodeList(raw);
      }
      _recompute();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('LearningStats load failed: $error');
        debugPrint('$stackTrace');
      }
      state = state.copyWith(loading: false);
    }
  }

  Future<void> _waitForLoad() async {
    _loadingTask ??= _load();
    await _loadingTask;
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kActivityLog,
        ActivityLogEntry.encodeList(_allEntries),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('LearningStats persist failed: $error');
      }
    }
  }
}
