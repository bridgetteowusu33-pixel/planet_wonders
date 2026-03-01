import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/achievements/ui/achievement_tracker.dart';
import '../../features/stickers/ui/sticker_album_screen.dart';
import '../../features/creative_studio/canvas_screen.dart';
import '../../features/creative_studio/creative_studio_home.dart';
import '../../features/creative_studio/draw_mode_selector.dart';
import '../../features/creative_studio/gallery_screen.dart';
import '../../features/creative_studio/prompt_picker.dart';
import '../../features/creative_studio/scene_picker.dart';
import '../../features/creative_studio/creative_state.dart';
import '../../features/draw_with_me/models/trace_shape.dart';
import '../../features/draw_with_me/ui/decorate_screen.dart';
import '../../features/draw_with_me/ui/draw_with_me_home.dart';
import '../../features/draw_with_me/ui/trace_screen.dart';
import '../../features/fashion/screens/all_fashion_screen.dart';
import '../../features/fashion/models/outfit_snapshot.dart';
import '../../features/fashion/screens/color_outfit_screen.dart';
import '../../features/fashion/screens/fashion_screen.dart';
import '../../features/coloring/screens/all_coloring_pages_screen.dart';
import '../../features/coloring/screens/coloring_list_screen.dart';
import '../../features/coloring/screens/coloring_page_screen.dart';
import '../../features/cooking_game/cooking_home.dart';
import '../../features/cooking_game/cooking_recipe_story_screen.dart';
import '../../features/cooking_game/data/recipes_ghana.dart';
import '../../features/cooking_game/v2/data/v2_recipe_registry.dart';
import '../../features/cooking_game/v2/data/v2_recipes_ghana.dart';
import '../../features/cooking_game/v2/screens/country_kitchen_screen.dart';
import '../../features/cooking_game/v2/screens/my_kitchen_screen.dart';
import '../../features/cooking_game/v2/screens/v2_cooking_shell.dart';
import '../../features/food/screens/food_detail_screen.dart';
import '../../features/food/screens/food_home_screen.dart';
import '../../features/games/screens/games_hub_screen.dart';
import '../../features/gallery/gallery_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/parents/parents_screen.dart';
import '../../features/passport/passport_screen.dart';
import '../../features/recipe_story/presentation/recipe_album_screen.dart';
import '../../features/recipe_story/presentation/recipe_list_screen.dart';
import '../../features/recipe_story/presentation/recipe_story_screen.dart';
import '../../features/stories/screens/all_stories_screen.dart';
import '../../features/stories/screens/story_complete_screen.dart';
import '../../features/stories/screens/story_screen.dart';
import '../../features/world_explorer/screens/continent_screen.dart';
import '../../features/world_explorer/screens/country_hub_screen.dart';
import '../../features/game_breaks/screens/memory_match_screen.dart';
import '../../features/game_breaks/screens/sliding_puzzle_screen.dart';
import '../../features/ingredient_rush/screens/ingredient_rush_screen.dart';
import '../../features/pack_suitcase/screens/pack_suitcase_screen.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/learning_report/screens/learning_report_screen.dart';
import '../../features/puzzles/presentation/puzzle_home_screen.dart';
import '../../features/puzzles/presentation/puzzle_pack_screen.dart';
import '../../features/puzzles/presentation/puzzle_play_screen.dart';
import '../../features/screen_time/screens/screen_time_screen.dart';
import '../../features/world_explorer/screens/world_explorer_screen.dart';

/// Signature for the shell builder used by [StatefulShellRoute].
typedef ShellBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  StatefulNavigationShell navigationShell,
);

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

/// Known sub-paths under /games that are NOT country IDs.
const _gamesSubRoutes = {'puzzles', 'memory', 'puzzle', 'ingredient-rush', 'pack-suitcase'};

