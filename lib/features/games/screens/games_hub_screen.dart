import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../../shared/widgets/flying_airplane.dart';
import '../../cooking_game/data/recipes_ghana.dart';
import '../providers/game_country_provider.dart';
import '../widgets/game_card.dart';

/// Centralized games hub — accessible from the Home screen.
///
/// Shows all game types with a country picker for country-specific games
/// (Memory Match, Sliding Puzzle, Cooking, Guess & Learn).
class GamesHubScreen extends ConsumerStatefulWidget {
  const GamesHubScreen({super.key, this.initialCountryId});

  /// When navigated from a backward-compat redirect (e.g. /games/ghana),
  /// this pre-selects the country.
  final String? initialCountryId;

  @override
  ConsumerState<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends ConsumerState<GamesHubScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialCountryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(selectedGameCountryProvider.notifier)
            .select(widget.initialCountryId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCountry = ref.watch(selectedGameCountryProvider);
    final countries = unlockedCountries;
    final recipes = cookingRecipesForCountry(selectedCountry);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Games',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          const FlyingAirplane(),
          SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final crossAxisCount = w >= 900 ? 4 : w >= 600 ? 3 : 2;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // ── Banner ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              PWColors.blue.withValues(alpha: 0.25),
                              PWColors.mint.withValues(alpha: 0.24),
                              PWColors.yellow.withValues(alpha: 0.22),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Text(
                          'Pick a game and play!\nShort, fun, and kid-friendly.',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(height: 1.3),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Country picker ──
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: countries.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final c = countries[index];
                            final isSelected = c.id == selectedCountry;
                            return ChoiceChip(
                              label: Text('${c.flag} ${c.name}'),
                              selected: isSelected,
                              onSelected: (_) => ref
                                  .read(selectedGameCountryProvider.notifier)
                                  .select(c.id),
                              selectedColor:
                                  PWColors.blue.withValues(alpha: 0.25),
                              backgroundColor:
                                  PWColors.navy.withValues(alpha: 0.06),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? PWColors.blue.withValues(alpha: 0.5)
                                      : Colors.transparent,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Game grid ──
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.15,
                          children: [
                            GameCard(
                              emoji: '\u{1F9E0}', // 🧠
                              title: 'Memory Match',
                              subtitle: 'Find matching cards',
                              color: PWColors.blue,
                              onTap: () => context
                                  .push('/games/memory/$selectedCountry'),
                            ),
                            GameCard(
                              emoji: '\u{1F9E9}', // 🧩
                              title: 'Sliding Puzzle',
                              subtitle: 'Slide tiles to solve',
                              color: PWColors.coral,
                              onTap: () => context
                                  .push('/games/puzzle/$selectedCountry'),
                            ),
                            GameCard(
                              emoji: '\u{1F9E9}', // 🧩
                              title: 'Jigsaw Puzzles',
                              subtitle: 'Build pictures, earn stars!',
                              color: PWColors.yellow,
                              onTap: () => context.push('/games/puzzles'),
                            ),
                            GameCard(
                              emoji: '\u{2753}', // ❓
                              title: 'Guess & Learn',
                              subtitle: 'Tap to reveal answers!',
                              color: PWColors.mint,
                              onTap: () => context.push(
                                  '/quiz?countryId=$selectedCountry'),
                            ),
                            GameCard(
                              emoji: '\u{1F3A8}', // 🎨
                              title: 'Draw With Me',
                              subtitle: 'Trace & decorate!',
                              color: const Color(0xFFFF7656),
                              onTap: () => context.push('/draw-with-me'),
                            ),
                            GameCard(
                              emoji: '\u{1F3AF}', // 🎯
                              title: 'Ingredient Rush',
                              subtitle: 'Tap the right ingredients!',
                              color: PWColors.coral,
                              onTap: () => context.push(
                                  '/games/ingredient-rush?countryId=$selectedCountry'),
                            ),
                            GameCard(
                              emoji: '\u{1F9F3}', // 🧳
                              title: 'Pack the Suitcase',
                              subtitle: 'Pack for your trip!',
                              color: PWColors.blue,
                              onTap: () => context.push(
                                  '/games/pack-suitcase?countryId=$selectedCountry'),
                            ),
                            GameCard(
                              emoji: '\u{1F373}', // 🍳
                              title: 'Cooking Fun',
                              subtitle: recipes.isEmpty
                                  ? 'Coming soon'
                                  : 'Cook a local recipe',
                              color: const Color(0xFFFFC23B),
                              onTap: () {
                                if (recipes.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Cooking game coming soon for this country.'),
                                    ),
                                  );
                                  return;
                                }
                                context.push(
                                    '/cooking-v2-kitchen?countryId=$selectedCountry');
                              },
                            ),
                          ],
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
