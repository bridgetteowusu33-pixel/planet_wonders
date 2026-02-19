import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Theme mode enum
// ---------------------------------------------------------------------------

enum ThemeModeType { light, dark, system }

// ---------------------------------------------------------------------------
// Theme provider — user's chosen theme (Light / Dark / System).
// ---------------------------------------------------------------------------

final themeProvider = NotifierProvider<ThemeNotifier, ThemeModeType>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeModeType> {
  static const _key = 'planet_wonders_theme';

  @override
  ThemeModeType build() {
    _loadFromPrefs();
    return ThemeModeType.light;
  }

  Future<void> setLight() async {
    state = ThemeModeType.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'light');
  }

  Future<void> setDark() async {
    state = ThemeModeType.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'dark');
  }

  Future<void> setSystem() async {
    state = ThemeModeType.system;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'system');
  }

  static ThemeMode toFlutterMode(ThemeModeType mode) => switch (mode) {
    ThemeModeType.light => ThemeMode.light,
    ThemeModeType.dark => ThemeMode.dark,
    ThemeModeType.system => ThemeMode.system,
  };

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    state = switch (raw) {
      'dark' => ThemeModeType.dark,
      'system' => ThemeModeType.system,
      _ => ThemeModeType.light,
    };
  }
}

// ---------------------------------------------------------------------------
// Bedtime mode state
// ---------------------------------------------------------------------------

class BedtimeState {
  const BedtimeState({
    this.enabled = false,
    this.startHour = 20,
    this.startMinute = 0,
    this.endHour = 7,
    this.endMinute = 0,
    this.isActive = false,
  });

  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  /// Whether we are currently inside the bedtime window.
  final bool isActive;

  TimeOfDay get startTime => TimeOfDay(hour: startHour, minute: startMinute);
  TimeOfDay get endTime => TimeOfDay(hour: endHour, minute: endMinute);

  BedtimeState copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    bool? isActive,
  }) {
    return BedtimeState(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      isActive: isActive ?? this.isActive,
    );
  }
}

// ---------------------------------------------------------------------------
// Bedtime provider
// ---------------------------------------------------------------------------

final bedtimeProvider = NotifierProvider<BedtimeNotifier, BedtimeState>(
  BedtimeNotifier.new,
);

class BedtimeNotifier extends Notifier<BedtimeState> {
  static const _enabledKey = 'planet_wonders_bedtime_mode_enabled';

  Timer? _boundaryTimer;

  @override
  BedtimeState build() {
    ref.onDispose(_cancelTimer);
    _loadFromPrefs();
    return const BedtimeState();
  }

  // ── Public API ──

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    _reevaluate();
  }

  /// Call when app resumes (AppLifecycleState.resumed) to refresh.
  void onAppResumed() => _reevaluate();

  // ── Internals ──

  void _reevaluate() {
    _cancelTimer();
    if (!state.enabled) {
      if (state.isActive) state = state.copyWith(isActive: false);
      return;
    }

    final now = DateTime.now();
    final inWindow = _isInBedtimeWindow(now);
    state = state.copyWith(isActive: inWindow);

    // Schedule timer for next boundary crossing.
    final nextBoundary = _nextBoundary(now, inWindow);
    if (nextBoundary != null) {
      final delay = nextBoundary.difference(now);
      if (delay.isNegative || delay == Duration.zero) {
        // Edge case: already at boundary, re-check in 1 second.
        _boundaryTimer = Timer(const Duration(seconds: 1), _reevaluate);
      } else {
        // Add 1 second buffer so we're solidly past the boundary.
        _boundaryTimer = Timer(delay + const Duration(seconds: 1), _reevaluate);
      }
    }
  }

  bool _isInBedtimeWindow(DateTime now) {
    final startMinutes = state.startHour * 60 + state.startMinute;
    final endMinutes = state.endHour * 60 + state.endMinute;
    final nowMinutes = now.hour * 60 + now.minute;

    if (startMinutes < endMinutes) {
      // Same-day window (e.g. 14:00 → 18:00)
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } else {
      // Crosses midnight (e.g. 20:00 → 07:00)
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }
  }

  /// Returns the next DateTime when the window starts or ends.
  DateTime? _nextBoundary(DateTime now, bool currentlyInWindow) {
    final targetHour = currentlyInWindow ? state.endHour : state.startHour;
    final targetMinute = currentlyInWindow ? state.endMinute : state.startMinute;

    var next = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  void _cancelTimer() {
    _boundaryTimer?.cancel();
    _boundaryTimer = null;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? false;
    state = state.copyWith(enabled: enabled);
    _reevaluate();
  }
}

// ---------------------------------------------------------------------------
// Effective theme mode — combines user choice + bedtime override.
//
// This is what MaterialApp should use.
// ---------------------------------------------------------------------------

final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final userChoice = ref.watch(themeProvider);
  final bedtime = ref.watch(bedtimeProvider);

  // If user chose Dark, bedtime is irrelevant — already dark.
  if (userChoice == ThemeModeType.dark) return ThemeMode.dark;

  // If bedtime is active, force dark.
  if (bedtime.enabled && bedtime.isActive) return ThemeMode.dark;

  // Otherwise, use the user's chosen mode.
  return ThemeNotifier.toFlutterMode(userChoice);
});
