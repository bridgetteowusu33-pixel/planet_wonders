import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/v2_recipe.dart';
import '../utils/v2_asset_preloader.dart';
import '../widgets/chef_avatar.dart';
import '../widgets/ingredient_image.dart';

class RecipeIntroScreen extends StatefulWidget {
  const RecipeIntroScreen({
    super.key,
    required this.recipe,
    required this.onStart,
  });

  final V2Recipe recipe;
  final VoidCallback onStart;

  @override
  State<RecipeIntroScreen> createState() => _RecipeIntroScreenState();
}

class _RecipeIntroScreenState extends State<RecipeIntroScreen> {
  @override
  void initState() {
    super.initState();
    // Precache illustrated assets during intro to avoid pop-in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        V2AssetPreloader.preload(context, widget.recipe);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: <Widget>[
            const Spacer(flex: 2),
            // Dish image — big reveal
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, t, child) {
                return Transform.scale(scale: t, child: child);
              },
              child: recipe.dishImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        recipe.dishImagePath!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          recipe.emoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    )
                  : Text(
                      recipe.emoji,
                      style: const TextStyle(fontSize: 80),
                    ),
            ),
            const SizedBox(height: 16),
            // Recipe name
            Text(
              recipe.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 4),
            // Difficulty badge
            _DifficultyBadge(difficulty: recipe.difficulty),
            const SizedBox(height: 20),
            // Character greeting with chef avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ChefAvatar(
                  countryId: recipe.countryId,
                  size: 48,
                  mood: ChefAvatarMood.excited,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFD166),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${recipe.characterName} says: Let\u{2019}s cook ${recipe.name}!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF264653),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Fun fact tip
            if (recipe.funFacts.isNotEmpty)
              _FunFactCard(facts: recipe.funFacts),
            const SizedBox(height: 16),
            // Ingredients list
            _IngredientPreview(ingredients: recipe.ingredients),
            const SizedBox(height: 8),
            // Step count
            Text(
              '${recipe.steps.length} steps',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF264653).withValues(alpha: 0.6),
              ),
            ),
            const Spacer(flex: 3),
            // Start button
            GestureDetector(
              onTap: widget.onStart,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF6BCB77), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x3374C69D),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Let\u{2019}s Cook!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final V2Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (difficulty) {
      V2Difficulty.easy => ('Easy', const Color(0xFF74C69D)),
      V2Difficulty.medium => ('Medium', const Color(0xFFFFB703)),
      V2Difficulty.hard => ('Hard', const Color(0xFFFF6B6B)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _FunFactCard extends StatelessWidget {
  const _FunFactCard({required this.facts});

  final List<String> facts;

  @override
  Widget build(BuildContext context) {
    final fact = facts[math.Random().nextInt(facts.length)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD166).withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '\u{1F4A1}', // 💡
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Did You Know?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE68A00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fact,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF355070),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientPreview extends StatelessWidget {
  const _IngredientPreview({required this.ingredients});

  final List<V2Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: ingredients.map((ingredient) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IngredientImage(ingredient: ingredient, size: 24),
              const SizedBox(width: 4),
              Text(
                ingredient.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}
