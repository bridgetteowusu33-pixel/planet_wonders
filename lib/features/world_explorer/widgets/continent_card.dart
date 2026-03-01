import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/continent.dart';

/// Gradient colors for each continent (matched by id).
const _continentGradients = <String, (Color, Color)>{
  'africa': (Color(0xFFFFC23B), Color(0xFFEA8B1D)),
  'asia': (Color(0xFFFF6B5F), Color(0xFFE23C2D)),
  'europe': (Color(0xFF2F9DFF), Color(0xFF215AE5)),
  'north_america': (Color(0xFF5BE3CF), Color(0xFF20AFA0)),
  'south_america': (Color(0xFF9C5FFF), Color(0xFF6B3FA0)),
  'oceania': (Color(0xFFFF7656), Color(0xFFDA3429)),
};

const _defaultGradient = (Color(0xFF2F9DFF), Color(0xFF215AE5));

/// A 3D sticker-style card showing a continent's emoji, name, and progress.
class ContinentCard extends StatelessWidget {
  const ContinentCard({
    super.key,
    required this.continent,
    required this.onTap,
  });

  final Continent continent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = continent.countries.length;
    final unlocked = continent.unlockedCount;
    final (gradTop, gradBottom) =
        _continentGradients[continent.id] ?? _defaultGradient;

    const radius = BorderRadius.all(Radius.circular(28));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: Color.lerp(gradBottom, Colors.black, 0.35)
              ?.withValues(alpha: 0.45),
        ),
        padding: const EdgeInsets.only(bottom: 3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradTop.withValues(alpha: 0.6),
                gradBottom.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Top shine highlight
              Positioned(
                left: 6,
                right: 6,
                top: 5,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      continent.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      continent.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$unlocked / $total explored',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
