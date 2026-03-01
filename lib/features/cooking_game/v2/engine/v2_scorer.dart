import '../models/step_type.dart';

/// Scoring engine for V2 cooking recipes.
class V2Scorer {
  const V2Scorer._();

  /// Points awarded per step based on mistakes and speed.
  ///
  /// Max 100 points per step. Deductions for mistakes and slow completion.
  static int scoreStep({
    required V2StepType type,
    required int mistakes,
    required Duration elapsed,
  }) {
    var points = 100;

    // Deduct for mistakes.
    points -= mistakes * 15;

    // Deduct for slow completion (generous thresholds for kids).
    final seconds = elapsed.inSeconds;
    final threshold = _timeThreshold(type);
    if (seconds > threshold * 2) {
      points -= 20;
    } else if (seconds > threshold) {
      points -= 10;
    }

    return points.clamp(10, 100);
  }

  /// Convert total points across all steps to 1-3 stars.
  static int calculateStars({
    required int totalPoints,
    required int maxPossiblePoints,
  }) {
    if (maxPossiblePoints <= 0) return 1;

    final ratio = totalPoints / maxPossiblePoints;
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.6) return 2;
    return 1;
  }

  /// Combo bonus: consecutive perfect steps earn extra points.
  static int comboBonus(int maxCombo) {
    if (maxCombo >= 7) return 50;
    if (maxCombo >= 5) return 30;
    if (maxCombo >= 3) return 15;
    return 0;
  }

  /// Generous per-step time thresholds in seconds (kid-friendly).
  static int _timeThreshold(V2StepType type) {
    if (type.isHeat) return 15;
    return switch (type) {
      V2StepType.addIngredients => 30,
      V2StepType.chop => 15,
      V2StepType.stir => 20,
      V2StepType.season => 10,
      V2StepType.simmer => 25,
      V2StepType.plate => 15,
      _ => 15,
    };
  }
}
