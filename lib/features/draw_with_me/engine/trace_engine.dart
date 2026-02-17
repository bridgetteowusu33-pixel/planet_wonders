// File: lib/features/draw_with_me/engine/trace_engine.dart
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_drawing/path_drawing.dart';

import '../models/trace_shape.dart';
import 'path_validator.dart';

final traceEngineProvider = Provider<TraceEngine>((ref) => TraceEngine());

class TraceLayoutSegment {
  const TraceLayoutSegment({required this.path, required this.samplePoints});

  final Path path;
  final List<Offset> samplePoints;
}

class TraceLayout {
  const TraceLayout({required this.size, required this.segments});

  final Size size;
  final List<TraceLayoutSegment> segments;
}

class TraceEngine {
  static const int _maxLayoutCacheEntries = 48;
  final PathValidator _validator = const PathValidator();

  List<TracePack>? _packCache;
  final Map<String, List<TraceShape>> _shapesByPack =
      <String, List<TraceShape>>{};
  final Map<String, TraceShape> _shapeByStorageId = <String, TraceShape>{};
  final LinkedHashMap<String, TraceLayout> _layoutCache =
      LinkedHashMap<String, TraceLayout>();

  Future<List<TracePack>> loadPacks() async {
    if (_packCache != null) return _packCache!;

    final raw = await rootBundle.loadString('assets/traces/trace_packs.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('trace_packs.json must be an object');
    }

    final entries = decoded['packs'];
    if (entries is! List) {
      throw const FormatException('trace_packs.json must contain packs list');
    }

    _packCache = entries
        .whereType<Map>()
        .map((entry) => TracePack.fromJson(entry.cast<String, dynamic>()))
        .toList(growable: false);

    return _packCache!;
  }

  Future<List<TraceShape>> loadShapesForPack(String packId) async {
    final cached = _shapesByPack[packId];
    if (cached != null) return cached;

    final packs = await loadPacks();
    TracePack? pack;
    for (final candidate in packs) {
      if (candidate.id == packId) {
        pack = candidate;
        break;
      }
    }
    if (pack == null) {
      throw ArgumentError('Unknown trace pack: $packId');
    }

    final raw = await rootBundle.loadString(pack.file);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('${pack.file} must be an object');
    }

    final shapes = <TraceShape>[];

    final items = decoded['items'];
    if (items is List) {
      shapes.addAll(
        items.whereType<Map>().map(
          (item) => TraceShape.fromJson(
            packId: packId,
            json: item.cast<String, dynamic>(),
          ),
        ),
      );
    } else {
      final shapeFiles = _extractShapeFiles(decoded);
      if (shapeFiles.isEmpty) {
        throw FormatException(
          '${pack.file} must contain items list or shape file entries.',
        );
      }

      final baseDir = _assetDir(pack.file);
      for (final shapeFile in shapeFiles) {
        final fullPath = shapeFile.startsWith('assets/')
            ? shapeFile
            : '$baseDir/$shapeFile';
        final shapeRaw = await rootBundle.loadString(fullPath);
        final shapeDecoded = jsonDecode(shapeRaw);
        if (shapeDecoded is! Map<String, dynamic>) {
          throw FormatException('$fullPath must be an object');
        }

        shapes.add(TraceShape.fromJson(packId: packId, json: shapeDecoded));
      }
    }

    _shapesByPack[packId] = shapes;
    for (final shape in shapes) {
      _shapeByStorageId[shape.storageId] = shape;
    }

    return shapes;
  }

  Future<TraceShape> loadShape({
    required String packId,
    required String shapeId,
  }) async {
    final key = '${packId}_$shapeId';
    final cached = _shapeByStorageId[key];
    if (cached != null) return cached;

    final shapes = await loadShapesForPack(packId);
    for (final shape in shapes) {
      if (shape.id == shapeId) {
        return shape;
      }
    }

    throw ArgumentError('Unknown trace shape: $packId/$shapeId');
  }

  TraceLayout buildLayout({required TraceShape shape, required Size size}) {
    final cacheKey =
        '${shape.storageId}:${size.width.toStringAsFixed(1)}:${size.height.toStringAsFixed(1)}';
    final cached = _layoutCache.remove(cacheKey);
    if (cached != null) {
      _layoutCache[cacheKey] = cached;
      return cached;
    }

    final canvasRect = Offset.zero & size;
    final paddedRect = canvasRect.deflate(28);

    final source = shape.viewBox;
    final scaleX = paddedRect.width / source.width;
    final scaleY = paddedRect.height / source.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final drawWidth = source.width * scale;
    final drawHeight = source.height * scale;

    final dx = paddedRect.left + (paddedRect.width - drawWidth) / 2;
    final dy = paddedRect.top + (paddedRect.height - drawHeight) / 2;

    final matrix = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);

    final segments = <TraceLayoutSegment>[];
    for (final segment in shape.segments) {
      final path = parseSvgPathData(segment.pathData).transform(matrix.storage);
      final samples = _validator.samplePath(path, spacing: 8);
      segments.add(TraceLayoutSegment(path: path, samplePoints: samples));
    }

    final layout = TraceLayout(size: size, segments: segments);
    _layoutCache[cacheKey] = layout;
    _evictLayoutCacheIfNeeded();
    return layout;
  }

  void _evictLayoutCacheIfNeeded() {
    while (_layoutCache.length > _maxLayoutCacheEntries) {
      _layoutCache.remove(_layoutCache.keys.first);
    }
  }

  List<String> _extractShapeFiles(Map<String, dynamic> decoded) {
    final direct = decoded['shape_files'];
    if (direct is List) {
      return direct.whereType<String>().toList(growable: false);
    }

    final entries = decoded['shapes'];
    if (entries is List) {
      return entries
          .whereType<Map>()
          .map((entry) => entry['file'])
          .whereType<String>()
          .toList(growable: false);
    }

    return const <String>[];
  }

  String _assetDir(String path) {
    final slash = path.lastIndexOf('/');
    if (slash < 0) return path;
    return path.substring(0, slash);
  }
}
