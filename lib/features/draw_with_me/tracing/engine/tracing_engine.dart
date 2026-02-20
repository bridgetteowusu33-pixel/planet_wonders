import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

import '../models/tracing_template.dart';

class TracingDifficulty {
  const TracingDifficulty({
    required this.label,
    required this.toleranceRadius,
    required this.completionThreshold,
    required this.guideStrokeWidth,
    required this.userStrokeWidth,
    required this.smoothingAlpha,
    required this.resampleSpacing,
    required this.coarseSamples,
  });

  final String label;
  final double toleranceRadius;
  final double completionThreshold;
  final double guideStrokeWidth;
  final double userStrokeWidth;
  final double smoothingAlpha;
  final double resampleSpacing;
  final int coarseSamples;

  static const easy = TracingDifficulty(
    label: 'Easy',
    toleranceRadius: 36,
    completionThreshold: 0.95,
    guideStrokeWidth: 14,
    userStrokeWidth: 11,
    smoothingAlpha: 0.35,
    resampleSpacing: 7,
    coarseSamples: 40,
  );

  static const medium = TracingDifficulty(
    label: 'Medium',
    toleranceRadius: 26,
    completionThreshold: 0.96,
    guideStrokeWidth: 10,
    userStrokeWidth: 8,
    smoothingAlpha: 0.35,
    resampleSpacing: 8,
    coarseSamples: 42,
  );

  static const hard = TracingDifficulty(
    label: 'Hard',
    toleranceRadius: 18,
    completionThreshold: 0.97,
    guideStrokeWidth: 7,
    userStrokeWidth: 6,
    smoothingAlpha: 0.35,
    resampleSpacing: 9,
    coarseSamples: 46,
  );
}

class TracingPointResult {
  const TracingPointResult({
    required this.accepted,
    required this.segmentProgress,
    required this.totalProgress,
    required this.segmentCompleted,
    required this.allCompleted,
    required this.closestScreenPoint,
    required this.distanceFromPath,
    required this.activeSegmentIndex,
  });

  final bool accepted;
  final double segmentProgress;
  final double totalProgress;
  final bool segmentCompleted;
  final bool allCompleted;
  final Offset closestScreenPoint;
  final double distanceFromPath;
  final int activeSegmentIndex;
}

class SegmentData {
  SegmentData({
    required this.index,
    required this.templatePath,
    required this.screenPath,
    required this.templateMetrics,
    required this.templateMetricEnds,
    required this.screenMetrics,
    required this.screenMetricEnds,
    required this.length,
  });

  final int index;
  final Path templatePath;
  final Path screenPath;
  final List<PathMetric> templateMetrics;
  final List<double> templateMetricEnds;
  final List<PathMetric> screenMetrics;
  final List<double> screenMetricEnds;
  final double length;

  PathMetric get metric => templateMetrics.first;

  Offset? templatePointAt(double distance) {
    return _pointAt(
      metrics: templateMetrics,
      metricEnds: templateMetricEnds,
      distance: distance,
    );
  }

  Offset? screenPointAt(double distance) {
    return _pointAt(
      metrics: screenMetrics,
      metricEnds: screenMetricEnds,
      distance: distance,
    );
  }

  Path extractScreenPathTo(double distance) {
    return _extractPathTo(
      metrics: screenMetrics,
      metricEnds: screenMetricEnds,
      distance: distance,
    );
  }

  Path extractTemplatePathTo(double distance) {
    return _extractPathTo(
      metrics: templateMetrics,
      metricEnds: templateMetricEnds,
      distance: distance,
    );
  }

  Offset? _pointAt({
    required List<PathMetric> metrics,
    required List<double> metricEnds,
    required double distance,
  }) {
    final match = _metricForDistance(
      metrics: metrics,
      metricEnds: metricEnds,
      distance: distance,
    );
    if (match == null) return null;
    return match.metric.getTangentForOffset(match.localDistance)?.position;
  }

