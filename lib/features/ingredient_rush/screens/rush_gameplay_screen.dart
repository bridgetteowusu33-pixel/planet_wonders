import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ingredient_rush_state.dart';
import '../providers/ingredient_rush_controller.dart';
import '../widgets/floating_ingredient.dart';
import '../widgets/rush_chef_bubble.dart';
import '../widgets/rush_objective_panel.dart';
import '../widgets/rush_pot_widget.dart';
import '../widgets/rush_timer_bar.dart';

/// Core gameplay screen with 60fps Ticker-driven ingredient movement.
class RushGameplayScreen extends ConsumerStatefulWidget {
  const RushGameplayScreen({super.key, required this.countryId});

  final String countryId;

  @override
  ConsumerState<RushGameplayScreen> createState() =>
      _RushGameplayScreenState();
}

class _RushGameplayScreenState extends ConsumerState<RushGameplayScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    ref.read(ingredientRushProvider.notifier).tick(delta);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ingredientRushProvider);
    final controller = ref.read(ingredientRushProvider.notifier);

    if (state.phase != RushPhase.playing) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.sizeOf(context);
    final laneHeight = (screenSize.height - 240) / 5; // 5 lanes
    const topOffset = 100.0;

    return Stack(
      children: [
        // ── Floating ingredients ──
        for (final ing in state.activeIngredients)
          Positioned(
            left: ing.x,
            top: topOffset + ing.lane * laneHeight,
            child: FloatingIngredientWidget(
              key: ValueKey<int>(ing.uid),
              ingredient: ing,
              onTap: () => controller.tapIngredient(ing.uid),
            ),
          ),

        // ── Pot (bottom center) ──
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: RushPotWidget(
              countryId: widget.countryId,
              face: state.potFace,
            ),
          ),
        ),

        // ── Top HUD: objective panel ──
        if (state.currentObjective != null)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: RushObjectivePanel(
                objective: state.currentObjective!,
                collected: state.currentCollected,
                countryId: widget.countryId,
              ),
            ),
          ),

        // ── Timer bar ──
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: RushTimerBar(
              fraction: state.timerFraction,
              remainingSec: state.timerRemainingSec,
            ),
          ),
        ),

        // ── Chef bubble (bottom-left) ──
        if (state.characterLine.isNotEmpty)
          Positioned(
            bottom: 160,
            left: 12,
            right: 100,
            child: RushChefBubble(
              countryId: widget.countryId,
              line: state.characterLine,
            ),
          ),
      ],
    );
  }
}
