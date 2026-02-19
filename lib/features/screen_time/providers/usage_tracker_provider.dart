import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_usage_record.dart';
import '../models/screen_time_settings.dart';
import 'screen_time_settings_provider.dart';

/// How often the tracker adds time (seconds).
const _tickIntervalSeconds = 15;

/// Persist to disk every N ticks (~1 minute).
const _persistEveryNTicks = 4;

final usageTrackerProvider =
    NotifierProvider<UsageTrackerNotifier, UsageTrackerState>(
  UsageTrackerNotifier.new,
);

class UsageTrackerState {
  const UsageTrackerState({
    this.today = const DailyUsageRecord(dateKey: ''),
    this.weekHistory = const [],
    this.isLocked = false,
    this.isBedtimeLocked = false,
    this.activeCategory = 'other',
  });

  final DailyUsageRecord today;
  final List<DailyUsageRecord> weekHistory;
  final bool isLocked;
  final bool isBedtimeLocked;
  final String activeCategory;

  UsageTrackerState copyWith({
    DailyUsageRecord? today,
    List<DailyUsageRecord>? weekHistory,
    bool? isLocked,
    bool? isBedtimeLocked,
    String? activeCategory,
  }) {
    return UsageTrackerState(
      today: today ?? this.today,
      weekHistory: weekHistory ?? this.weekHistory,
      isLocked: isLocked ?? this.isLocked,
      isBedtimeLocked: isBedtimeLocked ?? this.isBedtimeLocked,
      activeCategory: activeCategory ?? this.activeCategory,
    );
  }
}

class UsageTrackerNotifier extends Notifier<UsageTrackerState> {
  static const _kTodayKey = 'st_usage_today';
  static const _kHistoryKey = 'st_usage_history';

  Timer? _ticker;
  int _tickCount = 0;
  Future<void>? _loadTask;

  @override
  UsageTrackerState build() {
    ref.onDispose(_cancelTicker);
    _loadTask ??= _load();
    return const UsageTrackerState();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  void setActiveCategory(String category) {
    state = state.copyWith(activeCategory: category);
  }

  void onAppResumed() {
    _startTicker();
    _reevaluateLocks();
  }

  void onAppPaused() {
    _cancelTicker();
    _persistNow();
  }

  /// Temporarily unlock (after PIN verification). Resets at next tick cycle.
  void temporaryUnlock() {
    state = state.copyWith(isLocked: false, isBedtimeLocked: false);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = DailyUsageRecord.todayKey();

      // Load today
      DailyUsageRecord today;
      final todayRaw = prefs.getString(_kTodayKey);
      if (todayRaw != null && todayRaw.isNotEmpty) {
        final decoded = jsonDecode(todayRaw);
        if (decoded is Map<String, dynamic>) {
          final record = DailyUsageRecord.fromJson(decoded);
          // If stored record is from a different day, archive it and start fresh
          today = record.dateKey == todayKey
              ? record
              : DailyUsageRecord(dateKey: todayKey);
        } else {
          today = DailyUsageRecord(dateKey: todayKey);
        }
      } else {
        today = DailyUsageRecord(dateKey: todayKey);
      }

      // Load week history
      final historyRaw = prefs.getString(_kHistoryKey);
      final history = historyRaw != null && historyRaw.isNotEmpty
          ? DailyUsageRecord.decodeList(historyRaw)
          : <DailyUsageRecord>[];

      state = state.copyWith(today: today, weekHistory: history);
      _reevaluateLocks();
      _startTicker();
    } catch (e) {
      if (kDebugMode) debugPrint('UsageTracker load error: $e');
      _startTicker();
    }
  }

  void _startTicker() {
    _cancelTicker();
    _ticker = Timer.periodic(
      const Duration(seconds: _tickIntervalSeconds),
      (_) => _tick(),
    );
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    _tickCount++;

    // Roll over to new day if needed
    final todayKey = DailyUsageRecord.todayKey();
    DailyUsageRecord today = state.today;
    if (today.dateKey != todayKey) {
      _archiveDay(today);
      today = DailyUsageRecord(dateKey: todayKey);
    }

    // Add seconds to active category
    final updatedSeconds =
        today.seconds.addSeconds(state.activeCategory, _tickIntervalSeconds);
    today = DailyUsageRecord(dateKey: today.dateKey, seconds: updatedSeconds);

    state = state.copyWith(today: today);
    _reevaluateLocks();

    // Persist periodically
    if (_tickCount % _persistEveryNTicks == 0) {
      _persistNow();
    }
  }

  void _reevaluateLocks() {
    final settings = ref.read(screenTimeSettingsProvider);

    // Daily limit lock
    final isLocked = settings.hasLimit &&
        state.today.totalMinutes >= settings.dailyLimitMinutes;

    // Bedtime lock
    final isBedtimeLocked =
        settings.bedtimeLockEnabled && _isInBedtimeWindow(settings);

    if (isLocked != state.isLocked ||
        isBedtimeLocked != state.isBedtimeLocked) {
      state = state.copyWith(
        isLocked: isLocked,
        isBedtimeLocked: isBedtimeLocked,
      );
    }
  }

  bool _isInBedtimeWindow(ScreenTimeSettings settings) {
    final now = DateTime.now();
    final startMinutes = settings.bedtimeLockStartHour * 60;
    final endMinutes = settings.bedtimeLockEndHour * 60;
    final nowMinutes = now.hour * 60 + now.minute;

    if (startMinutes < endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } else {
      // Crosses midnight
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }
  }

  void _archiveDay(DailyUsageRecord day) {
    if (day.dateKey.isEmpty || day.totalMinutes == 0) return;
    final history = [day, ...state.weekHistory];
    // Keep only 7 days
    final trimmed = history.length > 7 ? history.sublist(0, 7) : history;
    state = state.copyWith(weekHistory: trimmed);
    _persistHistory();
  }

  Future<void> _persistNow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kTodayKey,
        jsonEncode(state.today.toJson()),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('UsageTracker persist error: $e');
    }
  }

  Future<void> _persistHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kHistoryKey,
        DailyUsageRecord.encodeList(state.weekHistory),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('UsageTracker history persist error: $e');
    }
  }
}
