import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'motion_settings_provider.dart';

/// A scale animation wrapper that becomes a no-op when reduce motion is active.
///
/// Usage:
/// ```dart
/// PWAnimatedScale(
///   scale: _isPressed ? 0.95 : 1.0,
///   child: MyButton(),
/// )
/// ```
class PWAnimatedScale extends ConsumerWidget {
  const PWAnimatedScale({
    super.key,
    required this.scale,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeOutCubic,
    this.alignment = Alignment.center,
  });

  final double scale;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduced = MotionUtil.isReduced(ref);

    if (reduced) return child;

    return AnimatedScale(
      scale: scale,
      duration: duration,
      curve: curve,
      alignment: alignment,
      child: child,
    );
  }
}
