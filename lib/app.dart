import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/pw_theme.dart';
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
import 'features/recipe_story/presentation/recipe_list_screen.dart';
import 'features/recipe_story/presentation/recipe_story_screen.dart';
import 'features/stories/screens/all_stories_screen.dart';
import 'features/stories/screens/story_complete_screen.dart';
import 'features/stories/screens/story_screen.dart';
import 'features/world_explorer/screens/continent_screen.dart';
import 'features/world_explorer/screens/country_hub_screen.dart';
import 'features/game_breaks/screens/memory_match_screen.dart';
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

class PlanetWondersApp extends StatelessWidget {
  PlanetWondersApp({super.key});

  final GoRouter _router = GoRouter(
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
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gallery',
                builder: (context, state) => const GalleryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/passport',
                builder: (context, state) => const PassportScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/parents',
                builder: (context, state) => const ParentsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: planetWondersTheme(),
      routerConfig: _router,
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFFFF7A7A)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_rounded),
            selectedIcon: Icon(
              Icons.photo_library_rounded,
              color: Color(0xFF6EC6E9),
            ),
            label: 'Gallery',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_rounded),
            selectedIcon: Icon(Icons.book_rounded, color: Color(0xFFFFD84D)),
            label: 'Passport',
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_rounded),
            selectedIcon: Icon(Icons.lock_rounded, color: Color(0xFF7ED6B2)),
            label: 'Parents',
          ),
        ],
      ),
    );
  }
}
