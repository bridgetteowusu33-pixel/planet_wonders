import 'package:flutter/material.dart';

import '../../domain/recipe.dart';
import '../../engine/recipe_engine.dart';
import '../widgets/scene_background.dart';
import 'tap_scene.dart';
import 'drag_scene.dart';
import 'stir_scene.dart';
import 'hold_scene.dart';
import 'shake_scene.dart';

/// Base class for recipe step scenes.
///
/// Each scene type provides:
/// 1. A themed background gradient (via [SceneBackground])
/// 2. An interactive area for the player
/// 3. Visual props (emoji-based, designed for future asset swap)
/// 4. Progress feedback
///
/// The [StepScene.forStep] factory selects the concrete scene based
/// on the step's action type, ensuring the correct interaction
/// handler is used.
abstract class StepScene extends StatelessWidget {
  const StepScene({
    super.key,
    required this.step,
    required this.progress,
    required this.interactionCount,
  });

  final RecipeStoryStep step;
  final double progress;
  final int interactionCount;

  /// Factory that returns the correct scene widget for a step.
  static Widget forStep({
    Key? key,
    required RecipeStoryStep step,
    required double progress,
    required int interactionCount,
    required VoidCallback onTapAction,
    required VoidCallback onDragAccepted,
    required ValueChanged<double> onProgressDelta,
  }) {
    return switch (step.action) {
      RecipeActionType.tap => TapScene(
          key: key,
          step: step,
          progress: progress,
          interactionCount: interactionCount,
          onTap: onTapAction,
        ),
      RecipeActionType.drag => DragScene(
          key: key,
          step: step,
          progress: progress,
          interactionCount: interactionCount,
          onDragAccepted: onDragAccepted,
        ),
      RecipeActionType.stir => StirScene(
          key: key,
          step: step,
          progress: progress,
          interactionCount: interactionCount,
          onProgressDelta: onProgressDelta,
        ),
      RecipeActionType.hold => HoldScene(
          key: key,
          step: step,
          progress: progress,
          interactionCount: interactionCount,
          onProgressDelta: onProgressDelta,
        ),
      RecipeActionType.shake => ShakeScene(
          key: key,
          step: step,
          progress: progress,
          interactionCount: interactionCount,
          onProgressDelta: onProgressDelta,
        ),
    };
  }

  /// Get scene colors from the engine.
  SceneColors get sceneColors =>
      const RecipeEngine().sceneColorsForAction(step.action);

  /// Build the scene with its themed background.
  @override
  Widget build(BuildContext context) {
    return SceneBackground(
      sceneColors: sceneColors,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: buildInteraction(context),
      ),
    );
  }

  /// Override in subclasses to build the interactive content.
  Widget buildInteraction(BuildContext context);
}
