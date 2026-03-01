import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/motion_settings_provider.dart';
import '../../providers/trace_controller.dart';
import '../../widgets/guiding_hand.dart';
import '../animations/segment_animations.dart';
import '../painters/animated_segment_painter.dart';
import '../painters/decoration_painter.dart';
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
    with TickerProviderStateMixin {
  late final AnimationController _fxController;
  late final AnimationController _segAnimController;
  final ValueNotifier<int> _strokeRepaint = ValueNotifier<int>(0);
  int? _activePointer;

  int _lastSegmentIndex = 0;
  int? _animatingSegmentIndex;
  SegmentAnimationType _animationType = SegmentAnimationType.none;
  Offset? _segmentBurstCenter;
  bool _jumpActive = false;

  @override
  void initState() {
    super.initState();
    _fxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _segAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _segAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animatingSegmentIndex = null;
          _animationType = SegmentAnimationType.none;
          _segmentBurstCenter = null;
          _jumpActive = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fxController.dispose();
    _segAnimController.dispose();
    _strokeRepaint.dispose();
    super.dispose();
  }

  void _onSegmentTransition(int newIndex, bool allCompleted) {
    final engine = ref.read(traceControllerProvider.notifier).engine;
    final completedIndex = newIndex - 1;

    if (completedIndex < 0 || completedIndex >= engine.segments.length) return;

    final segment = engine.segments[completedIndex];
    final shape = ref.read(traceControllerProvider).shape;
    final segId = (shape != null &&
            completedIndex < shape.segmentIds.length)
        ? shape.segmentIds[completedIndex]
        : '';

    // Determine animation type from segment ID.
    SegmentAnimationType type;
    int durationMs;
    if (segId.contains('ear') ||
        segId.contains('whisker') ||
        segId.contains('antenna') ||
        segId.contains('fin')) {
      type = SegmentAnimationType.earWiggle;
      durationMs = 400;
    } else if (segId.contains('wing')) {
      type = SegmentAnimationType.wingFlutter;
      durationMs = 400;
    } else if (segId == 'tail') {
      type = SegmentAnimationType.tailWag;
      durationMs = 500;
    } else {
      type = SegmentAnimationType.none;
      durationMs = 400;
    }

    // Compute burst center at midpoint of the completed segment.
    final midPoint = segment.screenPointAt(segment.length / 2);

    setState(() {
      _animatingSegmentIndex = completedIndex;
      _animationType = type;
      _segmentBurstCenter = midPoint;
      _jumpActive = allCompleted;
    });

    _segAnimController.duration = Duration(milliseconds: durationMs);
    _segAnimController.reset();
    _segAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(traceControllerProvider);
    final notifier = ref.read(traceControllerProvider.notifier);
    final engine = notifier.engine;
    final reduceMotion = MotionUtil.isReduced(ref);

    // Detect segment transitions.
    if (state.segmentIndex != _lastSegmentIndex && !state.loading) {
      final prevIndex = _lastSegmentIndex;
      _lastSegmentIndex = state.segmentIndex;
      if (state.segmentIndex > prevIndex && !reduceMotion) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _onSegmentTransition(state.segmentIndex, state.completed);
          }
        });
      }
    }

    final animateGuide = !reduceMotion && !state.completed;
    final animateEffects =
        !reduceMotion &&
        (state.hintGlowPoint != null ||
            state.showCompletionSparkles ||
            _segmentBurstCenter != null);

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

          // Build the animating segments set for GuidePainter.
          final animatingSet = <int>{};
          if (_animatingSegmentIndex != null) {
            animatingSet.add(_animatingSegmentIndex!);
          }

          // Compute animation values.
          final segAnimT = _segAnimController.value;
          double segAngle = 0;
          if (_animatingSegmentIndex != null) {
            switch (_animationType) {
              case SegmentAnimationType.earWiggle:
                segAngle = earWiggleAngle(segAnimT);
              case SegmentAnimationType.wingFlutter:
                segAngle = wingFlutterAngle(segAnimT);
              case SegmentAnimationType.tailWag:
                segAngle = tailWagAngle(segAnimT);
              case SegmentAnimationType.none:
                break;
            }
          }

          final jumpDy =
              _jumpActive && !reduceMotion ? jumpOffset(segAnimT) : 0.0;

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
              child: Transform.translate(
                offset: Offset(0, jumpDy),
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
                              animatingSegments: animatingSet,
                            ),
                            child: const SizedBox.expand(),
                          );
                        },
                      ),
                    ),

                    // Animated segment overlay (ear wiggle / tail wag).
                    if (_animatingSegmentIndex != null &&
                        _animationType != SegmentAnimationType.none)
                      RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _segAnimController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: AnimatedSegmentPainter(
                                segment:
                                    engine.segments[_animatingSegmentIndex!],
                                animationType: _animationType,
                                angle: segAngle,
                                strokeWidth: difficulty.guideStrokeWidth,
                              ),
                              child: const SizedBox.expand(),
                            );
                          },
                        ),
                      ),

                    if (state.shape?.decorations != null)
                      RepaintBoundary(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: state.segmentIndex >
                                  state.shape!.decorations!.revealAfterSegment
                              ? 1.0
                              : state.completed
                                  ? 1.0
                                  : 0.0,
                          child: CustomPaint(
                            painter: DecorationPainter(
                              decorations: state.shape!.decorations!,
                              scale: engine.scale,
                              tx: engine.tx,
                              ty: engine.ty,
                              opacity: state.segmentIndex >
                                      state.shape!.decorations!
                                          .revealAfterSegment
                                  ? 1.0
                                  : state.completed
                                      ? 1.0
                                      : 0.0,
                            ),
                            child: const SizedBox.expand(),
                          ),
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
                        (state.showCompletionSparkles && !reduceMotion) ||
                        _segmentBurstCenter != null)
                      RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _fxController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: EffectsPainter(
                                hintGlowPoint: state.hintGlowPoint,
                                showCompletionSparkles:
                                    state.showCompletionSparkles &&
                                    !reduceMotion,
                                sparklePositions: state.sparklePositions,
                                sparklePhase: _fxController.value,
                                reduceMotion: reduceMotion,
                                repaintTick: state.layoutVersion + tick,
                                segmentBurstCenter: _segmentBurstCenter,
                                segmentBurstPhase: _segAnimController.value,
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
            ),
          );
        },
      ),
    );
  }
}
