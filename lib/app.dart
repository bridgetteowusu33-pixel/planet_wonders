import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/motion/motion_settings_provider.dart';
import 'core/theme/pw_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/achievements/ui/achievement_tracker.dart';
import 'features/creative_studio/canvas_screen.dart';
import 'features/creative_studio/creative_studio_home.dart';
import 'features/creative_studio/draw_mode_selector.dart';
import 'features/creative_studio/gallery_screen.dart';
import 'features/creative_studio/prompt_picker.dart';
import 'features/creative_studio/scene_picker.dart';
import 'features/creative_studio/creative_state.dart';
import 'features/draw_with_me/models/trace_shape.dart';
import 'features/draw_with_me/ui/decorate_screen.dart';
import 'features/draw_with_me/ui/draw_with_me_home.dart';
import 'features/draw_with_me/ui/trace_screen.dart';
import 'features/fashion/screens/all_fashion_screen.dart';
import 'features/fashion/models/outfit_snapshot.dart';
import 'features/fashion/screens/color_outfit_screen.dart';
import 'features/fashion/screens/fashion_screen.dart';
import 'features/coloring/screens/all_coloring_pages_screen.dart';
import 'features/coloring/screens/coloring_list_screen.dart';
import 'features/coloring/screens/coloring_page_screen.dart';
import 'features/cooking_game/cooking_game_screen.dart';
import 'features/cooking_game/cooking_home.dart';
import 'features/cooking_game/cooking_recipe_story_screen.dart';
import 'features/cooking_game/data/recipes_ghana.dart';
import 'features/food/screens/food_detail_screen.dart';
import 'features/food/screens/food_home_screen.dart';
import 'features/games/screens/games_hub_screen.dart';
import 'features/gallery/gallery_screen.dart';
import 'features/home/home_screen.dart';
import 'features/parents/parents_screen.dart';
import 'features/passport/passport_screen.dart';
import 'features/recipe_story/presentation/recipe_album_screen.dart';
import 'features/recipe_story/presentation/recipe_list_screen.dart';
import 'features/recipe_story/presentation/recipe_story_screen.dart';
import 'features/stories/screens/all_stories_screen.dart';
import 'features/stories/screens/story_complete_screen.dart';
import 'features/stories/screens/story_screen.dart';
import 'features/world_explorer/screens/continent_screen.dart';
import 'features/world_explorer/screens/country_hub_screen.dart';
import 'features/game_breaks/screens/memory_match_screen.dart';
import 'features/learning_report/screens/learning_report_screen.dart';
import 'features/screen_time/lock/lock_overlay.dart';
import 'features/screen_time/providers/usage_tracker_provider.dart';
import 'features/screen_time/screens/screen_time_screen.dart';
import 'features/world_explorer/screens/world_explorer_screen.dart';

CreativeEntryMode _creativeModeFromQuery(String? raw) {
  switch (raw) {
    case 'draw_with_me':
      return CreativeEntryMode.drawWithMe;
    case 'scene_builder':
      return CreativeEntryMode.sceneBuilder;
    case 'free_draw':
    default:
      return CreativeEntryMode.freeDraw;
  }
}

TraceDifficulty _traceDifficultyFromQuery(String? raw) {
  switch (raw) {
    case 'hard':
      return TraceDifficulty.hard;
    case 'medium':
      return TraceDifficulty.medium;
    case 'easy':
    default:
      return TraceDifficulty.easy;
  }
}

class PlanetWondersApp extends ConsumerStatefulWidget {
  const PlanetWondersApp({super.key});

  @override
  ConsumerState<PlanetWondersApp> createState() => _PlanetWondersAppState();
}

