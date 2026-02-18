import 'dart:math' as math;
import 'dart:isolate';

import 'package:flutter/material.dart';

import '../models/recipe.dart';
import 'cooking_config.dart';

@immutable
class CookingScore {
  const CookingScore({
    required this.accuracy,
    required this.speed,
    required this.smoothness,
    required this.stars,
    required this.comboBonus,
    required this.perfectChef,
  });

  final int accuracy;
  final int speed;
  final int smoothness;
  final int stars;
  final int comboBonus;
  final bool perfectChef;
}

@immutable
class CircularGestureSample {
  const CircularGestureSample({
    required this.progressDelta,
    required this.angularVelocity,
  });

  final double progressDelta;
  final double angularVelocity;
}

class CookingEngine {
  const CookingEngine({this.config = const CookingConfig()});

  final CookingConfig config;

  double requiredStirRadians(Recipe recipe) {
    return recipe.requiredStirTurns * math.pi * 2;
  }

  CircularGestureSample evaluateStirGesture({
    required Offset center,
    required Offset previousPoint,
    required Offset currentPoint,
    required Duration delta,
  }) {
    final previous = previousPoint - center;
    final current = currentPoint - center;

    if (previous.distance < 4 || current.distance < 4) {
      return const CircularGestureSample(progressDelta: 0, angularVelocity: 0);
    }

    final previousAngle = math.atan2(previous.dy, previous.dx);
    final currentAngle = math.atan2(current.dy, current.dx);

    var deltaAngle = currentAngle - previousAngle;
    while (deltaAngle > math.pi) {
      deltaAngle -= 2 * math.pi;
    }
    while (deltaAngle < -math.pi) {
      deltaAngle += 2 * math.pi;
    }

    final absoluteDelta = deltaAngle.abs();
    if (absoluteDelta < 0.01) {
      return const CircularGestureSample(progressDelta: 0, angularVelocity: 0);
    }

    final ms = math.max(1, delta.inMilliseconds);
    final velocity = absoluteDelta / (ms / 1000.0);

    return CircularGestureSample(
      progressDelta: absoluteDelta,
      angularVelocity: velocity,
    );
  }

  bool validateIngredient({
    required Recipe recipe,
    required Set<String> alreadyAdded,
    required String ingredientId,
  }) {
    final existsInRecipe = recipe.ingredients.any((i) => i.id == ingredientId);
    if (!existsInRecipe) return false;
    return !alreadyAdded.contains(ingredientId);
  }

  bool validateSpiceShake(double intensity) {
    return intensity >= config.spiceMotionThreshold;
  }

  Future<CookingScore> calculateScore({
    required Recipe recipe,
    required int mistakes,
    required int maxCombo,
    required Duration totalDuration,
    required List<double> stirVelocities,
    required int successfulActions,
  }) {
    final ingredientCount = recipe.ingredients.length;
    final requiredServeScoops = recipe.requiredServeScoops;
    final requiredStirTurns = recipe.requiredStirTurns;
    final requiredSpiceShakes = recipe.requiredSpiceShakes;
    final ingredientWeight = config.ingredientWeight;
    final stirWeight = config.stirWeight;
    final spiceWeight = config.spiceWeight;
    final serveWeight = config.serveWeight;
    final stirVelocityTarget = config.stirVelocityTarget;
    final durationSeconds = totalDuration.inSeconds;
    final safeVelocities = List<double>.from(stirVelocities, growable: false);

    return Isolate.run(() {
      final expectedActions =
          ingredientCount +
          requiredServeScoops +
          requiredStirTurns +
          math.max(requiredSpiceShakes, 0);

      final accuracyValue =
          ((successfulActions / math.max(1, expectedActions + mistakes)) * 100)
              .clamp(0, 100)
              .round();

      final targetSeconds = math.max(20, expectedActions * 4);
      final speedValue = ((targetSeconds / math.max(1, durationSeconds)) * 100)
          .clamp(20, 100)
          .round();

      final averageVelocity = safeVelocities.isEmpty
          ? 0
          : safeVelocities.reduce((a, b) => a + b) / safeVelocities.length;
      final smoothnessRaw =
          (100 - (averageVelocity - stirVelocityTarget).abs() * 26).clamp(
            35,
            100,
          );
      final smoothnessValue = smoothnessRaw.round();

      final comboBonus = math.min(25, maxCombo * 2);
      final weighted =
          accuracyValue * ingredientWeight +
          speedValue * serveWeight +
          smoothnessValue * stirWeight +
          comboBonus * spiceWeight;

      int stars;
      if (weighted >= 82) {
        stars = 3;
      } else if (weighted >= 64) {
        stars = 2;
      } else {
        stars = 1;
      }

      final perfectChef =
          mistakes == 0 &&
          stars == 3 &&
          accuracyValue >= 92 &&
          speedValue >= 85;

      return CookingScore(
        accuracy: accuracyValue,
        speed: speedValue,
        smoothness: smoothnessValue,
        stars: stars,
        comboBonus: comboBonus,
        perfectChef: perfectChef,
      );
    });
  }
}
