import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/character_expression.dart';
import '../domain/recipe.dart';
import '../domain/step_reward.dart';
import '../engine/audio_manager.dart';
import '../engine/recipe_engine.dart';

final recipeStoryControllerProvider =
    NotifierProvider.autoDispose<RecipeStoryController, RecipeStoryState>(
  RecipeStoryController.new,
);

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class RecipeStoryState {
  const RecipeStoryState({
    required this.started,
    required this.stepIndex,
    required this.interactionCount,
    required this.stepProgress,
    required this.completed,
    this.earnedRewards = const [],
    this.lastReward,
    this.showingReward = false,
    this.expression,
  });

  const RecipeStoryState.initial()
      : started = false,
        stepIndex = 0,
        interactionCount = 0,
        stepProgress = 0,
        completed = false,
        earnedRewards = const [],
        lastReward = null,
        showingReward = false,
        expression = null;

  final bool started;
  final int stepIndex;
  final int interactionCount;
  final double stepProgress;
  final bool completed;

  /// All micro-rewards earned during this playthrough.
  final List<StepReward> earnedRewards;

  /// The reward earned on the most recently completed step (for popup).
  final StepReward? lastReward;

  /// Whether the reward popup is currently being shown.
  final bool showingReward;

  /// Current character expression for the story hero header.
  final CharacterExpression? expression;

  RecipeStoryState copyWith({
    bool? started,
    int? stepIndex,
    int? interactionCount,
    double? stepProgress,
    bool? completed,
    List<StepReward>? earnedRewards,
    StepReward? lastReward,
    bool? showingReward,
    CharacterExpression? expression,
    bool clearLastReward = false,
  }) {
    return RecipeStoryState(
      started: started ?? this.started,
      stepIndex: stepIndex ?? this.stepIndex,
      interactionCount: interactionCount ?? this.interactionCount,
      stepProgress: stepProgress ?? this.stepProgress,
      completed: completed ?? this.completed,
      earnedRewards: earnedRewards ?? this.earnedRewards,
      lastReward: clearLastReward ? null : (lastReward ?? this.lastReward),
      showingReward: showingReward ?? this.showingReward,
      expression: expression ?? this.expression,
    );
  }
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class RecipeStoryController extends Notifier<RecipeStoryState> {
  static const _engine = RecipeEngine();
  final _audio = RecipeAudioManager.instance;

  @override
  RecipeStoryState build() => const RecipeStoryState.initial();

  /// Begin the recipe story from the intro screen.
  void startStory(RecipeStory recipe) {
    final firstStep = recipe.steps.isNotEmpty ? recipe.steps[0] : null;
    state = RecipeStoryState(
      started: true,
      stepIndex: 0,
      interactionCount: 0,
      stepProgress: 0,
      completed: false,
      earnedRewards: const [],
      expression:
          firstStep != null ? _engine.expressionForStep(firstStep) : null,
    );
  }

  /// Reset to the intro screen.
  void restart() {
    state = const RecipeStoryState.initial();
  }

  /// Dismiss the reward popup after it has been shown.
  void dismissReward() {
    state = state.copyWith(
      showingReward: false,
      clearLastReward: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Discrete actions (tap / drag)
  // ---------------------------------------------------------------------------

  void completeTapAction(RecipeStory recipe) {
    _registerDiscreteAction(recipe, RecipeActionType.tap);
  }

  void completeDragAction(RecipeStory recipe) {
    _registerDiscreteAction(recipe, RecipeActionType.drag);
  }

  // ---------------------------------------------------------------------------
  // Continuous actions (stir / hold / shake)
  // ---------------------------------------------------------------------------

  void addProgress(
    RecipeStory recipe, {
    required double delta,
    required Set<RecipeActionType> actions,
  }) {
    if (!state.started || state.completed) return;

    final expected = _currentAction(recipe);
    if (expected == null || !actions.contains(expected)) return;

    final clampedDelta = _engine.clampProgressDelta(delta);
    final nextProgress = (state.stepProgress + clampedDelta).clamp(0.0, 1.0);
    state = state.copyWith(stepProgress: nextProgress, interactionCount: 0);

    if (nextProgress >= 1.0) {
      _advanceStep(recipe);
    }
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  RecipeStoryStep? currentStep(RecipeStory recipe) {
    if (state.stepIndex < 0 || state.stepIndex >= recipe.steps.length) {
      return null;
    }
    return recipe.steps[state.stepIndex];
  }

  RecipeActionType? currentAction(RecipeStory recipe) =>
      currentStep(recipe)?.action;

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  RecipeActionType? _currentAction(RecipeStory recipe) =>
      currentStep(recipe)?.action;

  bool _isExpectedAction(RecipeStory recipe, RecipeActionType action) {
    if (!state.started || state.completed) return false;
    return _currentAction(recipe) == action;
  }

  void _registerDiscreteAction(RecipeStory recipe, RecipeActionType action) {
    if (!_isExpectedAction(recipe, action)) return;
    final step = currentStep(recipe);
    if (step == null) return;

    _audio.playSfx(step.sfx ?? 'tap');

    final required = step.safeRequiredCount;
    final nextCount = (state.interactionCount + 1).clamp(0, required);
    final progress = _engine.discreteProgress(
      interactionCount: nextCount,
      requiredCount: required,
    );
    state = state.copyWith(
      interactionCount: nextCount,
      stepProgress: progress,
    );

    if (nextCount >= required) {
      _advanceStep(recipe);
    }
  }

  void _advanceStep(RecipeStory recipe) {
    // Grant micro-reward for the completed step.
    final completedStep = currentStep(recipe);
    StepReward? reward;
    List<StepReward> updatedRewards = [...state.earnedRewards];

    if (completedStep != null) {
      reward = _engine.rewardForStep(completedStep);
      updatedRewards = [...updatedRewards, reward];
      _audio.playSfx('ding');
    }

    final nextIndex = state.stepIndex + 1;

    if (nextIndex >= recipe.steps.length) {
      // Recipe complete!
      _audio.playSfx('fanfare');
      state = state.copyWith(
        stepIndex: recipe.steps.length,
        interactionCount: 0,
        stepProgress: 1,
        completed: true,
        earnedRewards: updatedRewards,
        lastReward: reward,
        showingReward: reward != null,
        expression: _engine.completionExpression(recipe.country),
      );
      return;
    }

    // Advance to next step.
    final nextStep = recipe.steps[nextIndex];
    state = state.copyWith(
      stepIndex: nextIndex,
      interactionCount: 0,
      stepProgress: 0,
      completed: false,
      earnedRewards: updatedRewards,
      lastReward: reward,
      showingReward: reward != null,
      expression: _engine.expressionForStep(nextStep),
    );
  }
}
