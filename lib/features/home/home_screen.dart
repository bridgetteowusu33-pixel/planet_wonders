import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/pw_theme.dart';
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
    for (final asset in _warmupAssets) {
      unawaited(
        precacheImage(AssetImage(asset), context).catchError((_) {
          // Optional assets are allowed to be absent during local iteration.
        }),
      );
    }
  }

  static const List<String> _warmupAssets = <String>[
    'assets/backgrounds/home_beach_bg.png',
    'assets/logos/planet_wonders_logo.png',
    'assets/icons/world.png',
    'assets/icons/book.png',
    'assets/icons/crayon.png',
    'assets/icons/palette.png',
    'assets/icons/dress.png',
    'assets/icons/cooking.png',
    'assets/icons/home.png',
    'assets/icons/gallery.png',
    'assets/icons/passport.png',
    'assets/icons/parents.png',
  ];

  @override
  Widget build(BuildContext context) {
    final actions = <_HomeStickerConfig>[
      _HomeStickerConfig(
        title: 'World Explorer',
        iconAsset: 'assets/icons/world.png',
        fallbackEmoji: '🌍',
        gradientTop: const Color(0xFFFFD64C),
        gradientBottom: const Color(0xFFF3A91D),
        onTap: () => context.push('/world'),
      ),
      _HomeStickerConfig(
        title: 'Stories',
        iconAsset: 'assets/icons/book.png',
        fallbackEmoji: '📖',
        gradientTop: const Color(0xFF2F9DFF),
        gradientBottom: const Color(0xFF215AE5),
        onTap: () => context.push('/stories'),
      ),
      _HomeStickerConfig(
        title: 'Coloring Pages',
        iconAsset: 'assets/icons/crayon.png',
        fallbackEmoji: '🖍️',
        gradientTop: const Color(0xFFFF6B5F),
        gradientBottom: const Color(0xFFE23C2D),
        onTap: () => context.push('/coloring'),
      ),
      _HomeStickerConfig(
        title: 'Start Drawing',
        iconAsset: 'assets/icons/palette.png',
        fallbackEmoji: '🎨',
        gradientTop: const Color(0xFFFF7656),
        gradientBottom: const Color(0xFFDA3429),
        onTap: () => context.push('/draw'),
      ),
      _HomeStickerConfig(
        title: 'Fashion Studio',
        iconAsset: 'assets/icons/dress.png',
        fallbackEmoji: '👗',
        gradientTop: const Color(0xFF5BE3CF),
        gradientBottom: const Color(0xFF20AFA0),
        onTap: () => context.push('/fashion'),
      ),
      _HomeStickerConfig(
        title: 'Cooking Fun',
        iconAsset: 'assets/icons/cooking.png',
        fallbackEmoji: '🍳',
        gradientTop: const Color(0xFFFFC23B),
        gradientBottom: const Color(0xFFEA8B1D),
        onTap: () => context.push('/cooking?source=home&view=hub'),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const _HomeScenicBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= 900;
                final contentMaxWidth = isTablet ? 980.0 : 760.0;
                final horizontalPadding = isTablet ? 24.0 : 16.0;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: CustomScrollView(
                      cacheExtent: 900,
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                _HomeLogo(isTablet: isTablet),
                                const SizedBox(height: 4),
                                Text(
                                  'What would you like to explore today?',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.baloo2(
                                    fontSize: isTablet ? 30 : 24,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1F3A83),
                                    shadows: const [
                                      Shadow(
                                        color: Colors.white,
                                        offset: Offset(0, 2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => RepaintBoundary(
                                child: _HomeStickerButton(
                                  config: actions[index],
                                  isTablet: isTablet,
                                ),
                              ),
                              childCount: actions.length,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: isTablet ? 16 : 12,
                                  crossAxisSpacing: isTablet ? 16 : 12,
                                  childAspectRatio: isTablet ? 1.20 : 1.10,
                                ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          sliver: const SliverToBoxAdapter(
                            child: SizedBox(height: 8),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          sliver: const SliverToBoxAdapter(
                            child: RepaintBoundary(child: _PassportCard()),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          sliver: const SliverToBoxAdapter(
                            child: SizedBox(height: 16),
                          ),
                        ),
                      ],
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
          filterQuality: FilterQuality.low,
          errorBuilder: (context, error, stackTrace) {
            return const GradientBackground(child: SizedBox.expand());
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.14),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.08),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeLogo extends StatelessWidget {
  const _HomeLogo({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final logoHeight = isTablet ? 260.0 : 220.0;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheHeight = (logoHeight * dpr).round().clamp(1, 4096).toInt();

    return SizedBox(
      height: logoHeight,
      child: Image.asset(
        'assets/logos/planet_wonders_logo.png',
        fit: BoxFit.contain,
        cacheHeight: cacheHeight,
        filterQuality: FilterQuality.low,
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

class _HomeStickerButton extends StatelessWidget {
  const _HomeStickerButton({required this.config, required this.isTablet});

  final _HomeStickerConfig config;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final iconCacheSize = ((isTablet ? 92 : 78) * dpr)
        .round()
        .clamp(1, 512)
        .toInt();

    final labelStyle = GoogleFonts.baloo2(
      fontSize: isTablet ? 18 : 13,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      height: 1.1,
      shadows: const [
        Shadow(color: Color(0x99000000), offset: Offset(0, 2), blurRadius: 2),
      ],
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: config.onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: Colors.white.withValues(alpha: 0.20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [config.gradientTop, config.gradientBottom],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.94),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14366F).withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 8,
                right: 8,
                top: 8,
                child: Container(
                  height: isTablet ? 34 : 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.34),
                        Colors.white.withValues(alpha: 0.02),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 12,
                top: 16,
                child: Text(
                  '✦',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ),
              Positioned(
                right: 14,
                top: isTablet ? 28 : 22,
                child: const Text(
                  '✦',
                  style: TextStyle(fontSize: 9, color: Colors.white70),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 3),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        config.iconAsset,
                        fit: BoxFit.contain,
                        cacheWidth: iconCacheSize,
                        cacheHeight: iconCacheSize,
                        filterQuality: FilterQuality.low,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              config.fallbackEmoji,
                              style: TextStyle(fontSize: isTablet ? 44 : 36),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: isTablet ? 44 : 34,
                      child: Center(
                        child: Text(
                          config.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle.copyWith(height: 1.0),
                        ),
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

class _HomeStickerConfig {
  const _HomeStickerConfig({
    required this.title,
    required this.iconAsset,
    required this.fallbackEmoji,
    required this.gradientTop,
    required this.gradientBottom,
    required this.onTap,
  });

  final String title;
  final String iconAsset;
  final String fallbackEmoji;
  final Color gradientTop;
  final Color gradientBottom;
  final VoidCallback onTap;
}

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
          Row(
            children: [
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
                          'Badges Earned · $badgesEarned',
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
                  child: Text('🌍', style: TextStyle(fontSize: 40)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
