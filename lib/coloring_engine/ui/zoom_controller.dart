import 'package:flutter/widgets.dart';

/// Manages pan/zoom transform for precision drawing.
class ZoomController extends ChangeNotifier {
  ZoomController({
    this.minScale = 1.0,
    this.maxScale = 4.0,
  });

  final double minScale;
  final double maxScale;

  double _scale = 1.0;
  Offset _offset = Offset.zero;
  bool precisionMode = false;

  double _gestureStartScale = 1.0;
  Offset _gestureStartFocal = Offset.zero;
  Offset _gestureStartOffset = Offset.zero;

  double get scale => _scale;
  Offset get offset => _offset;
  bool get isZoomed => _scale > 1.001;

  Matrix4 get matrix => Matrix4.identity()
    ..translateByDouble(_offset.dx, _offset.dy, 0, 1)
    ..scaleByDouble(_scale, _scale, 1, 1);

  Offset toCanvas(Offset viewPoint) => (viewPoint - _offset) / _scale;

  void setPrecisionMode(bool enabled) {
    if (precisionMode == enabled) return;
    precisionMode = enabled;
    notifyListeners();
  }

  void reset() {
    _scale = 1.0;
    _offset = Offset.zero;
    notifyListeners();
  }

  void startGesture(Offset focalPoint) {
    _gestureStartScale = _scale;
    _gestureStartFocal = focalPoint;
    _gestureStartOffset = _offset;
  }

  void updateGesture({
    required Offset focalPoint,
    required double gestureScale,
    required Offset focalDelta,
  }) {
    final nextScale = (_gestureStartScale * gestureScale).clamp(minScale, maxScale);

    // Keep the world coordinate under focal point stable while zooming.
    final worldUnderFocal = (_gestureStartFocal - _gestureStartOffset) / _gestureStartScale;
    final scaledOffset = focalPoint - (worldUnderFocal * nextScale);

    _scale = nextScale;
    _offset = scaledOffset + focalDelta;
    notifyListeners();
  }

  void zoomToPoint(
    Offset viewPoint, {
    required double targetScale,
  }) {
    final clampedTarget = targetScale.clamp(minScale, maxScale);
    final worldPoint = toCanvas(viewPoint);
    _scale = clampedTarget;
    _offset = viewPoint - (worldPoint * _scale);
    notifyListeners();
  }
}
