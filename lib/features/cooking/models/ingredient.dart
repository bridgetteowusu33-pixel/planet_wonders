import 'package:flutter/foundation.dart';

@immutable
class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.country,
    this.isSpice = false,
    this.points = 10,
  });

  final String id;
  final String name;
  final String assetPath;
  final String country;
  final bool isSpice;
  final int points;
}
