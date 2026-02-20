import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/pw_theme.dart';
import '../achievements/providers/achievement_provider.dart';
import '../achievements/ui/badge_unlock_animation.dart';
import '../coloring/data/coloring_data.dart';
import '../stories/data/story_data.dart';
import '../world_explorer/data/world_data.dart';

/// Passport screen — shows explorer profile, visited countries, and achievements.
class PassportScreen extends ConsumerWidget {
  const PassportScreen({super.key});

  List<_ExploredCountry> get _exploredCountries {
    final explored = <_ExploredCountry>[];
    for (final continent in worldContinents) {
      for (final country in continent.countries) {
        if (country.isUnlocked) {
          explored.add(
            _ExploredCountry(
              id: country.id,
              name: country.name,
              flag: country.flagEmoji,
              continent: continent.name,
              hasStory: storyRegistry.containsKey(country.id),
              hasColoring: coloringRegistry.containsKey(country.id),
            ),
          );
        }
      }
    }
    return explored;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = _exploredCountries;
    final achievementState = ref.watch(achievementProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'My Passport',
                    style: GoogleFonts.baloo2(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: PWColors.navy,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildExplorerCard(),
                  const SizedBox(height: 20),
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
                          emoji: '\u{1F3C6}', // 🏆
                          value: '${achievementState.unlockedCount}',
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
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => context.push('/achievements'),
                    icon: const Icon(Icons.emoji_events_rounded),
                    label: const Text('View Achievements'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: PWColors.mint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                            '\u{1F30D}',
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
                    ...countries.map((country) {
                      final countryBadges = achievementState.loading
                          ? const <_CountryBadge>[]
                          : achievementState
                                .unlockedAchievementsForCountry(country.id)
                                .map(
                                  (achievement) => _CountryBadge(
                                    title: achievement.title,
                                    iconPath: achievement.iconPath,
                                  ),
                                )
                                .toList(growable: false);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CountryStamp(
                          country: country,
                          countryBadges: countryBadges,
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const BadgeUnlockAnimationListener(),
          ],
        ),
      ),
    );
  }

  Widget _buildExplorerCard() {
    return Container(
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.3),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Center(
              child: Text('\u{1F30D}', style: TextStyle(fontSize: 40)),
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
    );
  }
}

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

class _CountryBadge {
  const _CountryBadge({required this.title, required this.iconPath});

  final String title;
  final String iconPath;
}

class _CountryStamp extends StatelessWidget {
  const _CountryStamp({required this.country, required this.countryBadges});

  final _ExploredCountry country;
  final List<_CountryBadge> countryBadges;

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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: PWColors.yellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(country.flag, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 14),
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
                if (countryBadges.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: countryBadges
                        .map((badge) => _CountryAchievementChip(badge: badge))
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
          const Text('\u{2705}', style: TextStyle(fontSize: 24)),
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

class _CountryAchievementChip extends StatelessWidget {
  const _CountryAchievementChip({required this.badge});

  final _CountryBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PWColors.mint.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: PWColors.mint.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.asset(
              badge.iconPath,
              width: 18,
              height: 18,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.emoji_events_rounded,
                size: 16,
                color: PWColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            badge.title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: PWColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
