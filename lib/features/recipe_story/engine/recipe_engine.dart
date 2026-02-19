import '../domain/character_expression.dart';
import '../domain/recipe.dart';
import '../domain/step_reward.dart';

/// Stateless service that handles recipe story game logic.
///
/// Separated from the UI layer so logic can be tested independently.
/// The engine evaluates interactions, determines rewards, and manages
/// scene configuration without holding any mutable state.
class RecipeEngine {
  const RecipeEngine();

  // ---------------------------------------------------------------------------
  // Step evaluation
  // ---------------------------------------------------------------------------

  /// Whether a discrete action (tap/drag) completes the current step.
  bool isStepComplete({
    required RecipeStoryStep step,
    required int interactionCount,
    required double progress,
  }) {
    final action = step.action;
    if (action == RecipeActionType.tap || action == RecipeActionType.drag) {
      return interactionCount >= step.safeRequiredCount;
    }
    // Continuous actions: stir, hold, shake
    return progress >= 1.0;
  }

  /// Calculate progress fraction for a discrete action step.
  double discreteProgress({
    required int interactionCount,
    required int requiredCount,
  }) {
    if (requiredCount <= 0) return 1.0;
    return (interactionCount / requiredCount).clamp(0.0, 1.0);
  }

  /// Clamp a continuous progress delta to prevent jumps.
  double clampProgressDelta(double delta) => delta.clamp(0.0, 0.08);

  // ---------------------------------------------------------------------------
  // Rewards
  // ---------------------------------------------------------------------------

  /// Get the micro-reward for completing a step.
  StepReward rewardForStep(RecipeStoryStep step) {
    return rewardForAction(step.actionKey);
  }

  /// Calculate final star rating based on completion.
  ///
  /// All recipe stories give 3 stars on completion (kids always win),
  /// but replay count affects the display.
  int calculateStars({required int playCount}) {
    // Kids always get 3 stars. No failure states.
    return 3;
  }

  // ---------------------------------------------------------------------------
  // Character expressions
  // ---------------------------------------------------------------------------

  /// Get character expression for the current step.
  CharacterExpression expressionForStep(RecipeStoryStep step) {
    return expressionForAction(step.actionKey);
  }

  /// Get the celebration expression for recipe completion.
  CharacterExpression completionExpression(String countryId) {
    final name = characterNameForCountry(countryId);
    return CharacterExpression(
      mood: CharacterMood.celebrating,
      message: '$name says: Amazing job, chef!',
    );
  }

  // ---------------------------------------------------------------------------
  // Scene configuration
  // ---------------------------------------------------------------------------

  /// Get background gradient colors for a step action type.
  ///
  /// Each action type has a distinct warm color palette that
  /// differentiates scenes visually without requiring custom assets.
  SceneColors sceneColorsForAction(RecipeActionType action) {
    return switch (action) {
      RecipeActionType.tap => const SceneColors(
          primary: 0xFFFFF3E0, // warm cream
          secondary: 0xFFFFE0B2, // light orange
          accent: 0xFFFF9800, // orange
        ),
      RecipeActionType.drag => const SceneColors(
          primary: 0xFFE8F5E9, // light green
          secondary: 0xFFC8E6C9, // soft green
          accent: 0xFF4CAF50, // green
        ),
      RecipeActionType.stir => const SceneColors(
          primary: 0xFFE3F2FD, // light blue
          secondary: 0xFFBBDEFB, // soft blue
          accent: 0xFF2196F3, // blue
        ),
      RecipeActionType.hold => const SceneColors(
          primary: 0xFFFFF9C4, // light yellow
          secondary: 0xFFFFF176, // warm yellow
          accent: 0xFFFFC107, // amber
        ),
      RecipeActionType.shake => const SceneColors(
          primary: 0xFFFCE4EC, // light pink
          secondary: 0xFFF8BBD0, // soft pink
          accent: 0xFFE91E63, // pink
        ),
    };
  }

  /// Emoji icon representing the step's action type (for journey map).
  String journeyIconForStep(RecipeStoryStep step) {
    return switch (step.actionKey) {
      'tap_bowl' => '\u{1F35A}', // 🍚
      'tap_chop' => '\u{1F52A}', // 🔪
      'tap_spice_shaker' => '\u{1F9C2}', // 🧂
      'drag_oil_to_pot' => '\u{1FAD9}', // 🫙
      'drag_tomato_mix' => '\u{1F345}', // 🍅
      'drag_rice_to_pot' => '\u{1F35A}', // 🍚
      'stir_circle' || 'stir' => '\u{1F944}', // 🥄
      'hold_to_cook' || 'hold' || 'hold_cook' => '\u{1FA98}', // 🫘
      'shake' => '\u{1F9C2}', // 🧂
      'tap' => '\u{1F44F}', // 👏
      'drag' => '\u{1F963}', // 🥣
      _ => '\u{2B50}', // ⭐
    };
  }
}

/// Color scheme for a recipe step scene.
class SceneColors {
  const SceneColors({
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  /// Background top color (lighter).
  final int primary;

  /// Background bottom color (slightly darker).
  final int secondary;

  /// Interactive element accent color.
  final int accent;
}
