import 'package:flutter/foundation.dart';

import 'badge.dart';
import 'ingredient.dart';

@immutable
class CookingFact {
  const CookingFact({required this.text, required this.country});

  final String text;
  final String country;
}

@immutable
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.country,
    required this.potAsset,
    required this.chefAsset,
    required this.ingredients,
    required this.facts,
    required this.badge,
    required this.requiredStirTurns,
    required this.requiredServeScoops,
    this.requiredSpiceShakes = 0,
  });

  final String id;
  final String name;
  final String country;
  final String potAsset;
  final String chefAsset;
  final List<Ingredient> ingredients;
  final List<CookingFact> facts;
  final CookingBadge badge;
  final int requiredStirTurns;
  final int requiredSpiceShakes;
  final int requiredServeScoops;
}
