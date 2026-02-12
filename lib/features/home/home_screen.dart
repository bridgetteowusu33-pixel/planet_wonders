import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/pw_theme.dart';
import '../../core/widgets/activity_card.dart';
import '../../core/widgets/gradient_background.dart';
import '../coloring/data/coloring_data.dart';
import '../stories/data/story_data.dart';
import '../world_explorer/data/world_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // --- Title ---
              const _ColorfulTitle(),
              const SizedBox(height: 2),
              Text(
                'Color the World.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'What wonder will you explore today?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
              ),

              const SizedBox(height: 16),

              // --- Passport summary card ---
              const _PassportCard(),

              const SizedBox(height: 4),

              // --- Action card grid (3×2) ---
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                  children: [
                    ActivityCard(
                      emoji: '\u{1F30D}', // 🌍
                      label: 'World\nExplorer',
                      color: const Color(0xFF4CAF50),
                      onTap: () => context.push('/world'),
                    ),
                    ActivityCard(
                      emoji: '\u{1F4D6}', // 📖
                      label: 'Stories',
                      color: const Color(0xFFFF9800),
                      onTap: () => context.push('/stories'),
                    ),
                    ActivityCard(
                      emoji: '\u{1F58D}', // 🖍️
                      label: 'Coloring\nPages',
                      color: const Color(0xFF9C27B0),
                      onTap: () => context.push('/coloring'),
                    ),
                    ActivityCard(
                      emoji: '\u{1F3A8}', // 🎨
                      label: 'Start\nDrawing',
                      color: PWColors.coral,
                      onTap: () => context.push('/draw'),
                    ),
                    ActivityCard(
                      emoji: '\u{1F457}', // 👗
                      label: 'Fashion\nStudio',
                      color: const Color(0xFFE91E63),
                      onTap: () => context.push('/fashion'),
                    ),
                    ActivityCard(
                      emoji: '\u{1F373}', // 🍳
                      label: 'Cooking\nFun',
                      color: const Color(0xFFFF5722),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Multi-color "Planet Wonders" title — each word a different PWColor.
class _ColorfulTitle extends StatelessWidget {
  const _ColorfulTitle();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.baloo2(
      fontSize: 34,
      fontWeight: FontWeight.w800,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Planet', style: style.copyWith(color: PWColors.yellow)),
        const SizedBox(width: 8),
        Text('Wonders', style: style.copyWith(color: Colors.white)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Passport summary card — parchment-style badge on the home screen
// ---------------------------------------------------------------------------

class _PassportCard extends StatelessWidget {
  const _PassportCard();

  @override
  Widget build(BuildContext context) {
    final countriesExplored = worldContinents
        .expand((c) => c.countries)
        .where((c) => c.isUnlocked)
        .length;
    final badgesEarned = storyRegistry.length + coloringRegistry.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4A84B).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF3A7BD5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Planet Wonders Passport',
              style: GoogleFonts.baloo2(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Content row: stats on left, globe on right
          Row(
            children: [
              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explorer: Ava',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: PWColors.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Countries Explored: $countriesExplored',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PWColors.navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 18,
                          color: Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Badges Earned \u00B7 $badgesEarned',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PWColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Globe illustration
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '\u{1F30D}', // 🌍
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
