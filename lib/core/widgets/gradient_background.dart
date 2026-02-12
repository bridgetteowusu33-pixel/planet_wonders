import 'package:flutter/material.dart';

/// A sky-to-grass gradient background for playful screens.
///
/// Wraps [child] in a full-bleed gradient. Use inside a Scaffold body
/// to replace the plain white background.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // sky blue
            Color(0xFFB5E8C3), // soft green-blue
            Color(0xFF7ED6A0), // grassy green
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}
