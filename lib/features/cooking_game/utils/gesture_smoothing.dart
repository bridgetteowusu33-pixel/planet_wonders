import 'dart:math' as math;
import 'dart:ui';

/// Tracks circular swipe progress for stirring.
///
/// Returns smoothed absolute angle deltas in radians for each pointer sample.
class CircularGestureTracker {
  double? _lastAngle;
  double _smoothedDelta = 0;

  void reset() {
    _lastAngle = null;
    _smoothedDelta = 0;
  }

  double addPoint({
    required Offset point,
    required Size areaSize,
  }) {
    final center = Offset(areaSize.width / 2, areaSize.height / 2);
    final vector = point - center;

    // Ignore tiny jitter near the center.
    if (vector.distanceSquared < 22 * 22) {
      return 0;
    }

    final angle = math.atan2(vector.dy, vector.dx);
    final previous = _lastAngle;
    _lastAngle = angle;

    if (previous == null) return 0;

    double delta = angle - previous;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;

    // Ignore teleports/edge jumps.
    if (delta.abs() > 1.15) {
      return 0;
    }

    // Exponential smoothing for steadier progress.
    _smoothedDelta = (_smoothedDelta * 0.68) + (delta * 0.32);
    return _smoothedDelta.abs();
  }
}
