import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/pw_theme.dart';

/// A small stat card showing emoji + value + label with a 3D pastel look.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final darkEdge = Color.lerp(color, Colors.black, 0.25)!;
    const radius = BorderRadius.all(Radius.circular(20));

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: darkEdge.withValues(alpha: 0.6),
      ),
      padding: const EdgeInsets.only(bottom: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: radius,
          color: color.withValues(alpha: 0.18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: PWThemeColors.of(context).textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: PWThemeColors.of(context).textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
