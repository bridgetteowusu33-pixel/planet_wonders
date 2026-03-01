/// Difficulty levels for Ingredient Rush.
enum RushDifficulty {
  easy,
  medium,
  hard;

  String get label => switch (this) {
        easy => 'Easy',
        medium => 'Medium',
        hard => 'Hard',
      };

  String get emoji => switch (this) {
        easy => '\u{2B50}', // ⭐
        medium => '\u{1F31F}', // 🌟
        hard => '\u{1F4AB}', // 💫
      };
}

/// Configuration constants per difficulty level.
class RushDifficultyConfig {
  const RushDifficultyConfig._({
    required this.spawnIntervalMs,
    required this.minSpeed,
    required this.maxSpeed,
    required this.maxOnScreen,
    required this.distractorRatio,
    required this.timerDurationSec,
  });

  /// Milliseconds between ingredient spawns.
  final int spawnIntervalMs;

  /// Minimum speed in logical-pixels per second.
  final double minSpeed;

  /// Maximum speed in logical-pixels per second.
  final double maxSpeed;

  /// Maximum simultaneous ingredients on screen.
  final int maxOnScreen;

  /// Fraction of spawns that are distractors (0.0–1.0).
  final double distractorRatio;

  /// Total timer duration in seconds.
  final int timerDurationSec;

  static const easy = RushDifficultyConfig._(
    spawnIntervalMs: 1400,
    minSpeed: 60,
    maxSpeed: 100,
    maxOnScreen: 5,
    distractorRatio: 0.25,
    timerDurationSec: 90,
  );

  static const medium = RushDifficultyConfig._(
    spawnIntervalMs: 1000,
    minSpeed: 90,
    maxSpeed: 140,
    maxOnScreen: 7,
    distractorRatio: 0.35,
    timerDurationSec: 75,
  );

  static const hard = RushDifficultyConfig._(
    spawnIntervalMs: 700,
    minSpeed: 120,
    maxSpeed: 180,
    maxOnScreen: 9,
    distractorRatio: 0.45,
    timerDurationSec: 60,
  );

  static RushDifficultyConfig forDifficulty(RushDifficulty d) => switch (d) {
        RushDifficulty.easy => easy,
        RushDifficulty.medium => medium,
        RushDifficulty.hard => hard,
      };
}
