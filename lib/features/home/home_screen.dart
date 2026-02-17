import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/pw_theme.dart';
import '../../core/widgets/activity_card.dart';
import '../../core/widgets/gradient_background.dart';
import '../coloring/data/coloring_data.dart';
import '../stories/data/story_data.dart';
import '../world_explorer/data/world_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _didPrecache = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    _didPrecache = true;
    precacheImage(
      const AssetImage('assets/backgrounds/home_beach_bg.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/logos/planet_wonders_logo.png'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _HomeScenicBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= 900;
                final contentMaxWidth = isTablet ? 980.0 : 760.0;
                final horizontalPadding = isTablet ? 28.0 : 20.0;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // --- Title ---
                          _HomeLogo(isTablet: isTablet),
                          const SizedBox(height: 2),
                          Text(
                            'Color the World.',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isTablet ? 22 : 18,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'What wonder will you explore today?',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: isTablet ? 17 : null,
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
                              mainAxisSpacing: isTablet ? 20 : 14,
                              crossAxisSpacing: isTablet ? 20 : 14,
                              childAspectRatio: isTablet ? 1.08 : 0.95,
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
                                      const SnackBar(
                                        content: Text('Coming soon!'),
                                      ),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeScenicBackground extends StatelessWidget {
  const _HomeScenicBackground();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final cacheWidth = mediaQuery == null
        ? null
        : (mediaQuery.size.width * mediaQuery.devicePixelRatio)
              .round()
              .clamp(1, 4096)
              .toInt();

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/backgrounds/home_beach_bg.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          cacheWidth: cacheWidth,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) {
            return const GradientBackground(child: SizedBox.expand());
          },
        ),
        // Keeps foreground text/buttons readable on both phones and iPads.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.18),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Home logo image with graceful fallback text.
class _HomeLogo extends StatelessWidget {
  const _HomeLogo({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final logoHeight = isTablet ? 182.0 : 206.0;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheHeight = (logoHeight * dpr).round().clamp(1, 4096).toInt();

    return SizedBox(
      height: logoHeight,
      child: Image.asset(
        'assets/logos/planet_wonders_logo.png',
        fit: BoxFit.contain,
        cacheHeight: cacheHeight,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          final style = GoogleFonts.baloo2(
            fontSize: isTablet ? 44 : 34,
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
        },
      ),
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