  Path _extractPathTo({
    required List<PathMetric> metrics,
    required List<double> metricEnds,
    required double distance,
  }) {
    final clamped = distance.clamp(0.0, length);
    final output = Path();
    var consumed = 0.0;

    for (var i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final end = metricEnds[i];
      if (clamped >= end) {
        output.addPath(metric.extractPath(0, metric.length), Offset.zero);
        consumed = end;
        continue;
      }

      final local = (clamped - consumed).clamp(0.0, metric.length);
      output.addPath(metric.extractPath(0, local), Offset.zero);
      break;
    }

    return output;
  }

  _MetricMatch? _metricForDistance({
    required List<PathMetric> metrics,
    required List<double> metricEnds,
    required double distance,
  }) {
    if (metrics.isEmpty) return null;

    final clampedDistance = distance.clamp(0.0, length);
    var start = 0.0;

    for (var i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final end = metricEnds[i];
      if (clampedDistance <= end || i == metrics.length - 1) {
        final localDistance = (clampedDistance - start).clamp(
          0.0,
          metric.length,
        );
        return _MetricMatch(metric: metric, localDistance: localDistance);
      }
      start = end;
    }

    return null;
  }
}

class TracingEngine {
  TracingEngine({
    this.onSegmentComplete,
    this.onAllComplete,
    this.onProgressChanged,
  });

  final void Function(int segmentIndex)? onSegmentComplete;
  final VoidCallback? onAllComplete;
  final void Function(double progress)? onProgressChanged;

  List<SegmentData> _segments = const [];
  TracingDifficulty _difficulty = TracingDifficulty.easy;

  Rect _viewBox = const Rect.fromLTWH(0, 0, 1000, 1000);
  Size _canvasSize = Size.zero;

  double _scale = 1;
  double _tx = 0;
  double _ty = 0;
  Float64List _matrix = _makeMatrix(1, 0, 0);

  int _activeSegmentIndex = 0;
  double _activeDistanceAlong = 0;

  Offset? _lastSmoothed;
  Offset? _lastAcceptedTemplatePoint;

  List<List<Offset>> _segmentStrokes = const [];
  List<Offset> _activeStrokePoints = const [];

  List<String> _pathStrings = const [];

  int get activeSegmentIndex => _activeSegmentIndex;
  int get totalSegments => _segments.length;
  bool get allCompleted => _activeSegmentIndex >= _segments.length;
  List<SegmentData> get segments => _segments;
  TracingDifficulty get difficulty => _difficulty;
  Size get canvasSize => _canvasSize;
  double get scale => _scale;
  double get tx => _tx;
  double get ty => _ty;

  double get segmentProgress {
    if (allCompleted) return 1;
    final segment = _activeSegment;
    if (segment == null || segment.length <= 0) return 0;
    return (_activeDistanceAlong / segment.length).clamp(0.0, 1.0);
  }

  double get totalProgress {
    if (_segments.isEmpty) return 0;
    if (allCompleted) return 1;
    final done = _activeSegmentIndex / _segments.length;
    final current = segmentProgress / _segments.length;
    return (done + current).clamp(0.0, 1.0);
  }

  List<List<Offset>> get segmentStrokes => List.unmodifiable(_segmentStrokes);
  List<Offset> get activeStrokePoints => List.unmodifiable(_activeStrokePoints);

  SegmentData? get _activeSegment {
    if (_activeSegmentIndex < 0 || _activeSegmentIndex >= _segments.length) {
      return null;
    }
    return _segments[_activeSegmentIndex];
  }

  void configure({
    required List<String> segmentPathStrings,
    required Rect viewBox,
    required Size canvasSize,
    required TracingDifficulty difficulty,
  }) {
    _pathStrings = List.of(segmentPathStrings);
    _viewBox = viewBox;
    _canvasSize = canvasSize;
    _difficulty = difficulty;

    _computeTransform();
    _buildSegments();
    _resetProgress();
    onProgressChanged?.call(totalProgress);
  }

