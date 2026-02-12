import 'dart:ui' as ui;

import '../models/coloring_page.dart';

/// Creates an [OutlinePainter] that draws a pre-loaded [ui.Image].
///
/// The image is scaled to fit [size] while preserving aspect ratio, then
/// centred on the canvas. Works identically to programmatic painters in the
/// 4-layer compositing system (faint guide + bold overlay).
OutlinePainter createImageOutlinePainter(ui.Image image) {
  return (ui.Canvas canvas, ui.Size size) {
    final src = ui.Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    // Scale to fit while preserving aspect ratio.
    final imageAspect = image.width / image.height;
    final canvasAspect = size.width / size.height;

    double destW, destH;
    if (imageAspect > canvasAspect) {
      destW = size.width;
      destH = size.width / imageAspect;
    } else {
      destH = size.height;
      destW = size.height * imageAspect;
    }

    final dst = ui.Rect.fromCenter(
      center: ui.Offset(size.width / 2, size.height / 2),
      width: destW,
      height: destH,
    );

    canvas.drawImageRect(image, src, dst, ui.Paint());
  };
}
