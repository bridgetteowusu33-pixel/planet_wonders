import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import 'cooking_step.dart';

class CookingState extends ChangeNotifier {
  CookingState({required this.recipe, required this.currentFact})
    : _startedAt = DateTime.now();

  final Recipe recipe;

  CookingStep _currentStep = CookingStep.addIngredients;
  double _progress = 0;
  int _stars = 0;
  bool _isComplete = false;
  int _combo = 0;
  int _mistakes = 0;
  int _successes = 0;
  CookingFact currentFact;

  final Set<String> _addedIngredientIds = <String>{};
  int _spiceCount = 0;
  int _servedCount = 0;
  double _stirRadians = 0;
  final DateTime _startedAt;

  CookingStep get currentStep => _currentStep;
  double get progress => _progress;
  int get stars => _stars;
  bool get isComplete => _isComplete;
  int get combo => _combo;
  int get mistakes => _mistakes;
  int get successes => _successes;
  int get spiceCount => _spiceCount;
  int get servedCount => _servedCount;
  double get stirRadians => _stirRadians;
  Set<String> get addedIngredientIds =>
      UnmodifiableSetView(_addedIngredientIds);
  DateTime get startedAt => _startedAt;

  void setStep(CookingStep step) {
    if (_currentStep == step) return;
    _currentStep = step;
    if (step == CookingStep.complete) {
      _isComplete = true;
      _progress = 1;
    } else {
      _progress = 0;
    }
    notifyListeners();
  }

  void setFact(CookingFact fact) {
    currentFact = fact;
    notifyListeners();
  }

  bool addIngredient(String ingredientId) {
    final didAdd = _addedIngredientIds.add(ingredientId);
    if (!didAdd) {
      _mistakes++;
      _combo = 0;
      notifyListeners();
      return false;
    }

    _successes++;
    _combo += 1;
    final ingredientTarget = math.max(1, recipe.ingredients.length);
    _progress = (_addedIngredientIds.length / ingredientTarget).clamp(0, 1);
    notifyListeners();
    return true;
  }

  void addStirRadians(double radiansDelta, {required double targetRadians}) {
    if (radiansDelta <= 0) return;
    _stirRadians = (_stirRadians + radiansDelta).clamp(0, targetRadians);
    _progress = (_stirRadians / math.max(1, targetRadians)).clamp(0, 1);
    notifyListeners();
  }

  void addSpice() {
    _spiceCount += 1;
    _successes += 1;
    _combo += 1;
    final target = math.max(1, recipe.requiredSpiceShakes);
    _progress = (_spiceCount / target).clamp(0, 1);
    notifyListeners();
  }

  void addServe() {
    _servedCount += 1;
    _successes += 1;
    _combo += 1;
    final target = math.max(1, recipe.requiredServeScoops);
    _progress = (_servedCount / target).clamp(0, 1);
    notifyListeners();
  }

  void registerMistake() {
    _mistakes += 1;
    _combo = 0;
    notifyListeners();
  }

  void setStars(int value) {
    _stars = value.clamp(1, 3);
    notifyListeners();
  }
}