  void configureFromTemplate({
    required TracingTemplate template,
    required Size canvasSize,
    required TracingDifficulty difficulty,
  }) {
    configure(
      segmentPathStrings: template.segments
          .map((segment) => segment.pathSvg)
          .toList(growable: false),
      viewBox: template.viewBox,
      canvasSize: canvasSize,
      difficulty: difficulty,
    );
  }

  void updateCanvasSize(Size size) {
    if ((_canvasSize.width - size.width).abs() < 0.5 &&
        (_canvasSize.height - size.height).abs() < 0.5) {
      return;
    }

    _canvasSize = size;
    _computeTransform();
    _rebuildScreenPaths();
  }

  void reset() {
    _resetProgress();
    onProgressChanged?.call(totalProgress);
  }

  void handlePointerDown(Offset screenPoint) {
    if (allCompleted) return;

    final templatePoint = _screenToTemplate(screenPoint);
    _lastSmoothed = templatePoint;
    _lastAcceptedTemplatePoint = null;
    _activeStrokePoints = const [];
  }

  TracingPointResult handlePointerMove(Offset screenPoint) {
    if (allCompleted) {
      return _buildNoOpResult(screenPoint);
    }

    final segment = _activeSegment;
    if (segment == null) {
      return _buildNoOpResult(screenPoint);
    }

    final templateRaw = _screenToTemplate(screenPoint);
    final smoothed = _smooth(templateRaw);

    final nearest = _findNearestOnSegment(segment, smoothed);
    final isWithinTube = nearest.distance <= _difficulty.toleranceRadius;

    if (!isWithinTube) {
      return _buildResult(
        accepted: false,
        segmentCompleted: false,
        distanceFromPath: nearest.distance,
        closestTemplatePoint: nearest.point,
      );
    }

    final lastAccepted = _lastAcceptedTemplatePoint;
    if (lastAccepted != null &&
        (smoothed - lastAccepted).distance < _difficulty.resampleSpacing) {
      return _buildResult(
        accepted: false,
        segmentCompleted: false,
        distanceFromPath: nearest.distance,
        closestTemplatePoint: nearest.point,
      );
    }

    _lastAcceptedTemplatePoint = smoothed;
    _activeStrokePoints = [..._activeStrokePoints, screenPoint];

    final beforeProgress = segmentProgress;
    if (nearest.distanceAlong > _activeDistanceAlong) {
      _activeDistanceAlong = nearest.distanceAlong;
    }

    final nowCompleted =
        segmentProgress >= _difficulty.completionThreshold ||
        segment.length <= 1;

    var segmentCompleted = false;
    if (nowCompleted) {
      segmentCompleted = true;
      _completeSegment();
    }

    if (segmentProgress != beforeProgress || segmentCompleted) {
      onProgressChanged?.call(totalProgress);
    }

    return _buildResult(
      accepted: true,
      segmentCompleted: segmentCompleted,
      distanceFromPath: nearest.distance,
      closestTemplatePoint: nearest.point,
    );
  }

  void handlePointerUp() {
    _activeStrokePoints = const [];
    _lastSmoothed = null;
    _lastAcceptedTemplatePoint = null;
  }

  Offset? get hintPoint {
    final segment = _activeSegment;
    if (segment == null) return null;

    final point = segment.screenPointAt(_activeDistanceAlong);
    return point;
  }

  Offset? segmentStartScreen(int index) {
    if (index < 0 || index >= _segments.length) return null;
    return _segments[index].screenPointAt(0);
  }

  Offset? segmentEndScreen(int index) {
    if (index < 0 || index >= _segments.length) return null;
    final segment = _segments[index];
    return segment.screenPointAt(segment.length);
  }

