import 'package:flutter/material.dart';

/// A full-bleed background applied globally via the MaterialApp builder.
///
/// Light mode: beach image with a subtle gradient overlay.
/// Dark mode: deep navy gradient (no image).
/// Falls back to the gradient if the beach image fails to load.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  static const _lightColors = [
    Color(0xFF87CEEB), // sky blue
    Color(0xFFB5E8C3), // soft green-blue
    Color(0xFF7ED6A0), // grassy green
  ];

  static const _darkColors = [
    Color(0xFF0E1B2B), // deep navy
    Color(0xFF152238), // mid navy
    Color(0xFF1A2D45), // lighter navy
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _darkColors,
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: child,
      );
    }

    // Light mode: beach image background
    final mq = MediaQuery.maybeOf(context);
    final cacheWidth = mq == null
        ? null
        : (mq.size.width * mq.devicePixelRatio)
              .round()
              .clamp(1, 4096)
              .toInt();

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/backgrounds/home_beach_bg.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          cacheWidth: cacheWidth,
          filterQuality: FilterQuality.low,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to gradient if image is missing
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _lightColors,
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.14),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.08),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
