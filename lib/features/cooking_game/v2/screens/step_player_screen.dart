import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../engine/cooking_audio_service.dart';
import '../models/step_type.dart';
import '../models/v2_recipe.dart';
import '../models/v2_recipe_step.dart';
import '../providers/v2_cooking_state.dart';
import '../widgets/add_ingredients_step.dart';
import '../widgets/chef_avatar.dart';
import '../widgets/chop_step.dart';
import '../widgets/heat_step.dart';
import '../widgets/ingredient_toolbar.dart';
import '../widgets/kitchen_scene.dart';
import '../widgets/plate_step.dart';
import '../widgets/season_step.dart';
import '../widgets/simmer_step.dart';
import '../widgets/stir_step.dart';

class StepPlayerScreen extends StatefulWidget {
  const StepPlayerScreen({
    super.key,
    required this.recipe,
    required this.state,
    required this.onAddIngredient,
    required this.onTapAction,
    required this.onProgressDelta,
    required this.onMistake,
    required this.onExit,
  });

  final V2Recipe recipe;
  final V2CookingState state;
  final void Function(String ingredientId) onAddIngredient;
  final VoidCallback onTapAction;
  final void Function(double delta) onProgressDelta;
  final VoidCallback onMistake;
  final VoidCallback onExit;

  @override
  State<StepPlayerScreen> createState() => _StepPlayerScreenState();
}

