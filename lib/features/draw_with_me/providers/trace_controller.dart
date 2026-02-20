// File: lib/features/draw_with_me/providers/trace_controller.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/trace_engine.dart';
import '../models/trace_shape.dart';
import '../tracing/engine/tracing_engine.dart';
import '../tracing/models/tracing_template.dart';

enum TraceAudioCue { followPath, greatJob, tryAgain, completed }

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class TraceState {
  const TraceState({
    required this.loading,
    required this.error,
    required this.packId,
    required this.shape,
    required this.difficulty,
    required this.segmentIndex,
    required this.progress,
    required this.completed,
    required this.segmentStrokes,
    required this.activeStroke,
    required this.hintGlowPoint,
    required this.showCompletionSparkles,
    required this.sparklePositions,
    required this.handVisible,
    required this.handCycle,
    required this.muted,
    required this.pendingAudioCue,
    required this.audioCueVersion,
    required this.layoutVersion,
  });

  factory TraceState.initial() {
    return const TraceState(
      loading: true,
      error: null,
      packId: null,
      shape: null,
      difficulty: TraceDifficulty.easy,
      segmentIndex: 0,
      progress: 0,
      completed: false,
      segmentStrokes: <List<Offset>>[],
      activeStroke: <Offset>[],
      hintGlowPoint: null,
      showCompletionSparkles: false,
      sparklePositions: <Offset>[],
      handVisible: true,
      handCycle: 0,
      muted: false,
      pendingAudioCue: null,
      audioCueVersion: 0,
      layoutVersion: 0,
    );
  }

  final bool loading;
  final String? error;
  final String? packId;
  final TraceShape? shape;
  final TraceDifficulty difficulty;
  final int segmentIndex;
  final double progress;
  final bool completed;
  final List<List<Offset>> segmentStrokes;
  final List<Offset> activeStroke;
  final Offset? hintGlowPoint;
  final bool showCompletionSparkles;
  final List<Offset> sparklePositions;
  final bool handVisible;
  final int handCycle;
  final bool muted;
  final TraceAudioCue? pendingAudioCue;
  final int audioCueVersion;
  final int layoutVersion;

  int get totalSegments => shape?.segments.length ?? 0;

  TraceState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    String? packId,
    TraceShape? shape,
    TraceDifficulty? difficulty,
    int? segmentIndex,
    double? progress,
    bool? completed,
    List<List<Offset>>? segmentStrokes,
    List<Offset>? activeStroke,
    Offset? hintGlowPoint,
    bool clearHintGlow = false,
    bool? showCompletionSparkles,
    List<Offset>? sparklePositions,
    bool? handVisible,
    int? handCycle,
    bool? muted,
    TraceAudioCue? pendingAudioCue,
    bool clearPendingAudioCue = false,
    int? audioCueVersion,
    int? layoutVersion,
  }) {
    return TraceState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      packId: packId ?? this.packId,
      shape: shape ?? this.shape,
      difficulty: difficulty ?? this.difficulty,
      segmentIndex: segmentIndex ?? this.segmentIndex,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      segmentStrokes: segmentStrokes ?? this.segmentStrokes,
      activeStroke: activeStroke ?? this.activeStroke,
      hintGlowPoint: clearHintGlow
          ? null
          : (hintGlowPoint ?? this.hintGlowPoint),
      showCompletionSparkles:
          showCompletionSparkles ?? this.showCompletionSparkles,
      sparklePositions: sparklePositions ?? this.sparklePositions,
      handVisible: handVisible ?? this.handVisible,
      handCycle: handCycle ?? this.handCycle,
      muted: muted ?? this.muted,
      pendingAudioCue: clearPendingAudioCue
          ? null
          : (pendingAudioCue ?? this.pendingAudioCue),
      audioCueVersion: audioCueVersion ?? this.audioCueVersion,
      layoutVersion: layoutVersion ?? this.layoutVersion,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final traceControllerProvider =
    NotifierProvider.autoDispose<TraceController, TraceState>(
      TraceController.new,
    );

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class TraceController extends Notifier<TraceState> {
  final TracingEngine _engine = TracingEngine();

  TracingEngine get engine => _engine;

  @override
  TraceState build() => TraceState.initial();

  // ---- Difficulty mapping ----

  static TracingDifficulty difficultyConfig(TraceDifficulty d) {
    switch (d) {
      case TraceDifficulty.easy:
        return TracingDifficulty.easy;
      case TraceDifficulty.medium:
        return TracingDifficulty.medium;
      case TraceDifficulty.hard:
        return TracingDifficulty.hard;
    }
  }

  // ---- Session lifecycle ----

  Future<void> loadSession({
    required String packId,
    required String shapeId,
    required TraceDifficulty difficulty,
  }) async {
    state = state.copyWith(
      loading: true,
      clearError: true,
      packId: packId,
      difficulty: difficulty,
      segmentIndex: 0,
      progress: 0,
      completed: false,
      segmentStrokes: const <List<Offset>>[],
      activeStroke: const <Offset>[],
      clearHintGlow: true,
      showCompletionSparkles: false,
      sparklePositions: const <Offset>[],
      handVisible: true,
      handCycle: 0,
      pendingAudioCue: null,
      audioCueVersion: state.audioCueVersion,
    );

    try {
      final loader = ref.read(traceEngineProvider);
      final shape = await loader.loadShape(packId: packId, shapeId: shapeId);
      final template = TracingTemplate.fromShape(shape, difficulty: difficulty);

      _engine.configureFromTemplate(
        template: template,
        canvasSize: _engine.canvasSize.isEmpty
            ? const Size(300, 300)
            : _engine.canvasSize,
        difficulty: difficultyConfig(difficulty),
      );

      state = state.copyWith(
        loading: false,
        shape: shape,
        segmentStrokes: List<List<Offset>>.generate(
          shape.segments.length,
          (_) => const <Offset>[],
        ),
        layoutVersion: state.layoutVersion + 1,
      );

      _queueAudio(TraceAudioCue.followPath);
    } catch (error) {
      state = state.copyWith(loading: false, error: '$error');
    }
  }

  void setViewportSize(Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final prev = _engine.canvasSize;
    if (!prev.isEmpty &&
        (prev.width - size.width).abs() < 0.5 &&
        (prev.height - size.height).abs() < 0.5) {
      return;
    }

    _engine.updateCanvasSize(size);
    state = state.copyWith(layoutVersion: state.layoutVersion + 1);
  }

  void setDifficulty(TraceDifficulty difficulty) {
    if (state.difficulty == difficulty) return;

    final shape = state.shape;
    if (shape == null) {
      state = state.copyWith(difficulty: difficulty);
      return;
    }

    // Reconfigure engine with new difficulty.
    final template = TracingTemplate.fromShape(shape, difficulty: difficulty);

    _engine.configureFromTemplate(
      template: template,
      canvasSize: _engine.canvasSize,
      difficulty: difficultyConfig(difficulty),
    );

    state = state.copyWith(
      difficulty: difficulty,
      segmentIndex: 0,
      progress: 0,
      completed: false,
      segmentStrokes: List<List<Offset>>.generate(
        shape.segments.length,
        (_) => const <Offset>[],
      ),
      activeStroke: const <Offset>[],
      clearHintGlow: true,
      showCompletionSparkles: false,
      sparklePositions: const <Offset>[],
      handVisible: true,
      handCycle: state.handCycle + 1,
      layoutVersion: state.layoutVersion + 1,
    );

    _queueAudio(TraceAudioCue.followPath);
  }

  // ---- Pointer events ----

  void startStroke(Offset screenPoint) {
    if (state.completed || state.shape == null) return;

    _engine.handlePointerDown(screenPoint);

    state = state.copyWith(
      activeStroke: const <Offset>[],
      handVisible: false,
      clearHintGlow: true,
    );
  }

  void addStrokePoint(Offset screenPoint) {
    if (state.completed || state.shape == null) return;

    final result = _engine.handlePointerMove(screenPoint);

    if (result.accepted) {
      state = state.copyWith(
        activeStroke: _engine.activeStrokePoints,
        segmentIndex: result.activeSegmentIndex,
        progress: result.totalProgress,
        clearHintGlow: true,
      );

      if (result.segmentCompleted) {
        _onSegmentCompleted(result);
      }
    } else if (result.distanceFromPath.isFinite) {
      // Off-path: show hint glow at closest point.
      state = state.copyWith(
        hintGlowPoint: result.closestScreenPoint,
        activeStroke: _engine.activeStrokePoints,
      );
    }
  }

  void endStroke() {
    if (state.completed) return;

    _engine.handlePointerUp();

    state = state.copyWith(activeStroke: const <Offset>[], clearHintGlow: true);
  }

  // ---- Segment / shape completion ----

  void _onSegmentCompleted(TracingPointResult result) {
    // Sync segment strokes from engine.
    state = state.copyWith(
      segmentStrokes: _engine.segmentStrokes,
      activeStroke: const <Offset>[],
      segmentIndex: result.activeSegmentIndex,
      progress: result.totalProgress,
      completed: result.allCompleted,
      clearHintGlow: true,
    );

    if (result.allCompleted) {
      _triggerCompletionCelebration();
      _queueAudio(TraceAudioCue.completed);
      return;
    }

    _queueAudio(TraceAudioCue.greatJob);

    // Show guiding hand for next segment.
    state = state.copyWith(handVisible: true, handCycle: state.handCycle + 1);
  }

  void _triggerCompletionCelebration() {
    // Generate sparkle positions along completed paths.
    final sparkles = <Offset>[];
    final rng = math.Random(42);

    for (final seg in _engine.segments) {
      final length = seg.length;
      // Place 3-4 sparkles per segment.
      final count = 3 + rng.nextInt(2);
      for (int i = 0; i < count; i++) {
        final d = (rng.nextDouble() * 0.8 + 0.1) * length;
        final point = seg.screenPointAt(d);
        if (point != null) {
          // Offset slightly from path for visual scatter.
          final jitter = Offset(
            (rng.nextDouble() - 0.5) * 40,
            (rng.nextDouble() - 0.5) * 40,
          );
          sparkles.add(point + jitter);
        }
      }
    }

    state = state.copyWith(
      showCompletionSparkles: true,
      sparklePositions: sparkles,
      handVisible: false,
    );
  }

  // ---- Hint / assist ----

  void requestHint({required bool animatedGuide}) {
    if (state.completed || state.shape == null) return;

    state = state.copyWith(
      handVisible: animatedGuide,
      handCycle: animatedGuide ? state.handCycle + 1 : state.handCycle,
      hintGlowPoint: _engine.hintPoint,
    );
    _queueAudio(TraceAudioCue.followPath);
  }

  void clearHintGlow() {
    if (state.hintGlowPoint == null) return;
    state = state.copyWith(clearHintGlow: true);
  }

  void resetTracing() {
    final shape = state.shape;
    if (shape == null) return;

    _engine.reset();

    state = state.copyWith(
      segmentIndex: 0,
      progress: 0,
      completed: false,
      segmentStrokes: List<List<Offset>>.generate(
        shape.segments.length,
        (_) => const <Offset>[],
      ),
      activeStroke: const <Offset>[],
      clearHintGlow: true,
      showCompletionSparkles: false,
      sparklePositions: const <Offset>[],
      handVisible: true,
      handCycle: state.handCycle + 1,
      layoutVersion: state.layoutVersion + 1,
    );

    _queueAudio(TraceAudioCue.followPath);
  }

  // ---- Audio ----

  void toggleMute() {
    state = state.copyWith(muted: !state.muted);
  }

  void consumeAudioCue() {
    if (state.pendingAudioCue == null) return;
    state = state.copyWith(clearPendingAudioCue: true);
  }

  void _queueAudio(TraceAudioCue cue) {
    if (state.muted) return;
    state = state.copyWith(
      pendingAudioCue: cue,
      audioCueVersion: state.audioCueVersion + 1,
    );
  }
}
