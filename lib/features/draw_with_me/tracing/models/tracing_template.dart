import 'dart:ui';

import '../../models/trace_shape.dart';

class TracingTemplateSegment {
  const TracingTemplateSegment({required this.pathSvg, this.start, this.end});

  final String pathSvg;
  final Offset? start;
  final Offset? end;
}

class TracingTemplate {
  const TracingTemplate({
    required this.id,
    required this.title,
    required this.viewBox,
    required this.segments,
    required this.difficulty,
  });

  final String id;
  final String title;
  final Rect viewBox;
  final List<TracingTemplateSegment> segments;
  final TraceDifficulty difficulty;

  double get aspectRatio {
    if (viewBox.height <= 0) return 1;
    return viewBox.width / viewBox.height;
  }

  factory TracingTemplate.fromShape(
    TraceShape shape, {
    TraceDifficulty? difficulty,
  }) {
    return TracingTemplate(
      id: shape.storageId,
      title: shape.title,
      viewBox: shape.viewBox,
      difficulty: difficulty ?? TraceDifficulty.easy,
      segments: shape.segments
          .map(
            (segment) => TracingTemplateSegment(
              pathSvg: segment.pathData,
              start: segment.start,
              end: segment.end,
            ),
          )
          .toList(growable: false),
    );
  }
}
