import 'package:flutter/foundation.dart';

@immutable
class CookingConfig {
  const CookingConfig({
    this.ingredientWeight = 0.30,
    this.stirWeight = 0.30,
    this.spiceWeight = 0.10,
    this.serveWeight = 0.30,
    this.stirVelocityTarget = 2.4,
    this.spiceMotionThreshold = 62,
  });

  final double ingredientWeight;
  final double stirWeight;
  final double spiceWeight;
  final double serveWeight;
  final double stirVelocityTarget;
  final double spiceMotionThreshold;
}
