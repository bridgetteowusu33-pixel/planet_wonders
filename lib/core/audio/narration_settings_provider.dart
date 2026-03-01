import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final narrationSettingsProvider =
    NotifierProvider<NarrationSettingsNotifier, NarrationSettings>(
  NarrationSettingsNotifier.new,
);

class NarrationSettings {
  const NarrationSettings({this.storyVoiceEnabled = true});

  /// Whether pre-generated story voice audio is enabled.
  final bool storyVoiceEnabled;

  NarrationSettings copyWith({bool? storyVoiceEnabled}) {
    return NarrationSettings(
      storyVoiceEnabled: storyVoiceEnabled ?? this.storyVoiceEnabled,
    );
  }
}

class NarrationSettingsNotifier extends Notifier<NarrationSettings> {
  static const _kStoryVoice = 'narration_story_voice';

  @override
  NarrationSettings build() {
    _loadFromPrefs();
    return const NarrationSettings();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = NarrationSettings(
      storyVoiceEnabled: prefs.getBool(_kStoryVoice) ?? true,
    );
  }

  Future<void> setStoryVoiceEnabled(bool value) async {
    state = state.copyWith(storyVoiceEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kStoryVoice, value);
  }
}
