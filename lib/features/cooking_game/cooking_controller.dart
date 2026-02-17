import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'models/cooking_step.dart';
import 'models/recipe.dart';
import 'utils/gesture_smoothing.dart';
import 'utils/sfx.dart';

class CookingController extends ChangeNotifier {
  CookingController({required this.recipe});

  final Recipe recipe;

  CookingState _state = CookingState.intro;
  final Set<String> _addedIngredientIds = <String>{};
  final CircularGestureTracker _gestureTracker = CircularGestureTracker();

  double _stirProgress = 0;
  double _plateProgress = 0;
  int _dropAnimationTick = 0;
  int _factIndex = 0;

  CookingState get state => _state;
  double get stirProgress => _stirProgress;
  double get plateProgress => _plateProgress;
  int get dropAnimationTick => _dropAnimationTick;

  Set<String> get addedIngredientIds => _addedIngredientIds;

  List<Ingredient> get remainingIngredients => recipe.ingredients
      .where((ing) => !_addedIngredientIds.contains(ing.id))
      .toList(growable: false);

  bool get allIngredientsAdded =>
      _addedIngredientIds.length == recipe.ingredients.length;

  String get currentInstruction {
    if (_state == CookingState.intro) {
      return 'Let\'s cook ${recipe.name}!';
    }
    if (_state == CookingState.complete) {
      return 'Amazing! Your ${recipe.name} is ready.';
    }
    return recipe.stepFor(_state)?.instruction ?? '';
  }

  String get currentFact {
    if (recipe.funFacts.isEmpty) return '';
    return recipe.funFacts[_factIndex % recipe.funFacts.length];
  }

  void startCooking() {
    _setState(CookingState.addIngredients);
  }

  void addIngredient(Ingredient ingredient) {
    if (_state != CookingState.addIngredients) return;
    final added = _addedIngredientIds.add(ingredient.id);
    if (!added) return;

    _dropAnimationTick++;
    _cycleFact();
    Sfx.plop();
    notifyListeners();
  }

  void continueToStirIfReady() {
    if (_state != CookingState.addIngredients || !allIngredientsAdded) return;
    _gestureTracker.reset();
    _stirProgress = 0;
    _setState(CookingState.stir);
  }

  void onStirStart() {
    if (_state != CookingState.stir) return;
    _gestureTracker.reset();
  }

  void onStirUpdate({
    required Offset point,
    required Size areaSize,
  }) {
    if (_state != CookingState.stir) return;

    final delta = _gestureTracker.addPoint(point: point, areaSize: areaSize);
    if (delta <= 0) return;

    // Roughly ~3 smooth circular swipes to complete.
    _stirProgress = (_stirProgress + (delta / (math.pi * 6.2))).clamp(0.0, 1.0);

    if (_stirProgress >= 1) {
      _setState(CookingState.plate);
      Sfx.stirTick();
      return;
    }

    if (_stirProgress > 0.35 && _factIndex == 0) {
      _cycleFact();
    } else if (_stirProgress > 0.72 && _factIndex == 1) {
      _cycleFact();
    }

    notifyListeners();
  }

  void serveScoop() {
    if (_state != CookingState.plate) return;

    _plateProgress = (_plateProgress + 0.17).clamp(0.0, 1.0);
    Sfx.stirTick();

    if (_plateProgress >= 1) {
      _setState(CookingState.complete);
      Sfx.celebrate();
      return;
    }

    notifyListeners();
  }

  String stepLabelForState(CookingState state) {
    switch (state) {
      case CookingState.intro:
        return 'Get Ready';
      case CookingState.addIngredients:
        return '1/3 Add';
      case CookingState.stir:
        return '2/3 Stir';
      case CookingState.plate:
        return '3/3 Serve';
      case CookingState.complete:
        return 'Done';
    }
  }

  double overallProgress() {
    switch (_state) {
      case CookingState.intro:
        return 0.0;
      case CookingState.addIngredients:
        return 0.33 * (_addedIngredientIds.length / recipe.ingredients.length);
      case CookingState.stir:
        return 0.33 + (0.33 * _stirProgress);
      case CookingState.plate:
        return 0.66 + (0.34 * _plateProgress);
      case CookingState.complete:
        return 1.0;
    }
  }

  void _setState(CookingState next) {
    if (_state == next) return;
    _state = next;
    notifyListeners();
  }

  void _cycleFact() {
    if (recipe.funFacts.isEmpty) return;
    _factIndex = (_factIndex + 1) % recipe.funFacts.length;
  }
}
