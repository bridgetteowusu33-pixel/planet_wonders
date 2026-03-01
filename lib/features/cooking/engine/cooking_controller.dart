import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/passport_service.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import 'cooking_engine.dart';
import 'cooking_state.dart';
import 'cooking_step.dart';

enum ChefMood { happy, excited, thinking, proud }

// ---------------------------------------------------------------------------
// Character name lookup by country
// ---------------------------------------------------------------------------

String _characterFor(String country) {
  final key = country.trim().toLowerCase();
  return switch (key) {
    'ghana' => 'Afia',
    'nigeria' => 'Adetutu',
    'uk' || 'united kingdom' => 'Heze & Aza',
    'usa' || 'united states' => 'Ava',
    _ => 'Chef',
  };
}

// ---------------------------------------------------------------------------
// Pot face emoji constants
// ---------------------------------------------------------------------------

const _potIdle = '\u{1F60A}'; // 😊
const _potSurprised = '\u{1F62E}'; // 😮
const _potHappy = '\u{1F604}'; // 😄
const _potStir = '\u{1F606}'; // 😆
const _potYum = '\u{1F924}'; // 🤤
const _potSpicy = '\u{1F975}'; // 🥵
const _potDelicious = '\u{1F60B}'; // 😋
const _potLove = '\u{1F60D}'; // 😍
const _potParty = '\u{1F973}'; // 🥳
const _potWorried = '\u{1F61F}'; // 😟

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
       ),
       characterName = _characterFor(recipe.country) {
    _setChef(
      message: '$characterName says: Let\u{2019}s start cooking!',
      mood: ChefMood.excited,
    );
    potFace.value = _potIdle;
  }

  final Recipe recipe;
  final CookingEngine engine;
  final Future<void> Function(Recipe recipe, CookingScore score)? onCompleted;

  final CookingState state;
  final String characterName;

  final ValueNotifier<String> chefMessage = ValueNotifier<String>('');
  final ValueNotifier<ChefMood> chefMood = ValueNotifier<ChefMood>(
    ChefMood.happy,
  );
  final ValueNotifier<String> potFace = ValueNotifier<String>(_potIdle);
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

  final math.Random _rng = math.Random();
  Timer? _potFaceRevertTimer;
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
    _setChef(
      message: _pick(<String>[
        'Yum! ${ingredient.name} goes in!',
        '$characterName says: Nice pick!',
        'In it goes \u{2014} ${ingredient.name}!',
        'Perfect! Keep going, little chef!',
      ]),
      mood: ChefMood.happy,
    );
    _setPotFace(_potSurprised, revertTo: _potHappy, revertMs: 800);
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
    _setChef(
      message: _pick(<String>[
        'Shake shake! Perfect spice!',
        'Ooh, spicy! $characterName loves it!',
        'Shake it like a maraca!',
      ]),
      mood: ChefMood.excited,
    );
    _setPotFace(_potSpicy, revertTo: _potDelicious, revertMs: 600);
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
    _setChef(
      message: _pick(<String>[
        'Beautiful! $characterName is so proud!',
        'That looks delicious!',
        'Great plating, little chef!',
      ]),
      mood: ChefMood.happy,
    );
    _setPotFace(_potLove);
    HapticFeedback.selectionClick();

    if (state.progress >= 1) {
      await _completeRecipe();
    }
  }

  Future<void> _completeRecipe() async {
    _setChef(
      message: _pick(<String>[
        'You\u{2019}re a ${recipe.name} Master!',
        'Chef $characterName gives you a gold star!',
        'Amazing cooking! $characterName is so proud!',
      ]),
      mood: ChefMood.proud,
    );
    _setPotFace(_potParty);

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
          message: _pick(<String>[
            '$characterName says: Stir stir stir!',
            'Stir in circles! Faster = more stars!',
            'Round and round we go!',
          ]),
          mood: ChefMood.thinking,
        );
        _setPotFace(_potStir);
        break;
      case CookingStep.spice:
        _setChef(
          message: _pick(<String>[
            'Time to add some spice!',
            'Shake or tap the spice shaker!',
            '$characterName says: Season it up!',
          ]),
          mood: ChefMood.excited,
        );
        _setPotFace(_potYum);
        break;
      case CookingStep.serve:
        _setChef(
          message: _pick(<String>[
            'Scoop and serve! Yum!',
            'Time to plate up, little chef!',
            '$characterName says: Serve it beautifully!',
          ]),
          mood: ChefMood.happy,
        );
        _setPotFace(_potLove);
        break;
      case CookingStep.complete:
      case CookingStep.addIngredients:
        break;
    }
  }

  void _handleMistake(String message) {
    state.registerMistake();
    _setChef(
      message: _pick(<String>[
        'Oops! Try again, you\u{2019}ve got this!',
        'Not quite \u{2014} keep going!',
        message,
      ]),
      mood: ChefMood.thinking,
    );
    _setPotFace(_potWorried, revertTo: _potIdle, revertMs: 1000);
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

  String _pick(List<String> options) => options[_rng.nextInt(options.length)];

  void _setPotFace(String emoji, {String? revertTo, int? revertMs}) {
    _potFaceRevertTimer?.cancel();
    _potFaceRevertTimer = null;
    potFace.value = emoji;
    if (revertTo != null && revertMs != null) {
      _potFaceRevertTimer = Timer(
        Duration(milliseconds: revertMs),
        () => potFace.value = revertTo,
      );
    }
  }

  @override
  void dispose() {
    _potFaceRevertTimer?.cancel();
    potFace.dispose();
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
