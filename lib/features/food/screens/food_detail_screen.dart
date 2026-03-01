import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../coloring/data/coloring_data.dart';
import '../../cooking_game/cooking_entry.dart';
import '../../cooking_game/data/recipes_ghana.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/food_data.dart';

/// Food detail page: big image + fun fact + color CTA.
class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({
    super.key,
    required this.countryId,
    required this.dishId,
  });

  final String countryId;
  final String dishId;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countryId = widget.countryId;
    final dishId = widget.dishId;
    final dish = findFoodDish(countryId, dishId);
    final country = findCountryById(countryId);
    final countryName = country?.name ?? countryId;
    final recipeId = _recipeIdForDish(countryId: countryId, dishId: dishId);

    if (dish == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Dish not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '\u{1F374} $countryName Food',
          style: Theme.of(context).textTheme.titleMedium,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: PWColors.navy.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (context, child) {
                        final t = _anim.value;
                        final bob = math.sin(t * math.pi) * 6;
                        final tilt = math.sin(t * math.pi) * 0.02;
                        return Transform.translate(
                          offset: Offset(0, bob),
                          child: Transform.rotate(
                            angle: tilt,
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        dish.previewAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            dish.emoji,
                            style: const TextStyle(fontSize: 140),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9EB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: PWColors.yellow.withValues(alpha: 0.7),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${dish.emoji} ${dish.name}',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dish.funFact,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          _openColoring(context, dish.coloringPageId),
                      icon: const Icon(Icons.brush_rounded),
                      label: const Text('COLOR THIS FOOD'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        backgroundColor: PWColors.coral,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (recipeId != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => openCookingGameV2(
                          context,
                          recipeId: '${recipeId}_v2',
                        ),
                        icon: const Icon(Icons.soup_kitchen_rounded),
                        label: const Text('COOK IT!'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          backgroundColor: PWColors.mint,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: PWColors.blue.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u{1F4A1} Did You Know?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PWColors.blue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...dish.didYouKnow.map(
                      (fact) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '\u2022 $fact',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
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

  void _openColoring(BuildContext context, String coloringPageId) {
    final page = findColoringPage(widget.countryId, coloringPageId);
    if (page == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Color page is not ready yet.')),
      );
      return;
    }
    context.push('/color/${widget.countryId}/$coloringPageId');
  }

  String? _recipeIdForDish({
    required String countryId,
    required String dishId,
  }) {
    final exactId = '${countryId}_$dishId';
    if (findCookingRecipe(exactId) != null) {
      return exactId;
    }
    // Dish IDs that don't match cooking recipe IDs directly.
    final alias = _cookingRecipeAlias(countryId, dishId);
    if (alias != null && findCookingRecipe(alias) != null) {
      return alias;
    }
    return null;
  }

  static String? _cookingRecipeAlias(String countryId, String dishId) {
    if (countryId == 'ghana') {
      return switch (dishId) {
        'jollof' => 'ghana_jollof',
        'banku' => 'ghana_banku',
        'fufu' => 'ghana_fufu',
        'waakye' => 'ghana_waakye',
        'koko' => 'ghana_koko',
        'kelewele' => 'ghana_kelewele',
        'peanut_butter_soup' => 'ghana_peanut_butter_soup',
        'palmnut' => 'ghana_palmnut',
        'fried_rice' => 'ghana_fried_rice',
        _ => null,
      };
    }
    if (countryId == 'nigeria') {
      return switch (dishId) {
        'jollof' => 'nigeria_jollof',
        'suya' => 'nigeria_suya',
        'pounded_yam' => 'nigeria_pounded_yam',
        'egusi' => 'nigeria_egusi',
        'chin_chin' => 'nigeria_chin_chin',
        _ => null,
      };
    }
    if (countryId == 'uk') {
      return switch (dishId) {
        'fishandchips' => 'uk_fish_and_chips',
        'shepherdspie' => 'uk_shepherds_pie',
        'englishbreakfast' => 'uk_full_breakfast',
        'bangersandmash' => 'uk_bangers_and_mash',
        'yorkshirepudding' => 'uk_yorkshire_pudding',
        'cornishpasty' => 'uk_cornish_pasty',
        'stickytoffee' => 'uk_sticky_toffee',
        _ => null,
      };
    }
    if (countryId == 'usa') {
      return switch (dishId) {
        'burger' => 'usa_burger',
        'pizza' => 'usa_pizza',
        'hotdog' => 'usa_hotdog',
        'pancakes' => 'usa_pancakes',
        'donut' => 'usa_donut',
        'icecream' => 'usa_icecream',
        'friedchicken' => 'usa_friedchicken',
        'applepie' => 'usa_applepie',
        'sandwich' => 'usa_sandwich',
        'milkshake' => 'usa_milkshake',
        _ => null,
      };
    }
    return null;
  }
}
