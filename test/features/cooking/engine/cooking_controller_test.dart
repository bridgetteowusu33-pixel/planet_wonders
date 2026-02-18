import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planet_wonders/features/cooking/data/ghana_recipes.dart';
import 'package:planet_wonders/features/cooking/engine/cooking_controller.dart';
import 'package:planet_wonders/features/cooking/engine/cooking_step.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  group('CookingController', () {
    test('transitions through all gameplay steps', () async {
      final controller = CookingController(recipe: ghanaJollofRecipe);

      for (final ingredient in ghanaJollofRecipe.ingredients) {
        controller.onIngredientDropped(ingredient);
      }
      expect(controller.state.currentStep, CookingStep.stir);

      const size = Size(220, 220);
      const center = Offset(110, 110);
      const radius = 70.0;

      Offset pointAt(double angle) {
        return Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        );
      }

      controller.onStirStart(pointAt(0));
      for (int i = 1; i <= 120; i++) {
        final angle = i * 0.45;
        controller.onStirUpdate(pointAt(angle), size);
      }
      controller.onStirEnd();
      expect(controller.state.currentStep, CookingStep.spice);

      for (int i = 0; i < ghanaJollofRecipe.requiredSpiceShakes; i++) {
        controller.onSpiceMotion(100);
      }
      expect(controller.state.currentStep, CookingStep.serve);

      for (int i = 0; i < ghanaJollofRecipe.requiredServeScoops; i++) {
        await controller.onServeDropped();
      }
      expect(controller.state.currentStep, CookingStep.complete);
      expect(controller.state.isComplete, isTrue);
      expect(controller.state.stars, inInclusiveRange(1, 3));

      controller.dispose();
    });

    test('dispose closes notifiers to guard leaks', () {
      final controller = CookingController(recipe: ghanaJollofRecipe);
      controller.dispose();

      expect(
        () => controller.chefMessage.addListener(() {}),
        throwsA(isA<FlutterError>()),
      );
      expect(
        () => controller.state.addListener(() {}),
        throwsA(isA<FlutterError>()),
      );
    });
  });
}
