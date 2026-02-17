// File: lib/features/draw_with_me/widgets/trace_canvas.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../coloring_engine/core/spline_path.dart';
import '../engine/path_validator.dart';
import '../engine/trace_engine.dart';
import '../models/trace_shape.dart';
import '../providers/trace_controller.dart';
import 'guiding_hand.dart';

class TraceCanvas extends ConsumerStatefulWidget {
  const TraceCanvas({super.key, required this.repaintKey});

  final GlobalKey repaintKey;

  @override
  ConsumerState<TraceCanvas> createState() => _TraceCanvasState();
}

class _TraceCanvasState extends ConsumerState<TraceCanvas> {
  Size? _lastViewportSize;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(traceControllerProvider);
    final layoutVersion = ref.watch(
      traceControllerProvider.select((s) => s.layoutVersion),
    );
    final controller = ref.read(traceControllerProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        if (_lastViewportSize == null ||
            (_lastViewportSize!.width - size.width).abs() > 0.5 ||
            (_lastViewportSize!.height - size.height).abs() > 0.5) {
          _lastViewportSize = size;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            controller.setViewportSize(size);
          });
        }

        final layout = controller.layout;
        final activePath =
            (layout != null &&
                state.segmentIndex >= 0 &&
                state.segmentIndex < layout.segments.length)
            ? layout.segments[state.segmentIndex].path
            : null;

        final config = TraceValidationConfig.fromDifficulty(state.difficulty);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) =>
              controller.startStroke(details.localPosition),
          onPanUpdate: (details) =>
              controller.addStrokePoint(details.localPosition),
          onPanEnd: (_) => controller.endStroke(),
          child: RepaintBoundary(
            key: widget.repaintKey,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _TracePainter(
                      state: state,
                      layout: layout,
                      config: config,
                      layoutVersion: layoutVersion,
                    ),
                    child: const SizedBox.expand(),
                  ),
                  GuidingHand(
                    path: activePath,
                    visible: state.handVisible && !state.completed,
                    cycle: state.handCycle,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({
    required this.state,
    required this.layout,
    required this.config,
    required this.layoutVersion,
  });

  final TraceState state;
  final TraceLayout? layout;
  final TraceValidationConfig config;
  final int layoutVersion;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final resolvedLayout = layout;
    if (resolvedLayout == null) {
      return;
    }

    final guidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFB7C4D4);

    final activeGuidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          config.strokeWidth +
          (state.difficulty == TraceDifficulty.easy ? 2 : 1)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF5C78A5);

    final doneGuidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF59B97A);

    for (int i = 0; i < resolvedLayout.segments.length; i++) {
      final segmentPath = resolvedLayout.segments[i].path;

      if (i < state.segmentIndex || state.completed) {
        canvas.drawPath(segmentPath, doneGuidePaint);
      } else if (i == state.segmentIndex) {
        if (state.difficulty == TraceDifficulty.hard || !config.dotted) {
          canvas.drawPath(segmentPath, activeGuidePaint);
        } else {
          _drawDottedPath(canvas, segmentPath, activeGuidePaint, gap: 7);
        }
      } else {
        if (state.difficulty == TraceDifficulty.easy) {
          _drawDottedPath(canvas, segmentPath, guidePaint, gap: 8);
        } else {
          canvas.drawPath(segmentPath, guidePaint);
        }
      }
    }

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = config.strokeWidth + 1
      ..color = const Color(0xFF1F7CF0);

    for (final stroke in state.segmentStrokes) {
      if (stroke.length < 2) continue;
      final path = buildSplinePath(stroke);
      canvas.drawPath(path, strokePaint);
    }

    if (state.activeStroke.isNotEmpty) {
      final activeStrokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = config.strokeWidth + 1
        ..color = const Color(0xFF1F7CF0);

      final points = state.activeStroke;
      if (points.length == 1) {
        canvas.drawCircle(
          points.first,
          activeStrokePaint.strokeWidth / 2,
          activeStrokePaint,
        );
      } else {
        canvas.drawPath(buildSplinePath(points), activeStrokePaint);
      }
    }
  }

  void _drawDottedPath(
    Canvas canvas,
    Path path,
    Paint basePaint, {
    double gap = 8,
  }) {
    for (final metric in path.computeMetrics(forceClosed: false)) {
      for (double d = 0; d < metric.length; d += gap * 2) {
        final segment = metric.extractPath(
          d,
          (d + gap).clamp(0, metric.length),
        );
        canvas.drawPath(segment, basePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.layoutVersion != layoutVersion ||
        oldDelegate.layout != layout;
  }
}
