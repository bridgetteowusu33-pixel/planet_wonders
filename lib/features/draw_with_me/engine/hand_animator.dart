// File: lib/features/draw_with_me/engine/hand_animator.dart
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class HandPose {
  const HandPose({required this.position, required this.radians});

  final Offset position;
  final double radians;
}

class HandAnimator {
  const HandAnimator();

  static final Expando<ui.PathMetric> _metricCache = Expando<ui.PathMetric>(
    'hand_metric_cache',
  );
  static final Expando<bool> _metricResolved = Expando<bool>(
    'hand_metric_resolved',
  );

  HandPose poseAt(Path path, double t) {
    final metric = _resolveMetric(path);
    if (metric == null) {
      return const HandPose(position: Offset.zero, radians: 0);
    }
    if (metric.length <= 0) {
      return const HandPose(position: Offset.zero, radians: 0);
    }

    final clamped = t.clamp(0.0, 1.0);
    final tangent = metric.getTangentForOffset(metric.length * clamped);

    if (tangent == null) {
      return const HandPose(position: Offset.zero, radians: 0);
    }

    return HandPose(
      position: tangent.position,
      radians: math.atan2(tangent.vector.dy, tangent.vector.dx),
    );
  }

  ui.PathMetric? _resolveMetric(Path path) {
    if (_metricResolved[path] == true) {
      return _metricCache[path];
    }
    final iterator = path.computeMetrics(forceClosed: false).iterator;
    final metric = iterator.moveNext() ? iterator.current : null;
    if (metric != null) {
      _metricCache[path] = metric;
    }
    _metricResolved[path] = true;
    return metric;
  }
}
