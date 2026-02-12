/// Parent-configurable settings for Game Breaks.
class GameBreakSettings {
  const GameBreakSettings({
    this.enabled = true,
    this.afterActivities = true,
    this.calmMode = false,
  });

  /// Master ON/OFF toggle.
  final bool enabled;

  /// Whether to prompt after completing coloring / stories.
  final bool afterActivities;

  /// Calm mode: fewer prompts, slower animations.
  final bool calmMode;

  GameBreakSettings copyWith({
    bool? enabled,
    bool? afterActivities,
    bool? calmMode,
  }) {
    return GameBreakSettings(
      enabled: enabled ?? this.enabled,
      afterActivities: afterActivities ?? this.afterActivities,
      calmMode: calmMode ?? this.calmMode,
    );
  }
}
