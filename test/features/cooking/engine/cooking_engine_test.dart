import 'package:flutter_test/flutter_test.dart';
import 'package:planet_wonders/features/cooking/data/ghana_recipes.dart';
import 'package:planet_wonders/features/cooking/engine/cooking_engine.dart';

void main() {
  group('CookingEngine', () {
    test(
      'evaluateStirGesture returns positive deltas for circular movement',
      () {
        const engine = CookingEngine();
        final sample = engine.evaluateStirGesture(
          center: const Offset(100, 100),
          previousPoint: const Offset(150, 100),
          currentPoint: const Offset(100, 150),
          delta: const Duration(milliseconds: 16),
        );

        expect(sample.progressDelta, greaterThan(0));
        expect(sample.angularVelocity, greaterThan(0));
      },
    );

    test('evaluateStirGesture ignores tiny center noise', () {
      const engine = CookingEngine();
      final sample = engine.evaluateStirGesture(
        center: const Offset(100, 100),
        previousPoint: const Offset(101, 101),
        currentPoint: const Offset(102, 102),
        delta: const Duration(milliseconds: 16),
      );

      expect(sample.progressDelta, 0);
      expect(sample.angularVelocity, 0);
    });

    test('calculateScore returns stronger score for cleaner run', () async {
      const engine = CookingEngine();

      final strong = await engine.calculateScore(
        recipe: ghanaJollofRecipe,
        mistakes: 0,
        maxCombo: 12,
        totalDuration: const Duration(seconds: 24),
        stirVelocities: const <double>[3.2, 3.4, 3.0, 3.1],
        successfulActions: 24,
      );

      final weak = await engine.calculateScore(
        recipe: ghanaJollofRecipe,
        mistakes: 8,
        maxCombo: 2,
        totalDuration: const Duration(seconds: 90),
        stirVelocities: const <double>[0.4, 7.8, 0.2],
        successfulActions: 8,
      );

      expect(strong.stars, greaterThanOrEqualTo(weak.stars));
      expect(strong.accuracy, greaterThan(weak.accuracy));
      expect(strong.speed, greaterThan(weak.speed));
    });
  });
}
