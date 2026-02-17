// File: lib/features/draw_with_me/engine/path_validator.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/trace_shape.dart';

class TraceValidationConfig {
  const TraceValidationConfig({
    required this.tolerance,
    required this.minCoverage,
    required this.autoCompleteCoverage,
    required this.strokeWidth,
    required this.dotted,
  });

  final double tolerance;
  final double minCoverage;
  final double autoCompleteCoverage;
  final double strokeWidth;
  final bool dotted;

  factory TraceValidationConfig.fromDifficulty(TraceDifficulty difficulty) {
    switch (difficulty) {
      case TraceDifficulty.easy:
        return const TraceValidationConfig(
          tolerance: 26,
          minCoverage: 0.72,
          autoCompleteCoverage: 0.60,
          strokeWidth: 10,
          dotted: true,
        );
      case TraceDifficulty.medium:
        return const TraceValidationConfig(
          tolerance: 18,
          minCoverage: 0.82,
          autoCompleteCoverage: 0.70,
          strokeWidth: 7,
          dotted: true,
        );
      case TraceDifficulty.hard:
        return const TraceValidationConfig(
          tolerance: 12,
          minCoverage: 0.90,
          autoCompleteCoverage: 0.84,
          strokeWidth: 4,
          dotted: false,
        );
    }
  }
}

class TraceValidationResult {
  const TraceValidationResult({
    required this.coverage,
    required this.completed,
    required this.suggestAutoComplete,
  });

  final double coverage;
  final bool completed;
  final bool suggestAutoComplete;
}

class PathValidator {
  const PathValidator();

  List<Offset> samplePath(Path path, {double spacing = 8}) {
    final samples = <Offset>[];
    for (final metric in path.computeMetrics(forceClosed: false)) {
      final length = metric.length;
      if (length <= 0) continue;

      for (double d = 0; d <= length; d += spacing) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent != null) {
          samples.add(tangent.position);
        }
      }

      final end = metric.getTangentForOffset(length);
      if (end != null) {
        samples.add(end.position);
      }
    }
    return samples;
  }

  TraceValidationResult evaluate({
    required List<Offset> sampledPathPoints,
    required List<Offset> userPoints,
    required TraceValidationConfig config,
  }) {
    if (sampledPathPoints.isEmpty || userPoints.isEmpty) {
      return const TraceValidationResult(
        coverage: 0,
        completed: false,
        suggestAutoComplete: false,
      );
    }

    int covered = 0;
    final toleranceSq = config.tolerance * config.tolerance;
    final cellSize = config.tolerance;
    final buckets = <(int, int), List<Offset>>{};

    for (final point in userPoints) {
      final cell = (
        (point.dx / cellSize).floor(),
        (point.dy / cellSize).floor(),
      );
      (buckets[cell] ??= <Offset>[]).add(point);
    }

    for (final target in sampledPathPoints) {
      final targetCellX = (target.dx / cellSize).floor();
      final targetCellY = (target.dy / cellSize).floor();
      bool hit = false;

      for (int cy = targetCellY - 1; cy <= targetCellY + 1 && !hit; cy++) {
        for (int cx = targetCellX - 1; cx <= targetCellX + 1 && !hit; cx++) {
          final candidates = buckets[(cx, cy)];
          if (candidates == null) continue;
          for (final drawn in candidates) {
            final dx = target.dx - drawn.dx;
            final dy = target.dy - drawn.dy;
            final distSq = dx * dx + dy * dy;
            if (distSq <= toleranceSq) {
              hit = true;
              break;
            }
          }
        }
      }

      if (hit) {
        covered++;
      }
    }

    final coverage = covered / math.max(1, sampledPathPoints.length);

    return TraceValidationResult(
      coverage: coverage,
      completed: coverage >= config.minCoverage,
      suggestAutoComplete: coverage >= config.autoCompleteCoverage,
    );
  }
}
