/// Difficulty levels for Pack the Suitcase.
enum PackDifficulty {
  easy,
  medium,
  hard;

  String get label => switch (this) {
        easy => 'Easy',
        medium => 'Medium',
        hard => 'Hard',
      };

  String get emoji => switch (this) {
        easy => '\u{2B50}',
        medium => '\u{1F31F}',
        hard => '\u{1F4AB}',
      };
}

/// Per-difficulty configuration (timer behaviour).
class PackDifficultyConfig {
  const PackDifficultyConfig._({
    required this.hasTimer,
    required this.timerDurationSec,
  });

  final bool hasTimer;
  final int timerDurationSec;

  static const easy = PackDifficultyConfig._(
    hasTimer: false,
    timerDurationSec: 0,
  );

  static const medium = PackDifficultyConfig._(
    hasTimer: true,
    timerDurationSec: 90,
  );

  static const hard = PackDifficultyConfig._(
    hasTimer: true,
    timerDurationSec: 60,
  );

  static PackDifficultyConfig forDifficulty(PackDifficulty d) => switch (d) {
        PackDifficulty.easy => easy,
        PackDifficulty.medium => medium,
        PackDifficulty.hard => hard,
      };
}
