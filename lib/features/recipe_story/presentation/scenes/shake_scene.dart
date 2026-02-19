import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/pw_theme.dart';
import '../../domain/recipe.dart';
import '../../engine/recipe_engine.dart';
import '../widgets/scene_background.dart';

/// Scene for shake-based steps (shake spice shaker).
///
/// Features a shaker emoji that bounces left-and-right with an
/// idle animation. The player shakes horizontally to fill progress.
/// Particles scatter as the player shakes.
class ShakeScene extends StatefulWidget {
  const ShakeScene({
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
  State<ShakeScene> createState() => _ShakeSceneState();
}

class _ShakeSceneState extends State<ShakeScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleAnim;

  @override
  void initState() {
    super.initState();
    _idleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = const RecipeEngine().sceneColorsForAction(widget.step.action);
    final isDone = widget.progress >= 1;

    return SceneBackground(
      sceneColors: colors,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          final delta = math.min(details.delta.dx.abs() / 260, 0.08);
          widget.onProgressDelta(delta);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shaker with bounce animation
                AnimatedBuilder(
                  animation: _idleAnim,
                  builder: (context, child) {
                    final shake =
                        math.sin(_idleAnim.value * math.pi * 2) * 12;
                    final tilt =
                        math.sin(_idleAnim.value * math.pi * 2) * 0.15;
                    return Transform.translate(
                      offset: Offset(shake, 0),
                      child: Transform.rotate(
                        angle: tilt,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.9),
                      border: Border.all(
                        color: isDone
                            ? PWColors.mint
                            : Color(colors.accent).withValues(alpha: 0.5),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Color(colors.accent).withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('\u{1F9C2}',
                          style: TextStyle(fontSize: 56)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Direction arrows + label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 22,
                      color: Color(colors.accent).withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDone ? '\u{2728} Done!' : 'Shake!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDone
                            ? PWColors.mint
                            : PWColors.navy.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 22,
                      color: Color(colors.accent).withValues(alpha: 0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                Container(
                  width: 180,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: isDone
                            ? PWColors.mint
                            : Color(colors.accent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
