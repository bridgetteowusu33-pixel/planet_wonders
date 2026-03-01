import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/pw_theme.dart';
import '../../../shared/widgets/flying_airplane.dart';
import '../data/world_data.dart';
import '../widgets/continent_card.dart';

/// Top-level World Explorer — a grid of continents to choose from.
class WorldExplorerScreen extends StatelessWidget {
  const WorldExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'World Explorer',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: PWColors.navy,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: PWColors.navy),
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_rounded, color: PWColors.navy),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/backgrounds/world/continents.webp',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.25),
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
          const FlyingAirplane(),
          SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final crossAxisCount = w >= 900 ? 5 : w >= 600 ? 4 : 3;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // --- Hero header ---
                      _HeroHeader(),

                      const SizedBox(height: 16),

                      // --- Continent grid ---
                      Expanded(
                        child: GridView.builder(
                          itemCount: worldContinents.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemBuilder: (context, index) {
                            final continent = worldContinents[index];
                            return ContinentCard(
                              continent: continent,
                              onTap: () =>
                                  context.push('/world/${continent.id}'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero header for the continents page
// ---------------------------------------------------------------------------

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PWColors.blue.withValues(alpha: 0.15),
            PWColors.mint.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            '\u{1F30D} There are 7 continents in the world!',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PWColors.navy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Each one has unique cultures, food, stories, music, '
            'and adventures waiting for you.',
            style: GoogleFonts.fredoka(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: PWColors.navy,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: PWColors.yellow.withValues(alpha: 0.3),
            ),
            child: Text(
              '\u{2708}\u{FE0F} Where would you like to travel today?',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PWColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: PWColors.coral.withValues(alpha: 0.12),
            ),
            child: Text(
              '\u{1F4A1} The 7th continent is Antarctica \u{2014} '
              'it has no countries, just penguins and scientists!',
              style: GoogleFonts.fredoka(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: PWColors.navy,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