class _StepPlayerScreenState extends State<StepPlayerScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _ttsMuted = false;
  bool _ttsSpeaking = false;
  int _lastSpokenStepIndex = -1;
  bool _showFact = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.4);
      await _tts.setPitch(1.1);
      _tts.setCompletionHandler(() => _ttsSpeaking = false);
    } catch (_) {
      // TTS plugin unavailable — degrade gracefully.
    }
  }

  @override
  void didUpdateWidget(StepPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Speak chef line when step changes.
    if (widget.state.stepIndex != _lastSpokenStepIndex) {
      // Play talking-drum SFX on step transitions (skip the first step).
      if (_lastSpokenStepIndex >= 0) {
        CookingAudioService.instance.playSfx(
          'step_complete',
          widget.recipe.countryId,
        );
      }
      _lastSpokenStepIndex = widget.state.stepIndex;
      _showFact = false;
      _speakChefLine();
    }
  }

  void _speakChefLine() {
    if (_ttsMuted || _ttsSpeaking) return;
    final line = widget.state.chefLine;
    if (line.isNotEmpty) {
      _ttsSpeaking = true;
      try {
        _tts.speak(line);
      } catch (_) {
        _ttsSpeaking = false;
      }
    }
  }

  @override
  void dispose() {
    try {
      _tts.stop();
    } catch (_) {
      // Ignore — TTS may not be initialized.
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepIndex = widget.state.stepIndex;
    final totalSteps = widget.recipe.steps.length;
    final currentStep = stepIndex < totalSteps
        ? widget.recipe.steps[stepIndex]
        : null;

    return SafeArea(
      child: Column(
        children: <Widget>[
          // Top bar: step dots + recipe name + mute
          _TopBar(
            stepIndex: stepIndex,
            totalSteps: totalSteps,
            recipeName: widget.recipe.name,
            ttsMuted: _ttsMuted,
            onTtsMuteToggle: () {
              setState(() => _ttsMuted = !_ttsMuted);
              CookingAudioService.instance.setMuted(_ttsMuted);
              if (_ttsMuted) {
                _tts.stop();
                CookingAudioService.instance.stopAll();
              }
            },
            onExit: widget.onExit,
            recipe: widget.recipe,
          ),
          // Kitchen scene: bg + pot + chef avatar + speech bubble
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: KitchenSceneWidget(
                countryId: widget.recipe.countryId,
                potFace: widget.state.potFace,
                progress: widget.state.stepProgress,
                chefLine: widget.state.chefLine,
                showSteam: currentStep != null &&
                    (currentStep.type.isHeat ||
                        currentStep.type == V2StepType.simmer),
                chefMood: _chefMoodForStep(currentStep?.type),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Instruction banner with toggleable fact
          if (currentStep != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _InstructionBanner(
                instruction: currentStep.instruction,
                factText: currentStep.factText,
                showFact: _showFact,
                onToggleFact: currentStep.factText != null
                    ? () => setState(() => _showFact = !_showFact)
                    : null,
              ),
            ),
          const SizedBox(height: 6),
          // Mini-game interaction area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: currentStep != null
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: KeyedSubtree(
                        key: ValueKey<int>(stepIndex),
                        child: _buildStepWidget(currentStep),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Loading...',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ),
          ),
          // Ingredient toolbar at bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IngredientToolbar(
              ingredients: widget.recipe.ingredients,
              addedIds: widget.state.addedIngredientIds,
              interactive:
                  currentStep?.type == V2StepType.addIngredients,
              onIngredientTap: widget.onAddIngredient,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  ChefAvatarMood _chefMoodForStep(V2StepType? type) {
    if (type == null) return ChefAvatarMood.happy;
    if (type.isHeat) return ChefAvatarMood.thinking;
    return switch (type) {
      V2StepType.addIngredients => ChefAvatarMood.excited,
      V2StepType.chop => ChefAvatarMood.happy,
      V2StepType.stir => ChefAvatarMood.happy,
      V2StepType.season => ChefAvatarMood.excited,
      V2StepType.simmer => ChefAvatarMood.happy,
      V2StepType.plate => ChefAvatarMood.proud,
      _ => ChefAvatarMood.happy,
    };
  }

  Widget _buildStepWidget(V2RecipeStep step) {
    final countryId = widget.recipe.countryId;
    return switch (step.type) {
      V2StepType.addIngredients => AddIngredientsStep(
          step: step,
          progress: widget.state.stepProgress,
          ingredients: widget.recipe.ingredients,
          addedIds: widget.state.addedIngredientIds,
          onIngredientAdded: widget.onAddIngredient,
          countryId: countryId,
        ),
      V2StepType.chop => ChopStep(
          step: step,
          progress: widget.state.stepProgress,
          interactionCount: widget.state.interactionCount,
          onTap: widget.onTapAction,
          countryId: countryId,
          ingredients: widget.recipe.ingredients,
        ),
      V2StepType.stir => StirStep(
          step: step,
          progress: widget.state.stepProgress,
          onProgressDelta: widget.onProgressDelta,
          countryId: countryId,
        ),
      V2StepType.heat || V2StepType.boil || V2StepType.fry || V2StepType.bake =>
        HeatStep(
          step: step,
          progress: widget.state.stepProgress,
          onProgressDelta: widget.onProgressDelta,
          onMistake: widget.onMistake,
          countryId: countryId,
        ),
      V2StepType.season => SeasonStep(
          step: step,
          progress: widget.state.stepProgress,
          interactionCount: widget.state.interactionCount,
          onTap: widget.onTapAction,
          countryId: countryId,
        ),
      V2StepType.simmer => SimmerStep(
          step: step,
          progress: widget.state.stepProgress,
          onProgressDelta: widget.onProgressDelta,
          countryId: countryId,
        ),
      V2StepType.plate => PlateStep(
          step: step,
          progress: widget.state.stepProgress,
          interactionCount: widget.state.interactionCount,
          onScoop: widget.onTapAction,
          countryId: countryId,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// _TopBar — slim header with step dots, recipe name, mute, and exit
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.stepIndex,
    required this.totalSteps,
    required this.recipeName,
    required this.ttsMuted,
    required this.onTtsMuteToggle,
    required this.onExit,
    required this.recipe,
  });

  final int stepIndex;
  final int totalSteps;
  final String recipeName;
  final bool ttsMuted;
  final VoidCallback onTtsMuteToggle;
  final VoidCallback onExit;
  final V2Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: <Widget>[
          // Exit button
          Semantics(
            button: true,
            label: 'Exit cooking game',
            child: GestureDetector(
              onTap: onExit,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF264653),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Recipe name + step dots
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  recipeName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1D3557),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Step dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalSteps, (i) {
                    final isActive = i == stepIndex;
                    final isDone = i < stepIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isDone
                              ? const Color(0xFF6BCB77)
                              : isActive
                                  ? const Color(0xFFFFB703)
                                  : const Color(0xFF1D3557)
                                      .withValues(alpha: 0.15),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Recipe book
          Semantics(
            button: true,
            label: 'View recipe',
            child: GestureDetector(
              onTap: () => _showRecipeSheet(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF264653),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Mute toggle
          Semantics(
            button: true,
            label: ttsMuted ? 'Unmute narration' : 'Mute narration',
            child: GestureDetector(
              onTap: onTtsMuteToggle,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ttsMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: const Color(0xFF264653),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF9E6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: <Widget>[
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D3557).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Row(
                children: <Widget>[
                  Text(
                    recipe.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D3557),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Ingredients header
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE76F51),
                ),
              ),
              const SizedBox(height: 8),
              ...recipe.ingredients.map(
                (ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: <Widget>[
                      Text(ing.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        ing.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF264653),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Steps header
              const Text(
                'Steps',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE76F51),
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(recipe.steps.length, (i) {
                final step = recipe.steps[i];
                final isCurrent = i == stepIndex;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFFFFB703).withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent
                        ? Border.all(
                            color: const Color(0xFFFFB703), width: 2)
                        : null,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: i < stepIndex
                              ? const Color(0xFF6BCB77)
                              : isCurrent
                                  ? const Color(0xFFFFB703)
                                  : const Color(0xFF1D3557)
                                      .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: i < stepIndex
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 16)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isCurrent
                                        ? Colors.white
                                        : const Color(0xFF1D3557),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          step.instruction,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: const Color(0xFF264653),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _InstructionBanner — instruction + toggleable fun fact
// ---------------------------------------------------------------------------

class _InstructionBanner extends StatelessWidget {
  const _InstructionBanner({
    required this.instruction,
    this.factText,
    required this.showFact,
    this.onToggleFact,
  });

  final String instruction;
  final String? factText;
  final bool showFact;
  final VoidCallback? onToggleFact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFF9E6), Color(0xFFFFF3C4)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Instruction row
          Row(
            children: <Widget>[
              const Icon(
                Icons.restaurant_menu_rounded,
                color: Color(0xFFFFB703),
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  instruction,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D3557),
                  ),
                ),
              ),
              if (factText != null)
                GestureDetector(
                  onTap: onToggleFact,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: showFact
                          ? const Color(0xFFFFA600)
                          : const Color(0xFFFFA600).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color:
                          showFact ? Colors.white : const Color(0xFFFFA600),
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          // Expandable fact
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFFFFA600),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        factText ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF355070),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            crossFadeState: showFact
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
