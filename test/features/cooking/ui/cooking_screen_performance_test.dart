import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planet_wonders/features/cooking/ui/cooking_screen.dart';
import 'package:planet_wonders/features/cooking/ui/pot_widget.dart';

void main() {
  testWidgets('cooking screen handles rapid stir input without exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1536, 2048);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: CookingScreen()));

    // Move into stir step quickly by tapping each ingredient card.
    for (final name in const <String>['Rice', 'Tomato', 'Onion', 'Pepper']) {
      await tester.tap(find.text(name));
      await tester.pump(const Duration(milliseconds: 40));
    }

    final potFinder = find.byType(PotWidget);
    expect(potFinder, findsOneWidget);

    final potCenter = tester.getCenter(potFinder);
    final gesture = await tester.startGesture(potCenter + const Offset(48, 0));

    for (int i = 0; i < 120; i++) {
      final angle = i * 0.22;
      final target =
          potCenter + Offset(math.cos(angle) * 48, math.sin(angle) * 48);
      await gesture.moveTo(target);
      await tester.pump(const Duration(milliseconds: 8));
    }
    await gesture.up();

    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.takeException(), isNull);
  });

  testWidgets('screen unmounts cleanly without ticker leaks', (tester) async {
    tester.view.physicalSize = const Size(1536, 2048);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: CookingScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
