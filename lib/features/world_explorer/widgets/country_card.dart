import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/country.dart';

/// Per-continent gradient colors for country cards.
const _countryGradients = <String, (Color, Color)>{
  'africa': (Color(0xFFFFC23B), Color(0xFFEA8B1D)),
  'asia': (Color(0xFFFF6B5F), Color(0xFFE23C2D)),
  'europe': (Color(0xFF2F9DFF), Color(0xFF215AE5)),
  'north_america': (Color(0xFF5BE3CF), Color(0xFF20AFA0)),
  'south_america': (Color(0xFF9C5FFF), Color(0xFF6B3FA0)),
  'oceania': (Color(0xFFFF7656), Color(0xFFDA3429)),
};

const _defaultGradient = (Color(0xFF2F9DFF), Color(0xFF215AE5));

/// A 3D sticker-style card for a single country.
///
/// Locked countries show a translucent overlay with a lock icon so kids
/// can see what's coming without feeling pressured.
class CountryCard extends StatelessWidget {
  const CountryCard({
    super.key,
    required this.country,
    required this.onTap,
  });

  final Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (gradTop, gradBottom) =
        _countryGradients[country.continentId] ?? _defaultGradient;

    const radius = BorderRadius.all(Radius.circular(28));

    return GestureDetector(
      onTap: country.isUnlocked ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
              // Country content
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (country.flagAsset != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            country.flagAsset!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Text(
                              country.flagEmoji,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        )
                      else
                        Text(
                          country.flagEmoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        country.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Lock overlay for locked countries
              if (!country.isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: radius,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        size: 28,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
