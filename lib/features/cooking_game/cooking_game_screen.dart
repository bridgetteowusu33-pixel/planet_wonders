// COOKING_ENTRYPOINT: lib/app.dart  class PlanetWondersApp (GoRoute '/cooking' -> CookingGameScreen)
// COOKING_ENTRYPOINT: lib/features/cooking_game/cooking_game_screen.dart  class CookingGameScreen

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../achievements/providers/achievement_provider.dart';
import '../learning_report/models/learning_stats.dart';
import '../learning_report/providers/learning_stats_provider.dart';
import '../stickers/providers/sticker_provider.dart';
import '../cooking/data/ghana_recipes.dart';
import '../cooking/data/uk_recipes.dart' as uk_premium;
import '../cooking/models/badge.dart';
import '../cooking/models/ingredient.dart' as upgraded;
import '../cooking/models/recipe.dart' as upgraded;
import '../cooking/ui/cooking_screen.dart';
import '../../shared/widgets/recipe_detail_sheet.dart';
import 'models/recipe.dart';

class CookingGameScreen extends ConsumerWidget {
  const CookingGameScreen({
    super.key,
    required this.recipe,
    this.entrySource = 'games',
    this.entryCountryId,
  });

  final Recipe recipe;
  final String entrySource;
  final String? entryCountryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumRecipe = _mapRecipe(recipe);

    final recipeDetail = RecipeDetailData(
      title: recipe.name,
      emoji: recipe.emoji,
      ingredients: recipe.ingredients
          .map((i) => (name: i.name, emoji: i.emoji))
          .toList(growable: false),
      steps: recipe.steps
          .map((s) => s.instruction)
          .toList(growable: false),
    );

    return CookingScreen(
      recipe: premiumRecipe,
      recipeDetail: recipeDetail,
      onExit: () => Navigator.of(context).maybePop(),
      onCompleted: (completedRecipe, score) async {
        final countryId =
            (entryCountryId != null && entryCountryId!.trim().isNotEmpty)
            ? entryCountryId!.trim()
            : recipe.countryId;

        await ref
            .read(achievementProvider.notifier)
            .markCookingRecipeCompleted(
              countryId: countryId,
              recipeId: recipe.id,
            );

        ref.read(learningStatsProvider.notifier).logActivity(
          ActivityLogEntry(
            id: '${DateTime.now().millisecondsSinceEpoch}',
            type: ActivityType.cooking,
            label: 'Cooked ${recipe.name}',
            countryId: countryId,
            timestamp: DateTime.now(),
            emoji: '\u{1F373}',
          ),
        );
        ref.read(stickerProvider.notifier).checkAndAward(
              conditionType: 'cooking_completed',
              countryId: countryId,
            );

        if (!context.mounted) return;
        final perfectChef = score.perfectChef;
        final stars = score.stars;
        final message = perfectChef
            ? 'Perfect Chef! ${completedRecipe.name} mastered with $stars stars!'
            : '${completedRecipe.name} complete! You earned $stars stars!';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }

  upgraded.Recipe _mapRecipe(Recipe value) {
    if (value.id == ghanaJollofRecipe.id) {
      return ghanaJollofRecipe;
    }

    final ukMatch = uk_premium.findPremiumUkRecipe(value.id);
    if (ukMatch != null) return ukMatch;

    final mappedIngredients = value.ingredients
        .map(
          (ingredient) => upgraded.Ingredient(
            id: ingredient.id,
            name: ingredient.name,
            assetPath: 'assets/cooking/ingredients/${ingredient.id}.png',
            country: _countryLabel(value.countryId),
            isSpice:
                ingredient.name.toLowerCase().contains('spice') ||
                ingredient.name.toLowerCase().contains('pepper'),
          ),
        )
        .toList(growable: false);

    final factList = value.funFacts.isEmpty
        ? <upgraded.CookingFact>[
            upgraded.CookingFact(
              text:
                  '${value.name} is a favorite for families to cook together.',
              country: _countryLabel(value.countryId),
            ),
          ]
        : value.funFacts
              .map(
                (fact) => upgraded.CookingFact(
                  text: fact,
                  country: _countryLabel(value.countryId),
                ),
              )
              .toList(growable: false);

    final spiceCount = mappedIngredients.any((i) => i.isSpice) ? 2 : 0;

    return upgraded.Recipe(
      id: value.id,
      name: value.name,
      country: _countryLabel(value.countryId),
      potAsset: 'assets/cooking/pots/classic_pot.png',
      chefAsset: 'assets/cooking/chefs/chef_ava.png',
      ingredients: mappedIngredients,
      facts: factList,
      badge: CookingBadge(
        id: '${value.countryId}_chef',
        title: '${_countryLabel(value.countryId)} Kitchen Star',
        country: _countryLabel(value.countryId),
        iconAsset: 'assets/cooking/effects/badge_${value.countryId}_chef.png',
      ),
      requiredStirTurns: math.max(4, mappedIngredients.length + 1),
      requiredSpiceShakes: spiceCount,
      requiredServeScoops: math.max(3, mappedIngredients.length - 1),
    );
  }

  String _countryLabel(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) return 'Country';
    return normalized
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