  void _completeSegment() {
    if (_activeSegmentIndex < _segmentStrokes.length) {
      _segmentStrokes[_activeSegmentIndex] = [..._activeStrokePoints];
    }

    final completedIndex = _activeSegmentIndex;
    _activeSegmentIndex += 1;
    _activeDistanceAlong = 0;
    _activeStrokePoints = const [];
    _lastSmoothed = null;
    _lastAcceptedTemplatePoint = null;

    onSegmentComplete?.call(completedIndex);
    if (allCompleted) {
      onAllComplete?.call();
    }
  }

  void _resetProgress() {
    _activeSegmentIndex = 0;
    _activeDistanceAlong = 0;
    _activeStrokePoints = const [];
    _lastSmoothed = null;
    _lastAcceptedTemplatePoint = null;

    final count = _segments.isEmpty ? _pathStrings.length : _segments.length;
    _segmentStrokes = List<List<Offset>>.generate(
      count,
      (_) => <Offset>[],
      growable: false,
    );
  }

  void _computeTransform() {
    const padding = 22.0;
    final availableWidth = (_canvasSize.width - padding * 2).clamp(
      1.0,
      double.infinity,
    );
    final availableHeight = (_canvasSize.height - padding * 2).clamp(
      1.0,
      double.infinity,
    );

    final scaleX = availableWidth / _viewBox.width;
    final scaleY = availableHeight / _viewBox.height;
    _scale = math.min(scaleX, scaleY);

    final drawWidth = _viewBox.width * _scale;
    final drawHeight = _viewBox.height * _scale;

    final drawLeft = padding + (availableWidth - drawWidth) / 2;
    final drawTop = padding + (availableHeight - drawHeight) / 2;

    _tx = drawLeft - (_viewBox.left * _scale);
    _ty = drawTop - (_viewBox.top * _scale);

    _matrix = _makeMatrix(_scale, _tx, _ty);
  }

  void _buildSegments() {
    final built = <SegmentData>[];

    for (var i = 0; i < _pathStrings.length; i++) {
      final templatePath = parseSvgPathData(_pathStrings[i]);
      final screenPath = templatePath.transform(_matrix);

      final templateMetrics = templatePath
          .computeMetrics(forceClosed: false)
          .toList();
      if (templateMetrics.isEmpty) continue;

      final screenMetrics = screenPath
          .computeMetrics(forceClosed: false)
          .toList();
      if (screenMetrics.isEmpty) continue;

      final templateEnds = <double>[];
      var totalLength = 0.0;
      for (final metric in templateMetrics) {
        totalLength += metric.length;
        templateEnds.add(totalLength);
      }

      final screenEnds = <double>[];
      var screenLen = 0.0;
      for (final metric in screenMetrics) {
        screenLen += metric.length;
        screenEnds.add(screenLen);
      }

      built.add(
        SegmentData(
          index: i,
          templatePath: templatePath,
          screenPath: screenPath,
          templateMetrics: templateMetrics,
          templateMetricEnds: templateEnds,
          screenMetrics: screenMetrics,
          screenMetricEnds: screenEnds,
          length: totalLength,
        ),
      );
    }

    _segments = built;
  }

  void _rebuildScreenPaths() {
    final rebuilt = <SegmentData>[];

    for (final segment in _segments) {
      final screenPath = segment.templatePath.transform(_matrix);
      final screenMetrics = screenPath
          .computeMetrics(forceClosed: false)
          .toList();
      if (screenMetrics.isEmpty) continue;

      final screenEnds = <double>[];
      var screenLength = 0.0;
      for (final metric in screenMetrics) {
        screenLength += metric.length;
        screenEnds.add(screenLength);
      }

      rebuilt.add(
        SegmentData(
          index: segment.index,
          templatePath: segment.templatePath,
          screenPath: screenPath,
          templateMetrics: segment.templateMetrics,
          templateMetricEnds: segment.templateMetricEnds,
          screenMetrics: screenMetrics,
          screenMetricEnds: screenEnds,
          length: segment.length,
        ),
      );
    }

    _segments = rebuilt;
  }

