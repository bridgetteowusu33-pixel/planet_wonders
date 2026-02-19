import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/pw_theme.dart';
import '../../domain/recipe.dart';
import '../../engine/recipe_engine.dart';
import '../widgets/scene_background.dart';

/// Scene for hold-based steps (hold lid to cook).
///
/// Features a pot lid that the player holds down. Steam rises
/// while holding, and 3 progress dots fill sequentially.
/// The background warms as progress increases.
class HoldScene extends StatefulWidget {
  const HoldScene({
    super.key,
    required this.step,
    required this.progress,
    required this.interactionCount,
    required this.onProgressDelta,
  });

  final RecipeStoryStep step;
  final double progress;
  final int interactionCount;
  final ValueChanged<double> onProgressDelta;

  @override
  State<HoldScene> createState() => _HoldSceneState();
}

class _HoldSceneState extends State<HoldScene>
    with SingleTickerProviderStateMixin {
  static const int _holdTickMs = 50;

  Timer? _holdTimer;
  bool _holding = false;
  late final AnimationController _steamAnim;

  @override
  void initState() {
    super.initState();
    _steamAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant HoldScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.actionKey != widget.step.actionKey) {
      _stopHolding();
    }
  }

  @override
  void dispose() {
    _stopHolding();
    _steamAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = const RecipeEngine().sceneColorsForAction(widget.step.action);
    final isDone = widget.progress >= 1;
    final dotsFilled = (widget.progress * 3).floor().clamp(0, 3);

    return SceneBackground(
      sceneColors: colors,
      child: GestureDetector(
        onTapDown: (_) => _startHolding(),
        onTapUp: (_) => _stopHolding(),
        onTapCancel: _stopHolding,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 200,
              height: 220,
              decoration: BoxDecoration(
                color: _holding
                    ? Colors.white.withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _holding
                      ? Color(colors.accent)
                      : Color(colors.accent).withValues(alpha: 0.3),
                  width: _holding ? 4 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(colors.accent)
                        .withValues(alpha: _holding ? 0.25 : 0.1),
                    blurRadius: _holding ? 20 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Steam animation
                  if (_holding)
                    AnimatedBuilder(
                      animation: _steamAnim,
                      builder: (context, child) {
                        final opacity = 0.3 + _steamAnim.value * 0.6;
                        final rise = _steamAnim.value * 12;
                        return Transform.translate(
                          offset: Offset(0, -rise),
                          child: Opacity(
                            opacity: opacity,
                            child: child,
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('\u{2668}\u{FE0F}',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(width: 6),
                          Text('\u{2668}\u{FE0F}',
                              style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Text('\u{2668}\u{FE0F}',
                              style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  if (!_holding) const SizedBox(height: 28),
                  // Lid emoji
                  AnimatedScale(
                    scale: _holding ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isDone ? '\u{2728}' : '\u{1FA98}', // ✨ : 🪘
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Label
                  Text(
                    isDone
                        ? 'Cooked!'
                        : _holding
                            ? 'Cooking...'
                            : 'Hold to Cook',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDone
                          ? PWColors.mint
                          : PWColors.navy.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final filled = i < dotsFilled;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: filled ? 18 : 14,
                        height: filled ? 18 : 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled
                              ? Color(colors.accent)
                              : Colors.white,
                          border: Border.all(
                            color: Color(colors.accent).withValues(
                                alpha: filled ? 1 : 0.3),
                            width: 2,
                          ),
                          boxShadow: filled
                              ? [
                                  BoxShadow(
                                    color: Color(colors.accent)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startHolding() {
    if (_holdTimer != null) return;
    setState(() => _holding = true);

    final holdDurationMs = widget.step.safeHoldDurationMs;
    final tickDelta = (_holdTickMs / holdDurationMs).clamp(0.01, 0.2);

    _holdTimer = Timer.periodic(const Duration(milliseconds: _holdTickMs), (_) {
      widget.onProgressDelta(tickDelta);
    });
  }

  void _stopHolding() {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (_holding) {
      setState(() => _holding = false);
    }
  }
}
