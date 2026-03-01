import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../achievements/providers/achievement_provider.dart';
import '../../../stickers/providers/sticker_provider.dart';
import '../../../cooking/ui/painters/ghana_kitchen_painter.dart';
import '../../../cooking/ui/painters/nigeria_kitchen_painter.dart';
import '../../../cooking/ui/painters/usa_kitchen_painter.dart';
import '../../../learning_report/models/learning_stats.dart';
import '../../../learning_report/providers/learning_stats_provider.dart';
import '../../uk/british_kitchen_painter.dart';
import '../models/v2_recipe.dart';
import '../providers/cooking_progress_provider.dart';
import '../providers/v2_cooking_controller.dart';
import '../providers/v2_cooking_state.dart';
import 'dish_reveal_screen.dart';
import 'recipe_intro_screen.dart';
import 'step_player_screen.dart';

class V2CookingShell extends ConsumerWidget {
  const V2CookingShell({
    super.key,
    required this.recipe,
  });

  final V2Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(v2CookingControllerProvider);
    final controller = ref.read(v2CookingControllerProvider.notifier);

    // Save progress + log to learning report when entering dish reveal phase.
    ref.listen(v2CookingControllerProvider, (prev, next) {
      if (prev?.phase != V2Phase.dishReveal &&
          next.phase == V2Phase.dishReveal) {
        ref.read(cookingProgressProvider.notifier).recordCompletion(
              recipeId: recipe.id,
              stars: next.stars,
            );
        // Normalize V2 recipe ID (strip _v2 suffix) so V1 and V2
        // completions of the same dish share one achievement key.
        final achievementRecipeId = recipe.id.endsWith('_v2')
            ? recipe.id.substring(0, recipe.id.length - 3)
            : recipe.id;
        ref.read(achievementProvider.notifier).markCookingRecipeCompleted(
              countryId: recipe.countryId,
              recipeId: achievementRecipeId,
            );
        ref.read(learningStatsProvider.notifier).logActivity(
              ActivityLogEntry(
                id: '${DateTime.now().millisecondsSinceEpoch}',
                type: ActivityType.cooking,
                label: 'Cooked ${recipe.name}',
                countryId: recipe.countryId,
                timestamp: DateTime.now(),
                emoji: '\u{1F373}', // 🍳
              ),
            );
        ref.read(stickerProvider.notifier).checkAndAward(
              conditionType: 'cooking_completed',
              countryId: recipe.countryId,
            );
      }
    });

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
            // Country kitchen background
            Positioned.fill(
              child: IgnorePointer(
                child: _kitchenBackground(recipe.countryId),
              ),
            ),
            // Phase-based content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _buildPhase(context, state, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase(
    BuildContext context,
    V2CookingState state,
    V2CookingController controller,
  ) {
    return switch (state.phase) {
      V2Phase.intro => RecipeIntroScreen(
          key: const ValueKey<V2Phase>(V2Phase.intro),
          recipe: recipe,
          onStart: () => controller.startRecipe(recipe),
        ),
      V2Phase.playing => StepPlayerScreen(
          key: const ValueKey<V2Phase>(V2Phase.playing),
          recipe: recipe,
          state: state,
          onAddIngredient: (id) => controller.addIngredient(recipe, id),
          onTapAction: () => controller.completeTapAction(recipe),
          onProgressDelta: (delta) =>
              controller.addProgress(recipe, delta: delta),
          onMistake: () => controller.registerMistake(recipe),
          onExit: () => Navigator.of(context).maybePop(),
        ),
      V2Phase.dishReveal || V2Phase.complete => DishRevealScreen(
          key: const ValueKey<V2Phase>(V2Phase.dishReveal),
          recipe: recipe,
          state: state,
          onCookAgain: () {
            controller.restart();
            controller.startRecipe(recipe);
          },
          onMyKitchen: () => context.push('/my-kitchen'),
          onExit: () => Navigator.of(context).maybePop(),
        ),
    };
  }

  /// Try the illustrated kitchen PNG first; fall back to CustomPainter.
  static Widget _kitchenBackground(String countryId) {
    final id = countryId.trim().toLowerCase();
    return Image.asset(
      'assets/cooking/v2/$id/kitchen_bg.webp',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => CustomPaint(
        painter: _fallbackPainter(id),
      ),
    );
  }

  static CustomPainter _fallbackPainter(String id) {
    return switch (id) {
      'ghana' => const GhanaKitchenPainter(),
      'nigeria' => const NigeriaKitchenPainter(),
      'usa' || 'united_states' => const UsaKitchenPainter(),
      'uk' || 'united_kingdom' => const BritishKitchenPainter(),
      _ => const _FallbackKitchenPainter(),
    };
  }
}

/// Minimal fallback kitchen painter for unknown countries.
class _FallbackKitchenPainter extends CustomPainter {
  const _FallbackKitchenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Simple warm gradient wall.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );

    // Wooden counter.
    final counterTop = size.height * 0.72;
    canvas.drawRect(
      Rect.fromLTWH(0, counterTop, size.width, size.height - counterTop),
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0xFFE8C89C), Color(0xFFD4A870)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromLTWH(0, counterTop, size.width, size.height - counterTop),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _FallbackKitchenPainter oldDelegate) => false;
}
