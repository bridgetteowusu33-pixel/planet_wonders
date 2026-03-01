import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/motion/pw_animated_scale.dart';

/// A 3D sticker-style game card with emoji, title, subtitle, and accent color.
///
/// Includes a subtle press-to-shrink animation that respects reduce motion.
class GameCard extends StatefulWidget {
  const GameCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gradTop = Color.lerp(widget.color, Colors.white, 0.25)!;
    final gradBottom = widget.color;

    const radius = BorderRadius.all(Radius.circular(18));

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: PWAnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: Color.lerp(gradBottom, Colors.black, 0.35),
          ),
          padding: const EdgeInsets.only(bottom: 4),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [gradTop, gradBottom],
              ),
            ),
            child: Stack(
              children: [
                // Top shine highlight
                Positioned(
                  left: 4,
                  right: 4,
                  top: 0,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.4),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.emoji,
                        style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 6),
                    Text(
                      widget.title,
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
