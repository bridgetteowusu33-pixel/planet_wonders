// File: lib/features/draw_with_me/models/trace_shape.dart
import 'package:flutter/material.dart';

import 'trace_segment.dart';

enum TraceDifficulty { easy, medium, hard }

TraceDifficulty traceDifficultyFromString(String? raw) {
  switch (raw) {
    case 'hard':
      return TraceDifficulty.hard;
    case 'medium':
      return TraceDifficulty.medium;
    case 'easy':
    default:
      return TraceDifficulty.easy;
  }
}

class TracePack {
  const TracePack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.file,
  });

  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final String file;

  factory TracePack.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final title = (json['title'] as String?)?.trim() ?? '';
    final subtitle = (json['subtitle'] as String?)?.trim() ?? '';
    final icon = (json['icon'] as String?)?.trim() ?? 'draw';
    final file = (json['file'] as String?)?.trim() ?? '';

    if (id.isEmpty || title.isEmpty || file.isEmpty) {
      throw const FormatException('Trace pack is missing required fields.');
    }

    return TracePack(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: _colorFromHex((json['color'] as String?) ?? '#DCEEFF'),
      file: file,
    );
  }
}

class TraceShape {
  const TraceShape({
    required this.id,
    required this.packId,
    required this.title,
    required this.thumbnailEmoji,
    required this.viewBox,
    required this.segments,
  });

  final String id;
  final String packId;
  final String title;
  final String thumbnailEmoji;
  final Rect viewBox;
  final List<TraceSegment> segments;

  String get storageId => '${packId}_$id';

  factory TraceShape.fromJson({
    required String packId,
    required Map<String, dynamic> json,
  }) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final title = (json['title'] as String?)?.trim() ?? '';
    final emoji =
        ((json['thumbnailEmoji'] ?? json['emoji']) as String?)?.trim() ?? '🎨';

    if (id.isEmpty || title.isEmpty) {
      throw const FormatException('Trace shape is missing required fields.');
    }

    final viewBox = _viewBoxFromJson(json['viewBox']);

    final rawSegments = json['segments'];
    if (rawSegments is! List || rawSegments.isEmpty) {
      throw const FormatException('Trace shape must contain segments.');
    }

    final segments = rawSegments
        .whereType<Map>()
        .map((entry) => TraceSegment.fromJson(entry.cast<String, dynamic>()))
        .toList(growable: false);

    return TraceShape(
      id: id,
      packId: packId,
      title: title,
      thumbnailEmoji: emoji,
      viewBox: viewBox,
      segments: segments,
    );
  }
}

Rect _viewBoxFromJson(Object? raw) {
  if (raw is List && raw.length == 4) {
    final x = raw[0];
    final y = raw[1];
    final w = raw[2];
    final h = raw[3];
    if (x is num && y is num && w is num && h is num) {
      return Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        w.toDouble(),
        h.toDouble(),
      );
    }
  }
  return const Rect.fromLTWH(0, 0, 1000, 1000);
}

Color _colorFromHex(String raw) {
  final normalized = raw.replaceAll('#', '').trim();
  if (normalized.length == 6) {
    final value = int.tryParse('FF$normalized', radix: 16);
    if (value != null) return Color(value);
  }
  if (normalized.length == 8) {
    final value = int.tryParse(normalized, radix: 16);
    if (value != null) return Color(value);
  }
  return const Color(0xFFDCEEFF);
}
