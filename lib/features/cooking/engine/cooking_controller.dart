import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/passport_service.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import 'cooking_engine.dart';
import 'cooking_state.dart';
import 'cooking_step.dart';

enum ChefMood { happy, excited, thinking, proud }

class CookingController extends ChangeNotifier {
  CookingController({
    required this.recipe,
    this.engine = const CookingEngine(),
    this.onCompleted,
  }) : state = CookingState(
         recipe: recipe,
         currentFact: recipe.facts.isEmpty
             ? CookingFact(text: 'Cooking is fun!', country: recipe.country)
             : recipe.facts.first,
       ) {
    _setChef(message: 'Drag ingredients into the pot!', mood: ChefMood.excited);
  }

  final Recipe recipe;
  final CookingEngine engine;
  final Future<void> Function(Recipe recipe, CookingScore score)? onCompleted;

  final CookingState state;

  final ValueNotifier<String> chefMessage = ValueNotifier<String>('');
  final ValueNotifier<ChefMood> chefMood = ValueNotifier<ChefMood>(
    ChefMood.happy,
  );
  final ValueNotifier<double> stirProgressRing = ValueNotifier<double>(0);
  final ValueNotifier<int> splashTick = ValueNotifier<int>(0);
  final ValueNotifier<int> steamTick = ValueNotifier<int>(0);
  final ValueNotifier<int> swirlTick = ValueNotifier<int>(0);
  final ValueNotifier<int> confettiTick = ValueNotifier<int>(0);
  final ValueNotifier<bool> successGlow = ValueNotifier<bool>(false);
  final ValueNotifier<CookingScore?> score = ValueNotifier<CookingScore?>(null);
  final ValueNotifier<String?> lastDroppedIngredientAsset =
      ValueNotifier<String?>(null);
  final ValueNotifier<CookingStep?> stepCompletedEvent =
      ValueNotifier<CookingStep?>(null);

  int _factIndex = 0;
  int _maxCombo = 0;
  Offset? _lastStirPoint;
  DateTime? _lastStirTime;
  final List<double> _stirVelocities = <double>[];

  Future<void> preloadAssets(BuildContext context) async {
    final assets = <String>{
      recipe.potAsset,
      recipe.chefAsset,
      recipe.badge.iconAsset,
      'assets/cooking/effects/steam.png',
      'assets/cooking/effects/sparkle.png',
      'assets/cooking/effects/confetti_star.png',
      ...recipe.ingredients.map((ingredient) => ingredient.assetPath),
    };

    for (final asset in assets) {
      await _precacheAsset(context, asset);
    }
  }

  Future<void> _precacheAsset(BuildContext context, String path) async {
    try {
      await rootBundle.load(path);
    } catch (_) {
      return;
    }

    if (!context.mounted) return;

    try {
      await precacheImage(AssetImage(path), context);
    } catch (_) {
      // Keep gameplay resilient when assets are missing.
    }
  }

  void onIngredientDropped(Ingredient ingredient) {
    if (state.currentStep != CookingStep.addIngredients) {
      _handleMistake(
        'Nice try! We are on ${state.currentStep.title.toLowerCase()}.',
      );
      return;
    }

    final isValid = engine.validateIngredient(
      recipe: recipe,
      alreadyAdded: state.addedIngredientIds,
      ingredientId: ingredient.id,
    );

    if (!isValid) {
      _handleMistake('Oops! Add each ingredient only once.');
      return;
    }

    state.addIngredient(ingredient.id);
    splashTick.value += 1;
    lastDroppedIngredientAsset.value = ingredient.assetPath;
    _trackCombo();
    _setChef(message: 'Yum! ${ingredient.name} added.', mood: ChefMood.happy);
    _pulseSuccessGlow();
    HapticFeedback.lightImpact();

    if (state.progress >= 1) {
      _moveToStep(CookingStep.stir);
    }
  }

  void onStirStart(Offset point) {
    if (state.currentStep != CookingStep.stir) return;
    _lastStirPoint = point;
    _lastStirTime = DateTime.now();
  }

