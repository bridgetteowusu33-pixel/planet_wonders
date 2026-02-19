import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'motion_settings_provider.dart';

/// An [AnimatedSwitcher] that becomes an instant switch when reduce motion
/// is effective. Preserves the same API so callers don't need conditionals.
class PWAnimatedSwitcher extends ConsumerWidget {
  const PWAnimatedSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.switchInCurve = Curves.easeInOut,
    this.switchOutCurve = Curves.easeInOut,
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
  });

  final Widget child;
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;
  final AnimatedSwitcherLayoutBuilder layoutBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduced = MotionUtil.isReduced(ref);

    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: transitionBuilder,
      layoutBuilder: layoutBuilder,
      child: child,
    );
  }
}
