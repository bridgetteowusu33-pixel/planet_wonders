import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_break_settings.dart';

final gameBreakSettingsProvider =
    NotifierProvider<GameBreakSettingsNotifier, GameBreakSettings>(
  GameBreakSettingsNotifier.new,
);

class GameBreakSettingsNotifier extends Notifier<GameBreakSettings> {
  static const _kEnabled = 'gb_enabled';
  static const _kAfterActivities = 'gb_after_activities';
  static const _kCalm = 'gb_calm';

  @override
  GameBreakSettings build() {
    _loadFromPrefs();
    return const GameBreakSettings(); // defaults until async load completes
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = GameBreakSettings(
      enabled: prefs.getBool(_kEnabled) ?? true,
      afterActivities: prefs.getBool(_kAfterActivities) ?? true,
      calmMode: prefs.getBool(_kCalm) ?? false,
    );
  }

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, value);
  }

  Future<void> setAfterActivities(bool value) async {
    state = state.copyWith(afterActivities: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAfterActivities, value);
  }

  Future<void> setCalmMode(bool value) async {
    state = state.copyWith(calmMode: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCalm, value);
  }
}