/// Builds the app-wide [GoRouter].
GoRouter buildAppRouter({
  required GlobalKey<NavigatorState> navigatorKey,
  required ShellBuilder shellBuilder,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    redirect: (context, state) {
      // Backward compat: /games/<countryId> → /games?countryId=<countryId>
      final segments = state.uri.pathSegments;
      if (segments.length == 2 &&
          segments[0] == 'games' &&
          !_gamesSubRoutes.contains(segments[1])) {
        return '/games?countryId=${segments[1]}';
      }
      return null;
    },
    routes: [
      // ── Full-screen routes (no bottom nav) ──
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
            // Always use V2 cooking engine.
            final v2Id = recipeId != null ? '${recipeId}_v2' : null;
            final v2Recipe =
                (v2Id != null ? findV2Recipe(v2Id) : null) ??
                (recipeId != null ? findV2Recipe(recipeId) : null);
            if (v2Recipe != null) {
              return V2CookingShell(recipe: v2Recipe);
            }
            // Fall back to country kitchen picker.
            return CountryKitchenScreen(countryId: resolvedCountryId);
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
        path: '/cooking-v2',
        builder: (context, state) {
          final recipeId = state.uri.queryParameters['recipeId'];
          // Look up V2 recipe from global registry; fall back to Ghana Jollof.
          final recipe = (recipeId != null ? findV2Recipe(recipeId) : null) ??
              ghanaJollofV2;
          return V2CookingShell(recipe: recipe);
        },
      ),
      GoRoute(
        path: '/cooking-v2-kitchen',
        builder: (context, state) {
          final countryId =
              state.uri.queryParameters['countryId'] ?? 'ghana';
          return CountryKitchenScreen(countryId: countryId);
        },
      ),
      GoRoute(
        path: '/my-kitchen',
        builder: (context, state) => const MyKitchenScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementTrackerScreen(),
      ),
      GoRoute(
        path: '/sticker-album',
        builder: (context, state) => const StickerAlbumScreen(),
      ),
      GoRoute(
        path: '/screen-time',
        builder: (context, state) => const ScreenTimeScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) {
          final daily = state.uri.queryParameters['daily'] == 'true';
          final quizId = state.uri.queryParameters['quizId'];
          final countryId = state.uri.queryParameters['countryId'];
          return QuizScreen(
            daily: daily,
            quizId: quizId,
            countryId: countryId,
          );
        },
      ),

      // ── Games ──
      GoRoute(
        path: '/games',
        builder: (context, state) {
          final countryId = state.uri.queryParameters['countryId'];
          return GamesHubScreen(initialCountryId: countryId);
        },
        routes: [
          GoRoute(
            path: 'puzzles',
            builder: (context, state) => const PuzzleHomeScreen(),
            routes: [
              GoRoute(
                path: 'pack/:packId',
                builder: (context, state) => PuzzlePackScreen(
                  packId: state.pathParameters['packId']!,
                ),
              ),
              GoRoute(
                path: 'play/:puzzleId',
                builder: (context, state) => PuzzlePlayRouteGate(
                  puzzleId: state.pathParameters['puzzleId']!,
                  packId: state.uri.queryParameters['packId'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'memory/:countryId',
            builder: (context, state) => MemoryMatchScreen(
              countryId: state.pathParameters['countryId']!,
            ),
          ),
          GoRoute(
            path: 'puzzle/:countryId',
            builder: (context, state) => SlidingPuzzleScreen(
              countryId: state.pathParameters['countryId']!,
            ),
          ),
          GoRoute(
            path: 'ingredient-rush',
            builder: (context, state) => IngredientRushScreen(
              countryId:
                  state.uri.queryParameters['countryId'] ?? 'ghana',
              recipeId: state.uri.queryParameters['recipeId'],
              initialDifficulty:
                  state.uri.queryParameters['difficulty'] ?? 'easy',
            ),
          ),
          GoRoute(
            path: 'pack-suitcase',
            builder: (context, state) => PackSuitcaseScreen(
              countryId:
                  state.uri.queryParameters['countryId'] ?? 'ghana',
              packId: state.uri.queryParameters['packId'],
            ),
          ),
        ],
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

      // ── Tab routes (with bottom nav shell) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            shellBuilder(context, state, navigationShell),
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
}
