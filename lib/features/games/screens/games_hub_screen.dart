import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../cooking_game/cooking_entry.dart';
import '../../cooking_game/data/recipes_ghana.dart';
import '../../world_explorer/data/world_data.dart';

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
                    _GameCard(
                      emoji: '\u{1F9E0}', // 🧠
                      title: 'Memory Match',
                      subtitle: 'Find matching cards',
                      color: PWColors.blue,
                      onTap: () => context.push('/game-break/memory/$countryId'),
                    ),
                    _GameCard(
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

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: PWColors.navy.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
