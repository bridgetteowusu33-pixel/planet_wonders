import 'dart:math' as math;

/// Pure math helpers for per-segment completion animations.
/// [t] is normalized 0→1 over the animation duration.

/// Ear wiggle: oscillates ±[maxAngle] radians for [repeats] cycles.
double earWiggleAngle(double t, {double maxAngle = 0.14, int repeats = 2}) {
  final decay = 1.0 - t; // fades out
  return math.sin(t * repeats * math.pi * 2) * maxAngle * decay;
}

/// Wing flutter: rapid smaller oscillation for wing segments.
double wingFlutterAngle(double t, {double maxAngle = 0.10, int repeats = 3}) {
  final decay = 1.0 - t;
  return math.sin(t * repeats * math.pi * 2) * maxAngle * decay;
}

/// Tail wag: oscillates ±[maxAngle] radians for [repeats] cycles.
double tailWagAngle(double t, {double maxAngle = 0.26, int repeats = 3}) {
  final decay = 1.0 - t;
  return math.sin(t * repeats * math.pi * 2) * maxAngle * decay;
}

/// Jump: parabolic arc peaking at -[maxHeight] pixels at t=0.5.
double jumpOffset(double t, {double maxHeight = 30}) {
  // Parabola: -4h * t * (1-t) peaks at t=0.5
  return -4 * maxHeight * t * (1 - t);
}

/// Sparkle burst scale: grows then fades.
double burstScale(double t) {
  if (t < 0.3) return t / 0.3;
  return 1.0 - ((t - 0.3) / 0.7);
}
