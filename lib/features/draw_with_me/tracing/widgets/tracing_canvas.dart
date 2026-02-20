import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/motion_settings_provider.dart';
import '../../providers/trace_controller.dart';
import '../../widgets/guiding_hand.dart';
import '../painters/effects_painter.dart';
import '../painters/guide_painter.dart';
import '../painters/stroke_painter.dart';

class TracingCanvas extends ConsumerStatefulWidget {
  const TracingCanvas({super.key, required this.repaintKey});

  final GlobalKey repaintKey;

  @override
  ConsumerState<TracingCanvas> createState() => _TracingCanvasState();
}

class _TracingCanvasState extends ConsumerState<TracingCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fxController;
  final ValueNotifier<int> _strokeRepaint = ValueNotifier<int>(0);
  int? _activePointer;

  @override
  void initState() {
    super.initState();
    _fxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _fxController.dispose();
    _strokeRepaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(traceControllerProvider);
    final notifier = ref.read(traceControllerProvider.notifier);
    final engine = notifier.engine;
    final reduceMotion = MotionUtil.isReduced(ref);

    final animateGuide = !reduceMotion && !state.completed;
    final animateEffects =
        !reduceMotion &&
        (state.hintGlowPoint != null || state.showCompletionSparkles);

    if ((animateGuide || animateEffects) && !_fxController.isAnimating) {
      _fxController.repeat();
    } else if (!animateGuide && !animateEffects && _fxController.isAnimating) {
      _fxController.stop(canceled: false);
    }

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            notifier.setViewportSize(size);
          });

          Path? activePath;
          if (!state.completed &&
              state.segmentIndex >= 0 &&
              state.segmentIndex < engine.segments.length) {
            activePath = engine.segments[state.segmentIndex].screenPath;
          }

          final difficulty = TraceController.difficultyConfig(state.difficulty);
          final tick = (_fxController.value * 1000).floor();

          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              _activePointer = event.pointer;
              notifier.startStroke(event.localPosition);
              _strokeRepaint.value++;
            },
            onPointerMove: (event) {
              if (_activePointer != event.pointer) return;
              notifier.addStrokePoint(event.localPosition);
              _strokeRepaint.value++;
            },
            onPointerUp: (event) {
              if (_activePointer == event.pointer) {
                notifier.endStroke();
                _activePointer = null;
                _strokeRepaint.value++;
              }
            },
            onPointerCancel: (event) {
              if (_activePointer == event.pointer) {
                notifier.endStroke();
                _activePointer = null;
                _strokeRepaint.value++;
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const RepaintBoundary(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFFFFF), Color(0xFFF6FAFF)],
                        ),
                      ),
                    ),
                  ),

                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _fxController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: GuidePainter(
                            segments: engine.segments,
                            activeSegmentIndex: state.segmentIndex,
                            segmentProgress: engine.segmentProgress,
                            allCompleted: state.completed,
                            guideStrokeWidth: difficulty.guideStrokeWidth,
                            reduceMotion: reduceMotion,
                            chevronPhase: reduceMotion
                                ? 0
                                : _fxController.value,
                            repaintTick: state.layoutVersion + tick,
                          ),
                          child: const SizedBox.expand(),
                        );
                      },
                    ),
                  ),

                  RepaintBoundary(
                    key: widget.repaintKey,
                    child: CustomPaint(
                      painter: StrokePainter(
                        segmentStrokes: state.segmentStrokes,
                        activeStrokePoints: state.activeStroke,
                        strokeWidth: difficulty.userStrokeWidth,
                        repaintTick: _strokeRepaint.value,
                        repaint: _strokeRepaint,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),

                  if (state.hintGlowPoint != null ||
                      (state.showCompletionSparkles && !reduceMotion))
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _fxController,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: EffectsPainter(
                              hintGlowPoint: state.hintGlowPoint,
                              showCompletionSparkles:
                                  state.showCompletionSparkles && !reduceMotion,
                              sparklePositions: state.sparklePositions,
                              sparklePhase: _fxController.value,
                              reduceMotion: reduceMotion,
                              repaintTick: state.layoutVersion + tick,
                            ),
                            child: const SizedBox.expand(),
                          );
                        },
                      ),
                    ),

                  GuidingHand(
                    path: activePath,
                    visible: state.handVisible && !state.completed,
                    cycle: state.handCycle,
                    reduceMotion: reduceMotion,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
