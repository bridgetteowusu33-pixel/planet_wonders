import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planet_wonders/features/draw_with_me/engine/trace_engine.dart';
import 'package:planet_wonders/features/draw_with_me/models/trace_segment.dart';
import 'package:planet_wonders/features/draw_with_me/models/trace_shape.dart';
import 'package:planet_wonders/features/draw_with_me/providers/trace_controller.dart';
import 'package:planet_wonders/features/draw_with_me/ui/trace_screen.dart';
import 'package:planet_wonders/features/draw_with_me/widgets/trace_canvas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pointer gesture along path advances trace progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [traceEngineProvider.overrideWithValue(_FakeTraceEngine())],
        child: const MaterialApp(
          home: TraceScreen(
            packId: 'test_pack',
            shapeId: 'line_shape',
            initialDifficulty: TraceDifficulty.easy,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    final canvasFinder = find.byType(TracingCanvas);
    expect(canvasFinder, findsOneWidget);

    final canvasRect = tester.getRect(canvasFinder);
    final y = canvasRect.center.dy;

    final gesture = await tester.startGesture(Offset(canvasRect.left + 36, y));

    for (var i = 0; i < 22; i++) {
      await gesture.moveBy(const Offset(12, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 150));

    final element = tester.element(find.byType(TraceScreen));
    final container = ProviderScope.containerOf(element, listen: false);
    final state = container.read(traceControllerProvider);

    expect(state.progress, greaterThan(0.01));
  });
}

class _FakeTraceEngine extends TraceEngine {
  @override
  Future<TraceShape> loadShape({
    required String packId,
    required String shapeId,
  }) async {
    return TraceShape(
      id: shapeId,
      packId: packId,
      title: 'Line Test',
      thumbnailEmoji: '✏️',
      viewBox: const Rect.fromLTWH(0, 0, 1000, 1000),
      segments: const [TraceSegment(pathData: 'M 100 500 L 900 500')],
    );
  }

  @override
  Future<List<TracePack>> loadPacks() async {
    return const <TracePack>[];
  }

  @override
  Future<List<TraceShape>> loadShapesForPack(String packId) async {
    return const <TraceShape>[];
  }
}
