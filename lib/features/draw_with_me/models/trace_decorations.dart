import 'package:flutter/material.dart';

class EyeDecoration {
  const EyeDecoration({
    required this.cx,
    required this.cy,
    required this.r,
    required this.pupilR,
    required this.highlightR,
    required this.highlightOffset,
  });

  final double cx;
  final double cy;
  final double r;
  final double pupilR;
  final double highlightR;
  final Offset highlightOffset;

  factory EyeDecoration.fromJson(Map<String, dynamic> json) {
    final offset = json['highlightOffset'];
    return EyeDecoration(
      cx: (json['cx'] as num).toDouble(),
      cy: (json['cy'] as num).toDouble(),
      r: (json['r'] as num).toDouble(),
      pupilR: (json['pupilR'] as num).toDouble(),
      highlightR: (json['highlightR'] as num).toDouble(),
      highlightOffset: offset is List && offset.length >= 2
          ? Offset(
              (offset[0] as num).toDouble(),
              (offset[1] as num).toDouble(),
            )
          : Offset.zero,
    );
  }
}

class BlushDecoration {
  const BlushDecoration({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
  });

  final double cx;
  final double cy;
  final double rx;
  final double ry;

  factory BlushDecoration.fromJson(Map<String, dynamic> json) {
    return BlushDecoration(
      cx: (json['cx'] as num).toDouble(),
      cy: (json['cy'] as num).toDouble(),
      rx: (json['rx'] as num).toDouble(),
      ry: (json['ry'] as num).toDouble(),
    );
  }
}

class TraceDecorations {
  const TraceDecorations({
    required this.revealAfterSegment,
    required this.eyes,
    required this.nosePath,
    required this.mouthPath,
    required this.tonguePath,
    required this.blush,
    required this.eyebrowPaths,
  });

  final int revealAfterSegment;
  final List<EyeDecoration> eyes;
  final String nosePath;
  final String mouthPath;
  final String tonguePath;
  final List<BlushDecoration> blush;
  final List<String> eyebrowPaths;

  factory TraceDecorations.fromJson(Map<String, dynamic> json) {
    final eyes = (json['eyes'] as List?)
            ?.whereType<Map>()
            .map((e) => EyeDecoration.fromJson(e.cast<String, dynamic>()))
            .toList(growable: false) ??
        const [];

    final blush = (json['blush'] as List?)
            ?.whereType<Map>()
            .map((e) => BlushDecoration.fromJson(e.cast<String, dynamic>()))
            .toList(growable: false) ??
        const [];

    final eyebrows = (json['eyebrowPaths'] as List?)
            ?.whereType<String>()
            .toList(growable: false) ??
        const [];

    return TraceDecorations(
      revealAfterSegment:
          (json['revealAfterSegment'] as num?)?.toInt() ?? 0,
      eyes: eyes,
      nosePath: (json['nosePath'] as String?) ?? '',
      mouthPath: (json['mouthPath'] as String?) ?? '',
      tonguePath: (json['tonguePath'] as String?) ?? '',
      blush: blush,
      eyebrowPaths: eyebrows,
    );
  }
}
