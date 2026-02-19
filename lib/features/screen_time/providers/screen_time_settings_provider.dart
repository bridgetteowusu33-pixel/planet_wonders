import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/screen_time_settings.dart';

final screenTimeSettingsProvider =
    NotifierProvider<ScreenTimeSettingsNotifier, ScreenTimeSettings>(
  ScreenTimeSettingsNotifier.new,
);

class ScreenTimeSettingsNotifier extends Notifier<ScreenTimeSettings> {
  static const _kLimit = 'st_daily_limit_minutes';
  static const _kBedtimeEnabled = 'st_bedtime_lock_enabled';
  static const _kBedtimeStart = 'st_bedtime_lock_start_hour';
  static const _kBedtimeEnd = 'st_bedtime_lock_end_hour';
  static const _kPinHash = 'st_pin_hash';

  @override
  ScreenTimeSettings build() {
    _loadFromPrefs();
    return const ScreenTimeSettings();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = ScreenTimeSettings(
      dailyLimitMinutes: prefs.getInt(_kLimit) ?? 60,
      bedtimeLockEnabled: prefs.getBool(_kBedtimeEnabled) ?? false,
      bedtimeLockStartHour: prefs.getInt(_kBedtimeStart) ?? 20,
      bedtimeLockEndHour: prefs.getInt(_kBedtimeEnd) ?? 7,
      pinHash: prefs.getString(_kPinHash),
    );
  }

  Future<void> setDailyLimit(int minutes) async {
    state = state.copyWith(dailyLimitMinutes: minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLimit, minutes);
  }

  Future<void> setBedtimeLockEnabled(bool enabled) async {
    state = state.copyWith(bedtimeLockEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBedtimeEnabled, enabled);
  }

  Future<void> setBedtimeLockHours({
    required int startHour,
    required int endHour,
  }) async {
    state = state.copyWith(
      bedtimeLockStartHour: startHour,
      bedtimeLockEndHour: endHour,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBedtimeStart, startHour);
    await prefs.setInt(_kBedtimeEnd, endHour);
  }

  Future<void> setPin(String pin) async {
    final hash = ScreenTimeSettings.hashPin(pin);
    state = state.copyWith(pinHash: () => hash);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPinHash, hash);
  }

  Future<void> clearPin() async {
    state = state.copyWith(pinHash: () => null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPinHash);
  }

  bool verifyPin(String pin) {
    if (!state.hasPin) return true;
    return ScreenTimeSettings.hashPin(pin) == state.pinHash;
  }
}
