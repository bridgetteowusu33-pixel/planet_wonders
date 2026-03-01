import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/v2_scorer.dart';
import '../models/pot_face_state.dart';
import '../models/step_type.dart';
import '../models/v2_recipe.dart';
import '../models/v2_recipe_step.dart';
import 'v2_cooking_state.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final v2CookingControllerProvider =
    NotifierProvider.autoDispose<V2CookingController, V2CookingState>(
  V2CookingController.new,
);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class V2CookingController extends Notifier<V2CookingState> {
  final math.Random _rng = math.Random();
  DateTime _startedAt = DateTime.now();

  @override
  V2CookingState build() => const V2CookingState.initial();

  // ---- Lifecycle ----------------------------------------------------------

  void startRecipe(V2Recipe recipe) {
    _startedAt = DateTime.now();
    final firstStep = recipe.steps.isNotEmpty ? recipe.steps[0] : null;
    state = V2CookingState(
      phase: V2Phase.playing,
      stepIndex: 0,
      chefLine: firstStep?.chefLine ?? '${recipe.characterName} says: Let\u{2019}s cook!',
      potFace: _potFaceForStepType(firstStep?.type),
    );
  }

  void restart() {
    state = const V2CookingState.initial();
  }

  // ---- Queries ------------------------------------------------------------

  V2RecipeStep? currentStep(V2Recipe recipe) {
    if (state.stepIndex < 0 || state.stepIndex >= recipe.steps.length) {
      return null;
    }
    return recipe.steps[state.stepIndex];
  }

  // ---- Actions: Add Ingredients -------------------------------------------

  void addIngredient(V2Recipe recipe, String ingredientId) {
    final step = currentStep(recipe);
    if (step == null || step.type != V2StepType.addIngredients) return;

    if (state.addedIngredientIds.contains(ingredientId)) {
      _registerMistake(recipe);
      return;
    }

    final updated = {...state.addedIngredientIds, ingredientId};
    final progress = updated.length / recipe.ingredients.length;

    state = state.copyWith(
      addedIngredientIds: updated,
      stepProgress: progress.clamp(0.0, 1.0),
      combo: state.combo + 1,
      maxCombo: math.max(state.maxCombo, state.combo + 1),
      potFace: PotFaceState.surprised,
      chefLine: _pick(<String>[
        'Yum! In it goes!',
        '${recipe.characterName} says: Nice pick!',
        'Perfect! Keep going!',
      ]),
    );

    if (progress >= 1.0) {
      _advanceStep(recipe);
    }
  }

  // ---- Actions: Discrete (chop, season, plate) ----------------------------

  void completeTapAction(V2Recipe recipe) {
    final step = currentStep(recipe);
    if (step == null) return;

    final allowed = <V2StepType>{V2StepType.chop, V2StepType.season, V2StepType.plate};
    if (!allowed.contains(step.type)) return;

    final required = step.targetCount;
    final nextCount = (state.interactionCount + 1).clamp(0, required);
    final progress = nextCount / required;

    state = state.copyWith(
      interactionCount: nextCount,
      stepProgress: progress.clamp(0.0, 1.0),
      combo: state.combo + 1,
      maxCombo: math.max(state.maxCombo, state.combo + 1),
      potFace: _potFaceForTap(step.type),
      chefLine: step.chefLine,
    );

    if (nextCount >= required) {
      _advanceStep(recipe);
    }
  }

  // ---- Actions: Continuous (stir, heat, simmer) ---------------------------

  void addProgress(V2Recipe recipe, {required double delta}) {
    final step = currentStep(recipe);
    if (step == null) return;

    if (!step.type.isHeat &&
        step.type != V2StepType.stir &&
        step.type != V2StepType.simmer) {
      return;
    }

    final clamped = delta.clamp(0.0, 0.1);
    final nextProgress = (state.stepProgress + clamped).clamp(0.0, 1.0);

    state = state.copyWith(
      stepProgress: nextProgress,
      potFace: _potFaceForStepType(step.type),
    );

    if (nextProgress >= 1.0) {
      _advanceStep(recipe);
    }
  }

  // ---- Actions: Mistake ---------------------------------------------------

  void registerMistake(V2Recipe recipe) {
    _registerMistake(recipe);
  }

  // ---- Internal -----------------------------------------------------------

  void _advanceStep(V2Recipe recipe) {
    final nextIndex = state.stepIndex + 1;

    if (nextIndex >= recipe.steps.length) {
      _completeRecipe(recipe);
      return;
    }

    final nextStep = recipe.steps[nextIndex];
    state = state.copyWith(
      stepIndex: nextIndex,
      stepProgress: 0,
      interactionCount: 0,
      addedIngredientIds: const <String>{},
      potFace: _potFaceForStepType(nextStep.type),
      chefLine: nextStep.chefLine,
    );
  }

  void _completeRecipe(V2Recipe recipe) {
    final elapsed = DateTime.now().difference(_startedAt);
    final totalPoints = V2Scorer.scoreStep(
          type: V2StepType.stir, // aggregate step type placeholder
          mistakes: state.mistakes,
          elapsed: elapsed,
        ) *
        recipe.steps.length;
    final maxPoints = 100 * recipe.steps.length;
    final bonus = V2Scorer.comboBonus(state.maxCombo);
    final stars = V2Scorer.calculateStars(
      totalPoints: totalPoints + bonus,
      maxPossiblePoints: maxPoints,
    );

    state = state.copyWith(
      phase: V2Phase.dishReveal,
      completed: true,
      stars: stars,
      potFace: PotFaceState.party,
      chefLine: _pick(<String>[
        'You\u{2019}re a ${recipe.name} Master!',
        '${recipe.characterName} gives you a gold star!',
        'Amazing cooking, little chef!',
      ]),
    );
  }

  void _registerMistake(V2Recipe recipe) {
    state = state.copyWith(
      mistakes: state.mistakes + 1,
      combo: 0,
      potFace: PotFaceState.worried,
      chefLine: _pick(<String>[
        'Oops! Try again \u{2014} you\u{2019}ve got this!',
        'Not quite! Keep going!',
        '${recipe.characterName} says: Almost!',
      ]),
    );
  }

  PotFaceState _potFaceForStepType(V2StepType? type) {
    if (type == null) return PotFaceState.idle;
    if (type.isHeat) return PotFaceState.yum;
    return switch (type) {
      V2StepType.addIngredients => PotFaceState.idle,
      V2StepType.chop => PotFaceState.happy,
      V2StepType.stir => PotFaceState.stir,
      V2StepType.season => PotFaceState.spicy,
      V2StepType.simmer => PotFaceState.delicious,
      V2StepType.plate => PotFaceState.love,
      _ => PotFaceState.idle,
    };
  }

  PotFaceState _potFaceForTap(V2StepType type) {
    return switch (type) {
      V2StepType.chop => PotFaceState.surprised,
      V2StepType.season => PotFaceState.spicy,
      V2StepType.plate => PotFaceState.love,
      _ => PotFaceState.happy,
    };
  }

  String _pick(List<String> options) => options[_rng.nextInt(options.length)];
}
