import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Performs a flood fill on [source] starting from ([startX], [startY]).
///
/// Returns a new [ui.Image] containing **only** the filled pixels (the rest
/// are transparent). This makes it easy to composite the fill as a layer
/// on top of existing strokes. Returns `null` if the tap lands on an
/// outline or the area is already the fill color.
Future<ui.Image?> floodFill({
  required ui.Image source,
  required int startX,
  required int startY,
  required ui.Color fillColor,
  double tolerance = 32.0,
}) async {
  final width = source.width;
  final height = source.height;

  // Bounds check.
  if (startX < 0 || startX >= width || startY < 0 || startY >= height) {
    return null;
  }

  final byteData = await source.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  if (byteData == null) return null;

  final pixels = byteData.buffer.asUint8List();

  // Target color at the tap point.
  final targetIdx = (startY * width + startX) * 4;
  final tR = pixels[targetIdx];
  final tG = pixels[targetIdx + 1];
  final tB = pixels[targetIdx + 2];
  final tA = pixels[targetIdx + 3];

  // Don't fill if tapping on the outline (very dark pixels).
  if (tR < 60 && tG < 60 && tB < 60 && tA > 180) return null;

  // Don't fill if already the fill color.
  final fR = (fillColor.r * 255.0).round().clamp(0, 255);
  final fG = (fillColor.g * 255.0).round().clamp(0, 255);
  final fB = (fillColor.b * 255.0).round().clamp(0, 255);
  if (_match(tR, tG, tB, tA, fR, fG, fB, 255, tolerance)) return null;

  // Output buffer — transparent everywhere, fill color where filled.
  final result = Uint8List(width * height * 4);
  final visited = Uint8List(width * height);

  // BFS scanline flood fill.
  final queue = Queue<int>();
  queue.add(startY * width + startX);
  visited[startY * width + startX] = 1;

  while (queue.isNotEmpty) {
    final pos = queue.removeFirst();
    final x = pos % width;
    final y = pos ~/ width;

    // Fill this pixel.
    final ri = pos * 4;
    result[ri] = fR;
    result[ri + 1] = fG;
    result[ri + 2] = fB;
    result[ri + 3] = 255;

    // Check 4-connected neighbors.
    for (final (dx, dy) in [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
      final nx = x + dx;
      final ny = y + dy;
      if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue;
      final ni = ny * width + nx;
      if (visited[ni] == 1) continue;
      visited[ni] = 1;

      final pi = ni * 4;
      if (_match(pixels[pi], pixels[pi + 1], pixels[pi + 2], pixels[pi + 3],
          tR, tG, tB, tA, tolerance)) {
        queue.add(ni);
      }
    }
  }

  // Decode result buffer into a ui.Image.
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    result,
    width,
    height,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  return completer.future;
}

/// Returns true if (r1,g1,b1,a1) is within [tolerance] of (r2,g2,b2,a2).
bool _match(
  int r1, int g1, int b1, int a1,
  int r2, int g2, int b2, int a2,
  double tolerance,
) {
  return (r1 - r2).abs() <= tolerance &&
      (g1 - g2).abs() <= tolerance &&
      (b1 - b2).abs() <= tolerance &&
      (a1 - a2).abs() <= tolerance;
}
