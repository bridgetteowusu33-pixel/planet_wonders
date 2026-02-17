// File: lib/features/draw_with_me/providers/trace_controller.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/path_validator.dart';
import '../engine/trace_engine.dart';
import '../models/trace_shape.dart';

enum TraceAudioCue { followPath, greatJob, tryAgain, completed }

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
    required this.activeCoverage,
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
      activeCoverage: 0,
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
  final double activeCoverage;
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
    double? activeCoverage,
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
      activeCoverage: activeCoverage ?? this.activeCoverage,
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

final traceControllerProvider =
    NotifierProvider.autoDispose<TraceController, TraceState>(
      TraceController.new,
    );

class TraceController extends Notifier<TraceState> {
  static const double _minPointDistanceSquared = 10.24; // 3.2px
  final PathValidator _validator = const PathValidator();

  TraceLayout? _layout;
  Size? _viewportSize;

  TraceLayout? get layout => _layout;

  @override
  TraceState build() {
    return TraceState.initial();
  }

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
      activeCoverage: 0,
      handVisible: true,
      handCycle: 0,
      pendingAudioCue: null,
      audioCueVersion: state.audioCueVersion,
    );

    try {
      final engine = ref.read(traceEngineProvider);
      final shape = await engine.loadShape(packId: packId, shapeId: shapeId);

      _layout = null;
      if (_viewportSize != null && _viewportSize!.longestSide > 0) {
        _layout = engine.buildLayout(shape: shape, size: _viewportSize!);
      }

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

    final prev = _viewportSize;
    if (prev != null &&
        (prev.width - size.width).abs() < 0.5 &&
        (prev.height - size.height).abs() < 0.5) {
      return;
    }

    _viewportSize = size;

    final shape = state.shape;
    if (shape == null) return;

    final engine = ref.read(traceEngineProvider);
    _layout = engine.buildLayout(shape: shape, size: size);

    state = state.copyWith(layoutVersion: state.layoutVersion + 1);
  }

  void setDifficulty(TraceDifficulty difficulty) {
    if (state.difficulty == difficulty) return;

    state = state.copyWith(difficulty: difficulty);

    // Re-evaluate current active stroke under the new tolerance.
    if (state.activeStroke.isNotEmpty) {
      _updateCoverageForActiveStroke();
    }
  }

  void toggleMute() {
    state = state.copyWith(muted: !state.muted);
  }

  void consumeAudioCue() {
    if (state.pendingAudioCue == null) return;
    state = state.copyWith(clearPendingAudioCue: true);
  }

  void startStroke(Offset point) {
    if (state.completed || state.shape == null) return;

    state = state.copyWith(
      activeStroke: <Offset>[point],
      handVisible: false,
      activeCoverage: 0,
    );
  }

  void addStrokePoint(Offset point) {
    final active = state.activeStroke;
    if (active.isEmpty || state.completed) return;

    final last = active.last;
    final dx = point.dx - last.dx;
    final dy = point.dy - last.dy;
    if ((dx * dx + dy * dy) < _minPointDistanceSquared) {
      return; // touch sampling debounce
    }

    final nextStroke = [...active, point];
    state = state.copyWith(activeStroke: nextStroke, handVisible: false);

    _updateCoverageForActiveStroke();
  }

  void endStroke() {
    if (state.completed || state.activeStroke.isEmpty) return;

    final result = _currentValidationResult();
    final config = TraceValidationConfig.fromDifficulty(state.difficulty);

    if (result.completed) {
      _completeCurrentSegment(points: state.activeStroke);
      return;
    }

    final canAssist =
        state.difficulty == TraceDifficulty.easy && result.suggestAutoComplete;

    if (canAssist) {
      _completeCurrentSegment(points: state.activeStroke, assisted: true);
      return;
    }

    state = state.copyWith(activeStroke: const <Offset>[], activeCoverage: 0);

    if (result.coverage < config.autoCompleteCoverage) {
      _queueAudio(TraceAudioCue.tryAgain);
    }
  }

  void requestHint() {
    if (state.completed || state.shape == null) return;

    if (state.difficulty == TraceDifficulty.easy) {
      final activePath = _activeSegmentPath();
      if (activePath != null) {
        _completeCurrentSegment(
          points: _samplePreview(activePath),
          assisted: true,
        );
        return;
      }
    }

    state = state.copyWith(handVisible: true, handCycle: state.handCycle + 1);
    _queueAudio(TraceAudioCue.followPath);
  }

  Path? _activeSegmentPath() {
    final layout = _layout;
    if (layout == null || state.segmentIndex >= layout.segments.length) {
      return null;
    }
    return layout.segments[state.segmentIndex].path;
  }

  List<Offset> _samplePreview(Path path) {
    return _validator.samplePath(path, spacing: 14);
  }

  void _updateCoverageForActiveStroke() {
    final result = _currentValidationResult();

    final totalSegments = math.max(1, state.totalSegments);
    final completedSegments = state.segmentIndex;
    final progress =
        ((completedSegments + result.coverage.clamp(0.0, 1.0)) / totalSegments)
            .clamp(0.0, 1.0)
            .toDouble();

    state = state.copyWith(activeCoverage: result.coverage, progress: progress);

    if (result.completed) {
      _completeCurrentSegment(points: state.activeStroke);
    }
  }

  TraceValidationResult _currentValidationResult() {
    final layout = _layout;
    final segmentIndex = state.segmentIndex;
    if (layout == null ||
        segmentIndex < 0 ||
        segmentIndex >= layout.segments.length ||
        state.activeStroke.isEmpty) {
      return const TraceValidationResult(
        coverage: 0,
        completed: false,
        suggestAutoComplete: false,
      );
    }

    final segment = layout.segments[segmentIndex];
    final config = TraceValidationConfig.fromDifficulty(state.difficulty);

    return _validator.evaluate(
      sampledPathPoints: segment.samplePoints,
      userPoints: state.activeStroke,
      config: config,
    );
  }

  void _completeCurrentSegment({
    required List<Offset> points,
    bool assisted = false,
  }) {
    final shape = state.shape;
    if (shape == null) return;

    final index = state.segmentIndex;
    if (index < 0 || index >= shape.segments.length) return;

    final updatedSegments = [...state.segmentStrokes];
    updatedSegments[index] = points.isEmpty ? const <Offset>[] : [...points];

    final nextIndex = index + 1;
    final total = math.max(1, shape.segments.length);
    final completed = nextIndex >= shape.segments.length;

    state = state.copyWith(
      segmentStrokes: updatedSegments,
      segmentIndex: completed ? index : nextIndex,
      completed: completed,
      activeStroke: const <Offset>[],
      activeCoverage: 0,
      progress: completed ? 1.0 : (nextIndex / total),
      handVisible: !completed,
      handCycle: state.handCycle + 1,
    );

    if (completed) {
      _queueAudio(TraceAudioCue.completed);
      return;
    }

    _queueAudio(TraceAudioCue.greatJob);

    if (assisted) {
      _queueAudio(TraceAudioCue.followPath);
    }
  }

  void _queueAudio(TraceAudioCue cue) {
    if (state.muted) return;

    state = state.copyWith(
      pendingAudioCue: cue,
      audioCueVersion: state.audioCueVersion + 1,
    );
  }
}
