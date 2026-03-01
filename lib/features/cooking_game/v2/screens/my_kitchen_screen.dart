import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/v2_recipe_registry.dart';
import '../models/v2_recipe.dart';
import '../providers/cooking_progress_provider.dart';

class MyKitchenScreen extends ConsumerWidget {
  const MyKitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(cookingProgressProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFFFF8E7), Color(0xFFFFE8D6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _Header(progress: progress),
              Expanded(
                child: progress.completedRecipes.isEmpty
                    ? const _EmptyState()
                    : _DishGrid(progress: progress),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.progress});

  final CookingProgress progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF264653),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'My Kitchen',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF264653),
                  ),
                ),
              ),
              // Total counter badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD166).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFD166),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('\u{1F373}',
                        style: TextStyle(fontSize: 16)), // 🍳
                    const SizedBox(width: 4),
                    Text(
                      '${progress.totalDishesCooked}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF264653),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _StatChip(
                label: 'Recipes',
                value: '${progress.uniqueRecipes}',
                color: const Color(0xFF74C69D),
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'Total Cooks',
                value: '${progress.totalDishesCooked}',
                color: const Color(0xFFFFB703),
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'Stars',
                value: '${progress.bestStars.values.fold<int>(0, (a, b) => a + b)}',
                color: const Color(0xFFFF6B6B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              '\u{1F373}', // 🍳
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Kitchen is Empty!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF264653),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start cooking to fill your kitchen\nwith delicious dishes!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF264653).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dish grid
// ---------------------------------------------------------------------------

class _DishGrid extends StatelessWidget {
  const _DishGrid({required this.progress});

  final CookingProgress progress;

  @override
  Widget build(BuildContext context) {
    final recipeIds = progress.completedRecipes.toList(growable: false);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: recipeIds.length,
      itemBuilder: (context, index) {
        final recipeId = recipeIds[index];
        final recipe = findV2Recipe(recipeId);
        final stars = progress.starsFor(recipeId);

        return _DishCard(
          recipeId: recipeId,
          recipe: recipe,
          stars: stars,
        );
      },
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.recipeId,
    required this.recipe,
    required this.stars,
  });

  final String recipeId;
  final V2Recipe? recipe;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final emoji = recipe?.emoji ?? '\u{1F372}'; // 🍲 fallback
    final name = recipe?.name ?? recipeId;
    final countryId = recipe?.countryId ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD166),
          width: 2,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Dish image
          if (recipe?.dishImagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                recipe!.dishImagePath!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            )
          else
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
          const SizedBox(height: 8),
          // Dish name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF264653),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Country flag
          if (countryId.isNotEmpty)
            Text(
              _flagFor(countryId),
              style: const TextStyle(fontSize: 16),
            ),
          const SizedBox(height: 6),
          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Icon(
                  i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: i < stars
                      ? const Color(0xFFFFB703)
                      : const Color(0xFFE0E0E0),
                  size: 22,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  static String _flagFor(String countryId) {
    return switch (countryId.trim().toLowerCase()) {
      'ghana' => '\u{1F1EC}\u{1F1ED}', // 🇬🇭
      'nigeria' => '\u{1F1F3}\u{1F1EC}', // 🇳🇬
      'uk' || 'united_kingdom' => '\u{1F1EC}\u{1F1E7}', // 🇬🇧
      'usa' || 'united_states' => '\u{1F1FA}\u{1F1F8}', // 🇺🇸
      _ => '\u{1F30D}', // 🌍
    };
  }
}
