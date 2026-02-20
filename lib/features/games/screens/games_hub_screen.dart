import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../cooking_game/cooking_entry.dart';
import '../../cooking_game/data/recipes_ghana.dart';
import '../../world_explorer/data/world_data.dart';
import '../widgets/game_card.dart';

/// Country-level games hub.
///
/// Shows available mini-games and launches them in one tap.
class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({
    super.key,
    required this.countryId,
  });

  final String countryId;

  @override
  Widget build(BuildContext context) {
    final country = findCountryById(countryId);
    final recipes = cookingRecipesForCountry(countryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${country?.flagEmoji ?? ''} ${country?.name ?? countryId} · Games',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.3,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.94,
                  children: [
                    GameCard(
                      emoji: '\u{1F9E0}', // 🧠
                      title: 'Memory Match',
                      subtitle: 'Find matching cards',
                      color: PWColors.blue,
                      onTap: () => context.push('/games/$countryId/memory'),
                    ),
                    GameCard(
                      emoji: '\u{1F373}', // 🍳
                      title: 'Cooking',
                      subtitle: recipes.isEmpty
                          ? 'Coming soon'
                          : 'Cook a local recipe',
                      color: PWColors.mint,
                      onTap: () {
                        if (recipes.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cooking game coming soon for this country.'),
                            ),
                          );
                          return;
                        }
                        openCookingHub(
                          context,
                          source: 'games',
                          countryId: countryId,
                          recipeId: recipes.first.id,
                        );
                      },
                    ),
                    GameCard(
                      emoji: '\u{1F9E9}', // 🧩
                      title: 'Sliding Puzzle',
                      subtitle: 'Slide tiles to solve',
                      color: PWColors.coral,
                      onTap: () =>
                          context.push('/games/$countryId/puzzle'),
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
                      color: PWColors.yellow,
                      onTap: () => context
                          .push('/quiz?countryId=$countryId'),
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

