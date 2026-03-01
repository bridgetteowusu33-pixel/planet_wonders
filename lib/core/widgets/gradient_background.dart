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

    final bgImage = isDark
        ? 'assets/backgrounds/home_bg_night.webp'
        : 'assets/backgrounds/home_beach_bg.webp';

    final fallbackColors = isDark ? _darkColors : _lightColors;

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
          bgImage,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          cacheWidth: cacheWidth,
          filterQuality: FilterQuality.low,
          errorBuilder: (context, error, stackTrace) {
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: fallbackColors,
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
              colors: isDark
                  ? [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                    ]
                  : [
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