class _PlanetWondersAppState extends ConsumerState<PlanetWondersApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh bedtime window on resume (covers timezone changes too).
      ref.read(bedtimeProvider.notifier).onAppResumed();
      ref.read(usageTrackerProvider.notifier).onAppResumed();
    } else if (state == AppLifecycleState.paused) {
      ref.read(usageTrackerProvider.notifier).onAppPaused();
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    // Pick up system reduce-motion changes.
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final mq = MediaQueryData.fromView(view);
    ref
        .read(motionSettingsProvider.notifier)
        .updateSystemReduceMotion(mq.disableAnimations);
  }

  late final GoRouter _router = GoRouter(
    routes: [
      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/draw',
        builder: (context, state) => const CreativeStudioHomeScreen(),
      ),
      GoRoute(
        path: '/creative-studio',
        builder: (context, state) => const CreativeStudioHomeScreen(),
        routes: [
          GoRoute(
            path: 'mode',
            builder: (context, state) => DrawModeSelectorScreen(
              initialMode: _creativeModeFromQuery(
                state.uri.queryParameters['initial'],
              ),
            ),
          ),
          GoRoute(
            path: 'prompts',
            builder: (context, state) => const PromptPickerScreen(),
          ),
          GoRoute(
            path: 'scenes',
            builder: (context, state) => const ScenePickerScreen(),
          ),
          GoRoute(
            path: 'my-art',
            builder: (context, state) => const CreativeStudioGalleryScreen(),
          ),
          GoRoute(
            path: 'canvas',
            builder: (context, state) => CreativeCanvasScreen(
              mode: _creativeModeFromQuery(state.uri.queryParameters['mode']),
              promptId: state.uri.queryParameters['promptId'],
              sceneId: state.uri.queryParameters['sceneId'],
              projectId: state.uri.queryParameters['projectId'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/draw-with-me',
        builder: (context, state) => const DrawWithMeHomeScreen(),
        routes: [
          GoRoute(
            path: 'trace/:packId/:shapeId',
            builder: (context, state) => TraceScreen(
              packId: state.pathParameters['packId']!,
              shapeId: state.pathParameters['shapeId']!,
              initialDifficulty: _traceDifficultyFromQuery(
                state.uri.queryParameters['difficulty'],
              ),
            ),
          ),
          GoRoute(
            path: 'decorate/:packId/:shapeId',
            builder: (context, state) => DecorateScreen(
              packId: state.pathParameters['packId']!,
              shapeId: state.pathParameters['shapeId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/coloring',
        builder: (context, state) => const AllColoringPagesScreen(),
      ),
      GoRoute(
        path: '/color/:countryId',
        builder: (context, state) =>
            ColoringListScreen(countryId: state.pathParameters['countryId']!),
        routes: [
          GoRoute(
            path: ':pageId',
            builder: (context, state) => ColoringPageScreen(
              countryId: state.pathParameters['countryId']!,
              pageId: state.pathParameters['pageId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/fashion',
        builder: (context, state) => const AllFashionScreen(),
      ),
      GoRoute(
        path: '/food/:countryId',
        builder: (context, state) =>
            FoodHomeScreen(countryId: state.pathParameters['countryId']!),
        routes: [
          GoRoute(
            path: ':dishId',
            builder: (context, state) => FoodDetailScreen(
              countryId: state.pathParameters['countryId']!,
              dishId: state.pathParameters['dishId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/recipe-album',
        builder: (context, state) => const RecipeAlbumScreen(),
      ),
      GoRoute(
        path: '/recipe-story/:countryId',
        builder: (context, state) => RecipeListScreen(
          countryId: state.pathParameters['countryId']!,
          source: state.uri.queryParameters['source'] ?? 'food',
        ),
        routes: [
          GoRoute(
            path: ':recipeId',
            builder: (context, state) => RecipeStoryScreen(
              countryId: state.pathParameters['countryId']!,
              recipeId: state.pathParameters['recipeId']!,
              source: state.uri.queryParameters['source'] ?? 'food',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/fashion/:countryId',
        builder: (context, state) =>
            FashionScreen(countryId: state.pathParameters['countryId']!),
        routes: [
          GoRoute(
            path: 'color',
            builder: (context, state) =>
                ColorOutfitScreen(snapshot: state.extra! as OutfitSnapshot),
          ),
        ],
      ),
      GoRoute(
        path: '/stories',
        builder: (context, state) => const AllStoriesScreen(),
      ),
      GoRoute(
        path: '/story/:countryId',
        builder: (context, state) =>
            StoryScreen(countryId: state.pathParameters['countryId']!),
        routes: [
          GoRoute(
            path: 'complete',
            builder: (context, state) => StoryCompleteScreen(
              countryId: state.pathParameters['countryId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/game-break/memory/:countryId',
        builder: (context, state) =>
            MemoryMatchScreen(countryId: state.pathParameters['countryId']!),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const LearningReportScreen(),
      ),
      GoRoute(
        path: '/cooking',
        builder: (context, state) {
          final source = state.uri.queryParameters['source'] ?? 'home';
          final view = state.uri.queryParameters['view'] ?? 'hub';
          final countryId = state.uri.queryParameters['countryId'];
          final recipeId = state.uri.queryParameters['recipeId'];

          final recipe =
              (recipeId != null ? findCookingRecipe(recipeId) : null) ??
              (countryId != null
                  ? defaultCookingRecipeForCountry(countryId)
                  : null) ??
              defaultCookingRecipeForCountry('ghana');

          final resolvedCountryId = (countryId != null && countryId.isNotEmpty)
              ? countryId
              : recipe?.countryId ?? 'ghana';

          if (view == 'play') {
            if (recipe == null) {
              return CookingHubScreen(
                source: source,
                countryId: resolvedCountryId,
                recipe: null,
              );
            }
            return CookingGameScreen(
              recipe: recipe,
              entrySource: source,
              entryCountryId: resolvedCountryId,
            );
          }

          if (view == 'story') {
            if (recipe == null) {
              return CookingHubScreen(
                source: source,
                countryId: resolvedCountryId,
                recipe: null,
              );
            }
            return CookingRecipeStoryScreen(
              recipe: recipe,
              countryId: resolvedCountryId,
              source: source,
            );
          }

          return CookingHubScreen(
            source: source,
            countryId: resolvedCountryId,
            recipe: recipe,
          );
        },
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementTrackerScreen(),
      ),
      GoRoute(
        path: '/screen-time',
        builder: (context, state) => const ScreenTimeScreen(),
      ),
      GoRoute(
        path: '/games/:countryId',
        builder: (context, state) =>
            GamesHubScreen(countryId: state.pathParameters['countryId']!),
      ),
      GoRoute(
        path: '/world',
        builder: (context, state) => const WorldExplorerScreen(),
        routes: [
          GoRoute(
            path: ':continentId',
            builder: (context, state) => ContinentScreen(
              continentId: state.pathParameters['continentId']!,
            ),
            routes: [
              GoRoute(
                path: ':countryId',
                builder: (context, state) => CountryHubScreen(
                  continentId: state.pathParameters['continentId']!,
                  countryId: state.pathParameters['countryId']!,
                ),
              ),
            ],
          ),
        ],
      ),

      // Tab routes (with bottom nav shell)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _Shell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gallery',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: GalleryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/passport',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: PassportScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/parents',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: ParentsScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final effectiveMode = ref.watch(effectiveThemeModeProvider);
    final motionSettings = ref.watch(motionSettingsProvider);

    const showPerfOverlay = bool.fromEnvironment(
      'PW_SHOW_PERF_OVERLAY',
      defaultValue: false,
    );
    const showCheckerboardRasterCache = bool.fromEnvironment(
      'PW_CHECKERBOARD_RASTER_CACHE',
      defaultValue: false,
    );
    const showCheckerboardOffscreenLayers = bool.fromEnvironment(
      'PW_CHECKERBOARD_OFFSCREEN',
      defaultValue: false,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: kDebugMode && showPerfOverlay,
      checkerboardRasterCacheImages: kDebugMode && showCheckerboardRasterCache,
      checkerboardOffscreenLayers:
          kDebugMode && showCheckerboardOffscreenLayers,
      theme: planetWondersLightTheme(
        reduceMotion: motionSettings.reduceMotionEffective,
      ),
      darkTheme: planetWondersDarkTheme(
        reduceMotion: motionSettings.reduceMotionEffective,
      ),
      themeMode: effectiveMode,
      routerConfig: _router,
      builder: (context, child) {
        final tracker = ref.watch(usageTrackerProvider);
        final showLock = tracker.isLocked || tracker.isBedtimeLocked;
        if (!showLock) return child!;
        return Stack(
          children: [
            child!,
            LockOverlay(
              reason: tracker.isBedtimeLocked
                  ? LockReason.bedtime
                  : LockReason.dailyLimit,
            ),
          ],
        );
      },
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: RepaintBoundary(child: navigationShell),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: RepaintBoundary(
            child: _StickerBottomNav(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StickerBottomNav extends StatelessWidget {
  const _StickerBottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _tabs = <_StickerTabData>[
    _StickerTabData(
      label: 'Home',
      icon: Icons.home_rounded,
      iconAsset: 'assets/icons/home.png',
      fallbackEmoji: '\u{1F3E0}',
      top: Color(0xFF2A66E5),
      bottom: Color(0xFF1D46AA),
    ),
    _StickerTabData(
      label: 'Gallery',
      icon: Icons.photo_size_select_actual_rounded,
      iconAsset: 'assets/icons/gallery.png',
      fallbackEmoji: '\u{1F5BC}',
      top: Color(0xFFFFD54F),
      bottom: Color(0xFFEEA820),
    ),
    _StickerTabData(
      label: 'Passport',
      icon: Icons.public_rounded,
      iconAsset: 'assets/icons/passport.png',
      fallbackEmoji: '\u{1F30D}',
      top: Color(0xFF5CCBFF),
      bottom: Color(0xFF268FD8),
    ),
    _StickerTabData(
      label: 'Parents',
      icon: Icons.lock_rounded,
      iconAsset: 'assets/icons/parents.png',
      fallbackEmoji: '\u{1F512}',
      top: Color(0xFF2A66E5),
      bottom: Color(0xFF1D46AA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final iconCacheSize = (72 * dpr).round().clamp(1, 1024).toInt();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        color: const Color(0xFF1542A8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33122D5D),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final isSelected = index == selectedIndex;
          final top = isSelected
              ? const Color(0xFFFFD54F)
              : const Color(0xFF2C67DF);
          final bottom = isSelected
              ? const Color(0xFFEEA820)
              : const Color(0xFF1D49A9);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => onDestinationSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    // Dark edge underneath for 3D depth
                    color: Color.lerp(bottom, Colors.black, 0.35),
                  ),
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [top, bottom],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Top shine highlight
                        Positioned(
                          left: 5,
                          right: 5,
                          top: 5,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.40),
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: tab.iconAsset != null
                                    ? Image.asset(
                                        tab.iconAsset!,
                                        fit: BoxFit.contain,
                                        cacheWidth: iconCacheSize,
                                        cacheHeight: iconCacheSize,
                                        filterQuality: FilterQuality.low,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  tab.icon,
                                                  color: Colors.white,
                                                  size: 52,
                                                ),
                                      )
                                    : Icon(
                                        tab.icon,
                                        color: Colors.white,
                                        size: 52,
                                      ),
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  tab.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.fredoka(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    height: 1.05,
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
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StickerTabData {
  const _StickerTabData({
    required this.label,
    required this.icon,
    required this.top,
    required this.bottom,
    this.iconAsset,
    this.fallbackEmoji,
  });

  final String label;
  final IconData icon;
  final Color top;
  final Color bottom;
  final String? iconAsset;
  final String? fallbackEmoji;
}