  Offset _screenToTemplate(Offset screen) {
    return Offset((screen.dx - _tx) / _scale, (screen.dy - _ty) / _scale);
  }

  Offset _templateToScreen(Offset template) {
    return Offset(template.dx * _scale + _tx, template.dy * _scale + _ty);
  }

  Offset _smooth(Offset raw) {
    final previous = _lastSmoothed;
    if (previous == null) {
      _lastSmoothed = raw;
      return raw;
    }

    final smoothed =
        Offset.lerp(previous, raw, _difficulty.smoothingAlpha) ?? raw;
    _lastSmoothed = smoothed;
    return smoothed;
  }

  _NearestResult _findNearestOnSegment(SegmentData segment, Offset point) {
    if (segment.length <= 0) {
      return const _NearestResult(
        point: Offset.zero,
        distance: double.infinity,
        distanceAlong: 0,
      );
    }

    final samples = math.max(8, _difficulty.coarseSamples);
    final step = segment.length / samples;

    var bestDistance = double.infinity;
    var bestAlong = 0.0;
    Offset bestPoint = Offset.zero;

    for (var i = 0; i <= samples; i++) {
      final along = (i / samples) * segment.length;
      final candidate = segment.templatePointAt(along);
      if (candidate == null) continue;

      final distance = (candidate - point).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestAlong = along;
        bestPoint = candidate;
      }
    }

    var window = step;
    for (var round = 0; round < 6; round++) {
      final left = math.max(0, bestAlong - window);
      final right = math.min(segment.length, bestAlong + window);
      final q1 = left + (right - left) * 0.25;
      final q2 = left + (right - left) * 0.50;
      final q3 = left + (right - left) * 0.75;

      for (final along in [q1, q2, q3]) {
        final candidate = segment.templatePointAt(along);
        if (candidate == null) continue;
        final distance = (candidate - point).distance;
        if (distance < bestDistance) {
          bestDistance = distance;
          bestAlong = along;
          bestPoint = candidate;
        }
      }

      window *= 0.5;
      if (window < 0.5) break;
    }

    return _NearestResult(
      point: bestPoint,
      distance: bestDistance,
      distanceAlong: bestAlong,
    );
  }

  TracingPointResult _buildNoOpResult(Offset screenPoint) {
    return TracingPointResult(
      accepted: false,
      segmentProgress: segmentProgress,
      totalProgress: totalProgress,
      segmentCompleted: false,
      allCompleted: allCompleted,
      closestScreenPoint: screenPoint,
      distanceFromPath: double.infinity,
      activeSegmentIndex: _activeSegmentIndex,
    );
  }

  TracingPointResult _buildResult({
    required bool accepted,
    required bool segmentCompleted,
    required double distanceFromPath,
    required Offset closestTemplatePoint,
  }) {
    return TracingPointResult(
      accepted: accepted,
      segmentProgress: segmentProgress,
      totalProgress: totalProgress,
      segmentCompleted: segmentCompleted,
      allCompleted: allCompleted,
      closestScreenPoint: _templateToScreen(closestTemplatePoint),
      distanceFromPath: distanceFromPath,
      activeSegmentIndex: _activeSegmentIndex,
    );
  }

  static Float64List _makeMatrix(double scale, double tx, double ty) {
    return Float64List.fromList([
      scale,
      0,
      0,
      0,
      0,
      scale,
      0,
      0,
      0,
      0,
      1,
      0,
      tx,
      ty,
      0,
      1,
    ]);
  }
}

class _NearestResult {
  const _NearestResult({
    required this.point,
    required this.distance,
    required this.distanceAlong,
  });

  final Offset point;
  final double distance;
  final double distanceAlong;
}

class _MetricMatch {
  const _MetricMatch({required this.metric, required this.localDistance});

  final PathMetric metric;
  final double localDistance;
}
