import 'package:flutter/material.dart';

import '../models/pot_face_state.dart';

/// Renders an illustrated pot PNG for the given country + face state,
/// falling back to the emoji face when the asset is missing.
class IllustratedPot extends StatelessWidget {
  const IllustratedPot({
    super.key,
    required this.countryId,
    required this.faceState,
    this.size = 160,
    this.progress = 0.0,
  });

  final String countryId;
  final PotFaceState faceState;
  final double size;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Progress ring behind the pot
          if (progress > 0)
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFB703),
                ),
              ),
            ),
          // Pot image with animated face switching
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.elasticOut,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Image.asset(
              faceState.assetPath(countryId),
              key: ValueKey<PotFaceState>(faceState),
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _EmojiFallback(
                emoji: faceState.fallbackEmoji,
                size: size,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiFallback extends StatelessWidget {
  const _EmojiFallback({required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.75,
      height: size * 0.75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: <Color>[Color(0xFFFFE0B2), Color(0xFFFFF3E0)],
        ),
        border: Border.all(color: const Color(0xFFFFB74D), width: 3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.35),
        ),
      ),
    );
  }
}
