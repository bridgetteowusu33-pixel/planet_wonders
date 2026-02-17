import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/coloring_page.dart';
import 'region_mask.dart';

/// Builds a region mask by rasterizing an [OutlinePainter] and extracting
/// enclosed components.
///
/// This enables region-fill on painter-driven pages that don't ship with a
/// precomputed mask asset.
Future<RegionMask> generateRegionMaskFromOutline({
  required OutlinePainter paintOutline,
  int width = 1024,
  int height = 1024,
  int lineThreshold = 210,
  int dilateIterations = 1,
  int minRegionSize = 48,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(width.toDouble(), height.toDouble());

  // Normalize to white page with black outlines.
  canvas.drawRect(
    Offset.zero & size,
    Paint()..color = Colors.white,
  );
  paintOutline(canvas, size);

  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  picture.dispose();

  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) {
    image.dispose();
    throw Exception('Failed to rasterize outline into mask buffer');
  }
  final rgba = byteData.buffer.asUint8List();
  image.dispose();

  // 1 = outline pixel, 0 = open pixel
  final lineMap = Uint8List(width * height);
  for (int i = 0; i < width * height; i++) {
    final o = i * 4;
    final r = rgba[o];
    final g = rgba[o + 1];
    final b = rgba[o + 2];
    final a = rgba[o + 3];
    final isLine = a > 10 && (r < lineThreshold || g < lineThreshold || b < lineThreshold);
    lineMap[i] = isLine ? 1 : 0;
  }

  _dilate(lineMap, width, height, dilateIterations);

  // labels:
  //  -1 = outline
  //   0 = unvisited open
  //  >0 = connected component id
  final labels = Int32List(width * height);
  for (int i = 0; i < labels.length; i++) {
    if (lineMap[i] == 1) labels[i] = -1;
  }

  final regionPixels = Uint8List(width * height);
  int componentId = 1;
  int nextRegionId = 1;

  final queue = Int32List(width * height);
  final componentIndices = Int32List(width * height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final start = y * width + x;
      if (labels[start] != 0) continue;

      int qHead = 0;
      int qTail = 0;
      int compCount = 0;
      bool touchesBorder = false;

      labels[start] = componentId;
      queue[qTail++] = start;

      while (qHead < qTail) {
        final idx = queue[qHead++];
        componentIndices[compCount++] = idx;

        final cx = idx % width;
        final cy = idx ~/ width;
        if (cx == 0 || cy == 0 || cx == width - 1 || cy == height - 1) {
          touchesBorder = true;
        }

        // 4-connected neighbors
        if (cx + 1 < width) {
          final ni = idx + 1;
          if (labels[ni] == 0) {
            labels[ni] = componentId;
            queue[qTail++] = ni;
          }
        }
        if (cx - 1 >= 0) {
          final ni = idx - 1;
          if (labels[ni] == 0) {
            labels[ni] = componentId;
            queue[qTail++] = ni;
          }
        }
        if (cy + 1 < height) {
          final ni = idx + width;
          if (labels[ni] == 0) {
            labels[ni] = componentId;
            queue[qTail++] = ni;
          }
        }
        if (cy - 1 >= 0) {
          final ni = idx - width;
          if (labels[ni] == 0) {
            labels[ni] = componentId;
            queue[qTail++] = ni;
          }
        }
      }

      final keep = !touchesBorder && compCount >= minRegionSize && nextRegionId <= 255;
      if (keep) {
        for (int i = 0; i < compCount; i++) {
          regionPixels[componentIndices[i]] = nextRegionId;
        }
        nextRegionId++;
      }

      componentId++;
    }
  }

  return RegionMask(width: width, height: height, pixels: regionPixels);
}

void _dilate(Uint8List map, int width, int height, int iterations) {
  if (iterations <= 0) return;

  for (int iter = 0; iter < iterations; iter++) {
    final src = Uint8List.fromList(map);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final i = y * width + x;
        if (src[i] == 1) continue;

        bool hasLineNeighbor = false;
        for (int dy = -1; dy <= 1 && !hasLineNeighbor; dy++) {
          final ny = y + dy;
          if (ny < 0 || ny >= height) continue;
          for (int dx = -1; dx <= 1; dx++) {
            final nx = x + dx;
            if (nx < 0 || nx >= width) continue;
            if (src[ny * width + nx] == 1) {
              hasLineNeighbor = true;
              break;
            }
          }
        }
        if (hasLineNeighbor) {
          map[i] = 1;
        }
      }
    }
  }
}

