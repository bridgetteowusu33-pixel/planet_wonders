import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/pw_theme.dart';
import '../coloring/data/coloring_data.dart';
import '../stories/data/story_data.dart';
import '../world_explorer/data/world_data.dart';

/// Passport screen — shows explorer profile, countries visited, and badges.
///
/// Data is derived from the world/story/coloring registries so it stays
/// in sync automatically as content is added.
class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  /// Countries that are unlocked count as "explored".
  List<_ExploredCountry> get _exploredCountries {
    final explored = <_ExploredCountry>[];
    for (final continent in worldContinents) {
      for (final country in continent.countries) {
        if (country.isUnlocked) {
          explored.add(_ExploredCountry(
            id: country.id,
            name: country.name,
            flag: country.flagEmoji,
            continent: continent.name,
            hasStory: storyRegistry.containsKey(country.id),
            hasColoring: coloringRegistry.containsKey(country.id),
          ));
        }
      }
    }
    return explored;
  }

  @override
  Widget build(BuildContext context) {
    final countries = _exploredCountries;
    final totalBadges = countries.where((c) => c.hasStory).length +
        countries.where((c) => c.hasColoring).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // --- Passport header ---
              Text(
                'My Passport',
                style: GoogleFonts.baloo2(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: PWColors.navy,
                ),
              ),
              const SizedBox(height: 20),

              // --- Explorer card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6EC6E9), Color(0xFF7ED6B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: PWColors.blue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.3),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '\u{1F30D}', // 🌍
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Little Explorer',
                      style: GoogleFonts.baloo2(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Planet Wonders Traveler',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Stats row ---
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      emoji: '\u{1F30E}', // 🌎
                      value: '${countries.length}',
                      label: 'Countries\nExplored',
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      emoji: '\u{2B50}', // ⭐
                      value: '$totalBadges',
                      label: 'Badges\nEarned',
                      color: PWColors.yellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      emoji: '\u{1F4D6}', // 📖
                      value: '${storyRegistry.length}',
                      label: 'Stories\nRead',
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Countries visited ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Countries Visited',
                  style: GoogleFonts.baloo2(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: PWColors.navy,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (countries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Text(
                        '\u{1F30D}', // 🌍
                        style: TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Start exploring to fill\nyour passport!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PWColors.navy.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...countries.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CountryStamp(country: c),
                    )),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat card (countries explored, badges, stories)
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: PWColors.navy.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Country stamp card
// ---------------------------------------------------------------------------

class _ExploredCountry {
  const _ExploredCountry({
    required this.id,
    required this.name,
    required this.flag,
    required this.continent,
    required this.hasStory,
    required this.hasColoring,
  });

  final String id;
  final String name;
  final String flag;
  final String continent;
  final bool hasStory;
  final bool hasColoring;
}

class _CountryStamp extends StatelessWidget {
  const _CountryStamp({required this.country});

  final _ExploredCountry country;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Flag
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: PWColors.yellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                country.flag,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Country info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: PWColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  country.continent,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PWColors.navy.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 8),
                // Badge chips
                Row(
                  children: [
                    if (country.hasStory)
                      _BadgeChip(
                        label: 'Story',
                        color: const Color(0xFFFF9800),
                      ),
                    if (country.hasStory && country.hasColoring)
                      const SizedBox(width: 8),
                    if (country.hasColoring)
                      _BadgeChip(
                        label: 'Coloring',
                        color: const Color(0xFF9C27B0),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Stamp icon
          Text(
            '\u{2705}', // ✅
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