  void onStirUpdate(Offset point, Size potSize) {
    if (state.currentStep != CookingStep.stir) return;

    final previous = _lastStirPoint;
    final previousTime = _lastStirTime;
    if (previous == null || previousTime == null) {
      _lastStirPoint = point;
      _lastStirTime = DateTime.now();
      return;
    }

    final now = DateTime.now();
    final sample = engine.evaluateStirGesture(
      center: potSize.center(Offset.zero),
      previousPoint: previous,
      currentPoint: point,
      delta: now.difference(previousTime),
    );

    _lastStirPoint = point;
    _lastStirTime = now;

    if (sample.progressDelta <= 0) {
      return;
    }

    final target = engine.requiredStirRadians(recipe);
    state.addStirRadians(sample.progressDelta, targetRadians: target);

    if (sample.angularVelocity > 0) {
      _stirVelocities.add(sample.angularVelocity);
      if (_stirVelocities.length > 240) {
        _stirVelocities.removeRange(0, _stirVelocities.length - 240);
      }
    }

    stirProgressRing.value = state.progress;
    swirlTick.value += 1;
    _trackCombo();

    if (state.progress >= 1) {
      steamTick.value += 1;
      HapticFeedback.mediumImpact();
      if (recipe.requiredSpiceShakes > 0) {
        _moveToStep(CookingStep.spice);
      } else {
        _moveToStep(CookingStep.serve);
      }
    }
  }

  void onStirEnd() {
    _lastStirPoint = null;
    _lastStirTime = null;
  }

  void onSpiceMotion(double intensity) {
    if (state.currentStep != CookingStep.spice) return;

    if (!engine.validateSpiceShake(intensity)) {
      return;
    }

    state.addSpice();
    splashTick.value += 1;
    _trackCombo();
    _setChef(message: 'Shake shake! Perfect spice!', mood: ChefMood.excited);
    HapticFeedback.mediumImpact();

    if (state.progress >= 1) {
      _moveToStep(CookingStep.serve);
    }
  }

  Future<void> onServeDropped() async {
    if (state.currentStep != CookingStep.serve) {
      _handleMistake('Let\'s finish the step first.');
      return;
    }

    state.addServe();
    splashTick.value += 1;
    _trackCombo();
    _setChef(message: 'Great plating!', mood: ChefMood.happy);
    HapticFeedback.selectionClick();

    if (state.progress >= 1) {
      await _completeRecipe();
    }
  }

  Future<void> _completeRecipe() async {
    _setChef(message: 'Chef-level cooking! You did it!', mood: ChefMood.proud);

    final computedScore = await engine.calculateScore(
      recipe: recipe,
      mistakes: state.mistakes,
      maxCombo: _maxCombo,
      totalDuration: DateTime.now().difference(state.startedAt),
      stirVelocities: List<double>.unmodifiable(_stirVelocities),
      successfulActions: state.successes,
    );

    score.value = computedScore;
    state.setStars(computedScore.stars);
    stepCompletedEvent.value = CookingStep.serve;
    state.setStep(CookingStep.complete);
    confettiTick.value += 1;
    await PassportService.unlockBadge(recipe.badge.id);

    if (onCompleted != null) {
      await onCompleted!(recipe, computedScore);
    }
  }

  void _moveToStep(CookingStep step) {
    final previousStep = state.currentStep;
    if (previousStep != step && previousStep != CookingStep.complete) {
      stepCompletedEvent.value = previousStep;
    }
    state.setStep(step);
    if (recipe.facts.isNotEmpty) {
      _factIndex = (_factIndex + 1) % recipe.facts.length;
      state.setFact(recipe.facts[_factIndex]);
    }

    switch (step) {
      case CookingStep.stir:
        _setChef(
          message: 'Stir in circles! Faster = more stars!',
          mood: ChefMood.thinking,
        );
        break;
      case CookingStep.spice:
        _setChef(
          message: 'Shake the spice shaker to season!',
          mood: ChefMood.excited,
        );
        break;
      case CookingStep.serve:
        _setChef(message: 'Scoop and serve! Yum!', mood: ChefMood.happy);
        break;
      case CookingStep.complete:
      case CookingStep.addIngredients:
        break;
    }
  }

  void _handleMistake(String message) {
    state.registerMistake();
    _setChef(message: message, mood: ChefMood.thinking);
    HapticFeedback.heavyImpact();
  }

  void _trackCombo() {
    if (state.combo > _maxCombo) {
      _maxCombo = state.combo;
    }
  }

  void _pulseSuccessGlow() {
    successGlow.value = true;
    scheduleMicrotask(() {
      successGlow.value = false;
    });
  }

  void _setChef({required String message, required ChefMood mood}) {
    chefMessage.value = message;
    chefMood.value = mood;
  }

  @override
  void dispose() {
    score.dispose();
    lastDroppedIngredientAsset.dispose();
    stepCompletedEvent.dispose();
    chefMessage.dispose();
    chefMood.dispose();
    stirProgressRing.dispose();
    splashTick.dispose();
    steamTick.dispose();
    swirlTick.dispose();
    confettiTick.dispose();
    successGlow.dispose();
    state.dispose();
    super.dispose();
  }
}
