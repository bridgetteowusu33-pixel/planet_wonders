import 'package:flutter/material.dart';

/// A friendly gradient countdown bar for Ingredient Rush.
///
/// Goes from mint (full) → yellow (half) → coral (low).
/// Rounded corners, no stress-inducing red.
class RushTimerBar extends StatelessWidget {
  const RushTimerBar({
    super.key,
    required this.fraction,
    required this.remainingSec,
  });

  /// Timer fraction (1.0 = full, 0.0 = empty).
  final double fraction;

  /// Remaining seconds (for label).
  final int remainingSec;

  @override
  Widget build(BuildContext context) {
    final color = _colorForFraction(fraction);
    final minutes = remainingSec ~/ 60;
    final seconds = remainingSec % 60;
    final label = minutes > 0
        ? '$minutes:${seconds.toString().padLeft(2, '0')}'
        : '${seconds}s';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, size: 18, color: color),
          const SizedBox(width: 6),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fraction.clamp(0, 1),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForFraction(double f) {
    if (f > 0.5) return const Color(0xFF66BB6A); // mint/green
    if (f > 0.25) return const Color(0xFFFFCA28); // yellow
    return const Color(0xFFFF7043); // coral
  }
}
