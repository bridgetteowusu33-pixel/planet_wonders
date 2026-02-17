import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/recipe.dart';

final recipeStoryControllerProvider =
    NotifierProvider.autoDispose<RecipeStoryController, RecipeStoryState>(
  RecipeStoryController.new,
);

class RecipeStoryState {
  const RecipeStoryState({
    required this.started,
    required this.stepIndex,
    required this.interactionCount,
    required this.stepProgress,
    required this.completed,
  });

  const RecipeStoryState.initial()
      : started = false,
        stepIndex = 0,
        interactionCount = 0,
        stepProgress = 0,
        completed = false;

  final bool started;
  final int stepIndex;
  final int interactionCount;
  final double stepProgress;
  final bool completed;

  RecipeStoryState copyWith({
    bool? started,
    int? stepIndex,
    int? interactionCount,
    double? stepProgress,
    bool? completed,
  }) {
    return RecipeStoryState(
      started: started ?? this.started,
      stepIndex: stepIndex ?? this.stepIndex,
      interactionCount: interactionCount ?? this.interactionCount,
      stepProgress: stepProgress ?? this.stepProgress,
      completed: completed ?? this.completed,
    );
  }
}

class RecipeStoryController extends Notifier<RecipeStoryState> {
  @override
  RecipeStoryState build() => const RecipeStoryState.initial();

  void startStory() {
    state = const RecipeStoryState(
      started: true,
      stepIndex: 0,
      interactionCount: 0,
      stepProgress: 0,
      completed: false,
    );
  }

  void restart() {
    state = const RecipeStoryState.initial();
  }

  void completeTapAction(RecipeStory recipe) {
    _registerDiscreteAction(recipe, RecipeActionType.tap);
  }

  void completeDragAction(RecipeStory recipe) {
    _registerDiscreteAction(recipe, RecipeActionType.drag);
  }

  void addProgress(
    RecipeStory recipe, {
    required double delta,
    required Set<RecipeActionType> actions,
  }) {
    if (!state.started || state.completed) return;

    final expected = currentAction(recipe);
    if (expected == null || !actions.contains(expected)) {
      return;
    }

    final nextProgress = (state.stepProgress + delta).clamp(0.0, 1.0);
    state = state.copyWith(stepProgress: nextProgress, interactionCount: 0);

    if (nextProgress >= 1.0) {
      _advanceStep(recipe);
    }
  }

  RecipeStoryStep? currentStep(RecipeStory recipe) {
    if (state.stepIndex < 0 || state.stepIndex >= recipe.steps.length) {
      return null;
    }
    return recipe.steps[state.stepIndex];
  }

  RecipeActionType? currentAction(RecipeStory recipe) {
    return currentStep(recipe)?.action;
  }

  bool _isExpectedAction(RecipeStory recipe, RecipeActionType action) {
    if (!state.started || state.completed) return false;
    return currentAction(recipe) == action;
  }

  void _registerDiscreteAction(RecipeStory recipe, RecipeActionType action) {
    if (!_isExpectedAction(recipe, action)) return;
    final step = currentStep(recipe);
    if (step == null) return;

    final required = step.safeRequiredCount;
    final nextCount = (state.interactionCount + 1).clamp(0, required);
    final progress = (nextCount / required).clamp(0.0, 1.0);
    state = state.copyWith(
      interactionCount: nextCount,
      stepProgress: progress,
    );

    if (nextCount >= required) {
      _advanceStep(recipe);
    }
  }

  void _advanceStep(RecipeStory recipe) {
    final nextIndex = state.stepIndex + 1;
    if (nextIndex >= recipe.steps.length) {
      state = state.copyWith(
        stepIndex: recipe.steps.length,
        interactionCount: 0,
        stepProgress: 1,
        completed: true,
      );
      return;
    }

    state = state.copyWith(
      stepIndex: nextIndex,
      interactionCount: 0,
      stepProgress: 0,
      completed: false,
    );
  }
}
