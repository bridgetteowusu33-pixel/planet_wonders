// File: lib/features/draw_with_me/models/trace_segment.dart
import 'package:flutter/material.dart';

class TraceSegment {
  const TraceSegment({required this.pathData, this.start, this.end});

  final String pathData;
  final Offset? start;
  final Offset? end;

  factory TraceSegment.fromJson(Map<String, dynamic> json) {
    final rawPath = (json['path'] as String?)?.trim() ?? '';
    if (rawPath.isEmpty) {
      throw const FormatException('Trace segment path is required.');
    }

    return TraceSegment(
      pathData: rawPath,
      start: _offsetFromJson(json['start']),
      end: _offsetFromJson(json['end']),
    );
  }
}

Offset? _offsetFromJson(Object? raw) {
  if (raw is! List || raw.length < 2) return null;
  final x = raw[0];
  final y = raw[1];
  if (x is! num || y is! num) return null;
  return Offset(x.toDouble(), y.toDouble());
}
