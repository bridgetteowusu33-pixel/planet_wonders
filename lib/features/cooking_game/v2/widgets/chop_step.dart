import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/cooking_audio_service.dart';
import '../models/v2_recipe.dart';
import '../models/v2_recipe_step.dart';
import 'ingredient_image.dart';
import 'prop_image.dart';

class ChopStep extends StatefulWidget {
  const ChopStep({
    super.key,
    required this.step,
    required this.progress,
    required this.interactionCount,
    required this.onTap,
    this.countryId = 'ghana',
    this.ingredients = const <V2Ingredient>[],
  });

  final V2RecipeStep step;
  final double progress;
  final int interactionCount;
  final VoidCallback onTap;
  final String countryId;
  final List<V2Ingredient> ingredients;

  @override
  State<ChopStep> createState() => _ChopStepState();
}

class _ChopStepState extends State<ChopStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _knife;
  bool _chopping = false;

  @override
  void initState() {
    super.initState();
    _knife = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _knife.dispose();
    super.dispose();
  }

  void _onChop() {
    if (_chopping) return;
    _chopping = true;
    HapticFeedback.mediumImpact();
    CookingAudioService.instance.playSfx('chop', widget.countryId);
    _knife.forward().then((_) {
      _knife.reverse().then((_) {
        _chopping = false;
      });
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final required = widget.step.targetCount;
    final done = widget.interactionCount;

    // Resolve full V2Ingredient objects for the chop step.
    final chopIngredients = <V2Ingredient>[];
    for (final id in widget.step.ingredientIds) {
      for (final ing in widget.ingredients) {
        if (ing.id == id) {
          chopIngredients.add(ing);
          break;
        }
      }
    }

    return Semantics(
      button: true,
      label: 'Cutting board. Tap to chop. $done of $required chops done',
      child: GestureDetector(
        onTap: _onChop,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Cutting board with ingredients + knife
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 380,
                  height: 260,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      // Board
                      Positioned.fill(
                        child: Image.asset(
                          'assets/cooking/v2/${widget.countryId}/props/cutting_board.webp',
                          fit: BoxFit.fill,
                          errorBuilder: (_, _, _) => Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: <Color>[
                                  Color(0xFFD4A373),
                                  Color(0xFFC8956E),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      // Ingredients on the left side of the board
                      Positioned(
                        left: 12,
                        top: 12,
                        bottom: 12,
                        right: 100, // leave space for knife on right
                        child: _ChopItems(
                          done: done,
                          total: required,
                          ingredients: chopIngredients,
                        ),
                      ),
                      // Knife on the right
                      Positioned(
                        right: -10,
                        top: -10,
                        child: AnimatedBuilder(
                          animation: _knife,
                          builder: (context, child) {
                            final angle = -0.3 + _knife.value * 0.6;
                            return Transform.rotate(
                              angle: angle,
                              alignment: Alignment.bottomLeft,
                              child: child,
                            );
                          },
                          child: PropImage(
                            countryId: widget.countryId,
                            propName: 'knife',
                            fallbackEmoji: '\u{1F52A}',
                            size: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Counter
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: const Color(0xFFFFD166), width: 2),
              ),
              child: Text(
                '$done / $required chops',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D3142),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: widget.progress.clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF8C42),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap to chop!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF264653).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChopItems extends StatelessWidget {
  const _ChopItems({
    required this.done,
    required this.total,
    required this.ingredients,
  });

  final int done;
  final int total;
  final List<V2Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.center,
      children: List<Widget>.generate(total, (i) {
        final isChopped = i < done;
        final ingredient = ingredients.isNotEmpty
            ? ingredients[i % ingredients.length]
            : null;

        return AnimatedScale(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          scale: isChopped ? 0.6 : 1.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isChopped ? 0.35 : 1.0,
            child: ingredient != null
                ? IngredientImage(
                    ingredient: ingredient,
                    size: isChopped ? 48 : 64,
                  )
                : Text(
                    '\u{1F96C}',
                    style: TextStyle(fontSize: isChopped ? 36 : 50),
                  ),
          ),
        );
      }),
    );
  }
}
