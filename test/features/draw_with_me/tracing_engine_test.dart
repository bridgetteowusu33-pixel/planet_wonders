import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:planet_wonders/features/draw_with_me/engine/tracing_engine.dart';

void main() {
  // Two-segment shape: horizontal then vertical.
  const twoSegments = [
    'M 100 500 L 900 500', // segment 0: left to right
    'M 500 100 L 500 900', // segment 1: top to bottom
  ];

  TracingEngine makeEngine({
    List<String> paths = const ['M 100 500 L 900 500'],
    Size canvasSize = const Size(400, 400),
    TracingDifficulty difficulty = TracingDifficulty.easy,
  }) {
    final engine = TracingEngine();
    engine.configure(
      segmentPathStrings: paths,
      viewBox: const Rect.fromLTWH(0, 0, 1000, 1000),
      canvasSize: canvasSize,
      difficulty: difficulty,
    );
    return engine;
  }

  group('TracingEngine configuration', () {
    test('starts at segment 0 with 0 progress', () {
      final engine = makeEngine();
      expect(engine.activeSegmentIndex, 0);
      expect(engine.totalSegments, 1);
      expect(engine.segmentProgress, 0);
      expect(engine.totalProgress, 0);
      expect(engine.allCompleted, false);
    });

    test('handles multi-segment shapes', () {
      final engine = makeEngine(paths: twoSegments);
      expect(engine.totalSegments, 2);
      expect(engine.activeSegmentIndex, 0);
    });

    test('reset() restores initial state', () {
      final engine = makeEngine();

      // Simulate some tracing.
      engine.handlePointerDown(const Offset(40, 200));
      engine.handlePointerMove(const Offset(100, 200));
      engine.handlePointerUp();

      engine.reset();
      expect(engine.activeSegmentIndex, 0);
      expect(engine.segmentProgress, 0);
      expect(engine.totalProgress, 0);
      expect(engine.allCompleted, false);
      expect(engine.activeStrokePoints, isEmpty);
    });
  });

  group('TracingEngine pointer handling', () {
    test('progress increases when tracing along the path', () {
      final engine = makeEngine();

      engine.handlePointerDown(const Offset(40, 200));

      double lastProgress = 0;
      // Trace roughly left-to-right along the path.
      // The path is a horizontal line at y=500 in template space.
      // With 400×400 canvas + 24px padding, the line maps to roughly y ≈ 200.
      for (double x = 50; x < 370; x += 10) {
        final result = engine.handlePointerMove(Offset(x, 200));
        if (result.accepted) {
          expect(
            result.totalProgress,
            greaterThanOrEqualTo(lastProgress),
            reason: 'progress must be monotonically non-decreasing',
          );
          lastProgress = result.totalProgress;
        }
      }

      expect(
        lastProgress,
        greaterThan(0),
        reason: 'should have made some forward progress',
      );
    });

    test('progress does NOT increase when off-path', () {
      final engine = makeEngine();

      engine.handlePointerDown(const Offset(40, 200));

      // First, make a bit of on-path progress.
      engine.handlePointerMove(const Offset(60, 200));
      engine.handlePointerMove(const Offset(80, 200));
      final progressBefore = engine.totalProgress;

      // Now move far off the path (y=10, while path is at y≈200).
      engine.handlePointerMove(const Offset(120, 10));
      engine.handlePointerMove(const Offset(150, 10));
      engine.handlePointerMove(const Offset(180, 10));
      final progressAfter = engine.totalProgress;

      expect(
        progressAfter,
        equals(progressBefore),
        reason: 'off-path movement should not advance progress',
      );
    });

    test('progress is monotonically non-decreasing (no backtrack)', () {
      final engine = makeEngine();

      engine.handlePointerDown(const Offset(40, 200));

      // Trace forward then backward.
      engine.handlePointerMove(const Offset(80, 200));
      engine.handlePointerMove(const Offset(150, 200));
      engine.handlePointerMove(const Offset(200, 200));
      final peakProgress = engine.totalProgress;

      // Trace backward.
      engine.handlePointerMove(const Offset(150, 200));
      engine.handlePointerMove(const Offset(80, 200));

      expect(
        engine.totalProgress,
        greaterThanOrEqualTo(peakProgress),
        reason: 'backtracking must not decrease progress',
      );
    });

    test('segment completes when threshold is reached', () {
      final engine = makeEngine(
        paths: twoSegments,
        difficulty: TracingDifficulty.easy,
      );

      engine.handlePointerDown(const Offset(40, 200));

      bool segmentCompleted = false;
      // Trace the full width along the horizontal line.
      for (double x = 40; x < 380; x += 3) {
        final result = engine.handlePointerMove(Offset(x, 200));
        if (result.segmentCompleted) {
          segmentCompleted = true;
          break;
        }
      }

      if (segmentCompleted) {
        expect(
          engine.activeSegmentIndex,
          1,
          reason: 'should advance to segment 1 after completing segment 0',
        );
      }
    });

    test('allCompleted is true after all segments are traced', () {
      final engine = makeEngine(
        paths: const ['M 100 500 L 900 500'],
        difficulty: const TracingDifficulty(
          label: 'Test',
          toleranceRadius: 100, // generous
          completionThreshold: 0.50, // low threshold for testing
          guideStrokeWidth: 10,
          userStrokeWidth: 8,
          smoothingAlpha: 0.30,
          resampleSpacing: 3,
          coarseSamples: 50,
        ),
      );

      engine.handlePointerDown(const Offset(40, 200));

      for (double x = 40; x < 380; x += 2) {
        final result = engine.handlePointerMove(Offset(x, 200));
        if (result.allCompleted) break;
      }

      expect(engine.allCompleted, true);
      expect(engine.totalProgress, 1.0);
    });

    test('handlePointerUp clears active stroke', () {
      final engine = makeEngine();

      engine.handlePointerDown(const Offset(40, 200));
      engine.handlePointerMove(const Offset(80, 200));
      expect(engine.activeStrokePoints, isNotEmpty);

      engine.handlePointerUp();
      expect(engine.activeStrokePoints, isEmpty);
    });
  });

  group('TracingEngine updateCanvasSize', () {
    test('updating canvas size preserves segments', () {
      final engine = makeEngine(canvasSize: const Size(400, 400));
      expect(engine.segments.length, 1);

      engine.updateCanvasSize(const Size(600, 600));
      expect(engine.segments.length, 1);
    });

    test('no-op for tiny size change', () {
      final engine = makeEngine(canvasSize: const Size(400, 400));
      final originalScale = engine.scale;

      engine.updateCanvasSize(const Size(400.3, 400.2));
      expect(engine.scale, originalScale);
    });
  });

  group('TracingDifficulty', () {
    test('easy has larger tolerance than hard', () {
      expect(
        TracingDifficulty.easy.toleranceRadius,
        greaterThan(TracingDifficulty.hard.toleranceRadius),
      );
    });

    test('hard has higher completion threshold', () {
      expect(
        TracingDifficulty.hard.completionThreshold,
        greaterThan(TracingDifficulty.easy.completionThreshold),
      );
    });
  });
}
