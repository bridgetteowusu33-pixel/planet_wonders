import 'package:flutter/foundation.dart';

import '../models/pot_face_state.dart';

/// Phases of the V2 cooking experience.
enum V2Phase { intro, playing, dishReveal, complete }

@immutable
class V2CookingState {
  const V2CookingState({
    this.phase = V2Phase.intro,
    this.stepIndex = 0,
    this.stepProgress = 0.0,
    this.interactionCount = 0,
    this.addedIngredientIds = const <String>{},
    this.mistakes = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.stars = 0,
    this.completed = false,
    this.potFace = PotFaceState.idle,
    this.chefLine = '',
  });

  const V2CookingState.initial() : this();

  final V2Phase phase;
  final int stepIndex;
  final double stepProgress;
  final int interactionCount;
  final Set<String> addedIngredientIds;
  final int mistakes;
  final int combo;
  final int maxCombo;
  final int stars;
  final bool completed;
  final PotFaceState potFace;
  final String chefLine;

  V2CookingState copyWith({
    V2Phase? phase,
    int? stepIndex,
    double? stepProgress,
    int? interactionCount,
    Set<String>? addedIngredientIds,
    int? mistakes,
    int? combo,
    int? maxCombo,
    int? stars,
    bool? completed,
    PotFaceState? potFace,
    String? chefLine,
  }) {
    return V2CookingState(
      phase: phase ?? this.phase,
      stepIndex: stepIndex ?? this.stepIndex,
      stepProgress: stepProgress ?? this.stepProgress,
      interactionCount: interactionCount ?? this.interactionCount,
      addedIngredientIds: addedIngredientIds ?? this.addedIngredientIds,
      mistakes: mistakes ?? this.mistakes,
      combo: combo ?? this.combo,
      maxCombo: maxCombo ?? this.maxCombo,
      stars: stars ?? this.stars,
      completed: completed ?? this.completed,
      potFace: potFace ?? this.potFace,
      chefLine: chefLine ?? this.chefLine,
    );
  }
}
