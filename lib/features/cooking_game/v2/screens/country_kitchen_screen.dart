import 'package:flutter/material.dart';

import '../../../cooking/ui/painters/ghana_kitchen_painter.dart';
import '../../../cooking/ui/painters/nigeria_kitchen_painter.dart';
import '../../../cooking/ui/painters/usa_kitchen_painter.dart';
import '../../uk/british_kitchen_painter.dart';
import '../data/v2_recipe_registry.dart';
import '../models/v2_recipe.dart';
import '../../cooking_entry.dart';

class CountryKitchenScreen extends StatelessWidget {
  const CountryKitchenScreen({
    super.key,
    required this.countryId,
  });

  final String countryId;

  @override
  Widget build(BuildContext context) {
    final recipes = v2RecipesForCountry(countryId);
    final characterName = _characterFor(countryId);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF8EDBFF),
              Color(0xFFBDEBFF),
              Color(0xFFE6F9FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Kitchen background
            Positioned.fill(
              child: IgnorePointer(
                child: _kitchenBackgroundFor(countryId),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 12),
                    // Header
                    _KitchenHeader(
                      characterName: characterName,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 16),
                    // Recipe grid
                    Expanded(
                      child: recipes.isEmpty
                          ? const Center(
                              child: Text(
                                'Recipes coming soon!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF355070),
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.only(bottom: 20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: recipes.length,
                              itemBuilder: (context, index) {
                                return _RecipeCard(
                                  recipe: recipes[index],
                                  onTap: () {
                                    openCookingGameV2(
                                      context,
                                      recipeId: recipes[index].id,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _characterFor(String countryId) {
    return switch (countryId.trim().toLowerCase()) {
      'ghana' => 'Afia',
      'nigeria' => 'Adetutu',
      'uk' || 'united_kingdom' => 'Heze & Aza',
      'usa' || 'united_states' => 'Ava',
      _ => 'Chef',
    };
  }

  static Widget _kitchenBackgroundFor(String countryId) {
    final id = countryId.trim().toLowerCase();
    return Image.asset(
      'assets/cooking/v2/$id/kitchen_bg.webp',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => CustomPaint(
        painter: switch (id) {
          'ghana' => const GhanaKitchenPainter(),
          'nigeria' => const NigeriaKitchenPainter(),
          'usa' || 'united_states' => const UsaKitchenPainter(),
          'uk' || 'united_kingdom' => const BritishKitchenPainter(),
          _ => const GhanaKitchenPainter(),
        },
      ),
    );
  }
}

class _KitchenHeader extends StatelessWidget {
  const _KitchenHeader({
    required this.characterName,
    required this.onBack,
  });

  final String characterName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFD166), Color(0xFFFFB86B)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$characterName\u{2019}s Kitchen',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Text(
            '\u{1F468}\u{200D}\u{1F373}', // 👨‍🍳
            style: TextStyle(fontSize: 28),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onTap,
  });

  final V2Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (diffLabel, diffColor) = switch (recipe.difficulty) {
      V2Difficulty.easy => ('Easy', const Color(0xFF74C69D)),
      V2Difficulty.medium => ('Medium', const Color(0xFFFFB703)),
      V2Difficulty.hard => ('Hard', const Color(0xFFFF6B6B)),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFFFFBE6), Color(0xFFFFF3C4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (recipe.dishImagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  recipe.dishImagePath!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Text(
                    recipe.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              )
            else
              Text(
                recipe.emoji,
                style: const TextStyle(fontSize: 48),
              ),
            const SizedBox(height: 8),
            Text(
              recipe.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1D3557),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: diffColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                diffLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: diffColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${recipe.steps.length} steps',
              style: TextStyle(
                fontSize: 12,
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
