import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/pw_theme.dart';
import 'features/coloring/drawing_screen.dart';
import 'features/fashion/screens/all_fashion_screen.dart';
import 'features/fashion/models/outfit_snapshot.dart';
import 'features/fashion/screens/color_outfit_screen.dart';
import 'features/fashion/screens/fashion_screen.dart';
import 'features/coloring/screens/all_coloring_pages_screen.dart';
import 'features/coloring/screens/coloring_list_screen.dart';
import 'features/coloring/screens/coloring_page_screen.dart';
import 'features/gallery/gallery_screen.dart';
import 'features/home/home_screen.dart';
import 'features/parents/parents_screen.dart';
import 'features/passport/passport_screen.dart';
import 'features/stories/screens/all_stories_screen.dart';
import 'features/stories/screens/story_complete_screen.dart';
import 'features/stories/screens/story_screen.dart';
import 'features/world_explorer/screens/continent_screen.dart';
import 'features/world_explorer/screens/country_hub_screen.dart';
import 'features/game_breaks/screens/memory_match_screen.dart';
import 'features/world_explorer/screens/world_explorer_screen.dart';

class PlanetWondersApp extends StatelessWidget {
  PlanetWondersApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/draw',
        builder: (context, state) => const DrawingScreen(),
      ),
      GoRoute(
        path: '/coloring',
        builder: (context, state) => const AllColoringPagesScreen(),
      ),
      GoRoute(
        path: '/color/:countryId',
        builder: (context, state) => ColoringListScreen(
          countryId: state.pathParameters['countryId']!,
        ),
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
        path: '/fashion/:countryId',
        builder: (context, state) => FashionScreen(
          countryId: state.pathParameters['countryId']!,
        ),
        routes: [
          GoRoute(
            path: 'color',
            builder: (context, state) => ColorOutfitScreen(
              snapshot: state.extra! as OutfitSnapshot,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/stories',
        builder: (context, state) => const AllStoriesScreen(),
      ),
      GoRoute(
        path: '/story/:countryId',
        builder: (context, state) => StoryScreen(
          countryId: state.pathParameters['countryId']!,
        ),
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
        builder: (context, state) => MemoryMatchScreen(
          countryId: state.pathParameters['countryId']!,
        ),
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
      ShellRoute(
        builder: (context, state, child) => _Shell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/gallery',
            builder: (context, state) => const GalleryScreen(),
          ),
          GoRoute(
            path: '/passport',
            builder: (context, state) => const PassportScreen(),
          ),
          GoRoute(
            path: '/parents',
            builder: (context, state) => const ParentsScreen(),
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
  const _Shell({required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith('/gallery')) return 1;
    if (location.startsWith('/passport')) return 2;
    if (location.startsWith('/parents')) return 3;
    return 0;
  }

  String _locationForIndex(int index) {
    switch (index) {
      case 1:
        return '/gallery';
      case 2:
        return '/passport';
      case 3:
        return '/parents';
      default:
        return '/';
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexForLocation(location),
        onDestinationSelected: (index) {
          context.go(_locationForIndex(index));
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFFFF7A7A)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_rounded),
            selectedIcon:
                Icon(Icons.photo_library_rounded, color: Color(0xFF6EC6E9)),
            label: 'Gallery',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_rounded),
            selectedIcon:
                Icon(Icons.book_rounded, color: Color(0xFFFFD84D)),
            label: 'Passport',
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_rounded),
            selectedIcon:
                Icon(Icons.lock_rounded, color: Color(0xFF7ED6B2)),
            label: 'Parents',
          ),
        ],
      ),
    );
  }
}