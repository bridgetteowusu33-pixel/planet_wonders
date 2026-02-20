import 'dart:math' as math;
import 'dart:ui';

double computeSnapThreshold(Size boardSize) {
  final shortest = math.min(boardSize.width, boardSize.height);
  final value = shortest * 0.07;
  return value.clamp(20.0, 52.0);
}

bool shouldSnapToTarget({
  required Offset dropPosition,
  required Offset targetCenter,
  required double threshold,
}) {
  return (dropPosition - targetCenter).distance <= threshold;
}
