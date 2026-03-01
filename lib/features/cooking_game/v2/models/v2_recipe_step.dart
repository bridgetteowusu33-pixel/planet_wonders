import 'package:flutter/foundation.dart';

import 'step_type.dart';

@immutable
class V2RecipeStep {
  const V2RecipeStep({
    required this.type,
    required this.instruction,
    required this.chefLine,
    this.targetCount = 1,
    this.durationMs = 0,
    this.ingredientIds = const <String>[],
    this.factText,
  });

  /// The mini-game type for this step.
  final V2StepType type;

  /// Instruction shown to the player, e.g. "Chop the tomatoes!".
  final String instruction;

  /// Character-specific line spoken by the chef, e.g. "Afia says: Nice chop!".
  final String chefLine;

  /// Target count for discrete steps (chop taps, season shakes).
  final int targetCount;

  /// Duration hint in ms for timed steps (heat hold, simmer wait).
  final int durationMs;

  /// Which ingredient IDs this step operates on (for visual cues).
  final List<String> ingredientIds;

  /// Optional fun fact shown during this step.
  final String? factText;
}
