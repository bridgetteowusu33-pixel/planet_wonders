import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/pw_theme.dart';
import '../../domain/recipe.dart';
import '../../engine/recipe_engine.dart';
import '../widgets/scene_background.dart';

class DragScene extends StatefulWidget {
  const DragScene({
    super.key,
    required this.step,
    required this.progress,
    required this.interactionCount,
    required this.onDragAccepted,
  });

  final RecipeStoryStep step;
  final double progress;
  final int interactionCount;
  final VoidCallback onDragAccepted;

  @override
  State<DragScene> createState() => _DragSceneState();
}

class _DragSceneState extends State<DragScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleAnim;
  bool _dragging = false;
  int _dropFxTick = 0;

  @override
  void initState() {
    super.initState();
    _idleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sourceEmoji = switch (widget.step.actionKey) {
      'drag_oil_to_pot' => '🫙',
      'drag_tomato_mix' => '🍅',
      'drag_rice_to_pot' => '🍚',
      _ => '🥣',
    };

    final sourceLabel = switch (widget.step.actionKey) {
      'drag_oil_to_pot' => 'Oil',
      'drag_tomato_mix' => 'Tomato',
      'drag_rice_to_pot' => 'Rice',
      _ => 'Ingredient',
    };

    final colors = const RecipeEngine().sceneColorsForAction(
      widget.step.action,
    );

    return SceneBackground(
      sceneColors: colors,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Drag into the pot! ✨',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _idleAnim,
                      builder: (context, child) {
                        final bob = _dragging
                            ? 0.0
                            : math.sin(_idleAnim.value * math.pi) * 5;
                        return Transform.translate(
                          offset: Offset(0, bob),
                          child: child,
                        );
                      },
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 120),
                        scale: _dragging ? 1.08 : 1,
                        child: Draggable<String>(
                          data: widget.step.actionKey,
                          onDragStarted: () => setState(() => _dragging = true),
                          onDragEnd: (_) => setState(() => _dragging = false),
                          feedback: _IngredientChip(
                            emoji: sourceEmoji,
                            label: sourceLabel,
                            opacity: 0.95,
                            glowing: true,
                          ),
                          childWhenDragging: _IngredientChip(
                            emoji: sourceEmoji,
                            label: sourceLabel,
                            opacity: 0.22,
                          ),
                          child: _IngredientChip(
                            emoji: sourceEmoji,
                            label: sourceLabel,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _idleAnim,
                  builder: (context, child) {
                    final slide = _idleAnim.value * 8;
                    return Transform.translate(
                      offset: Offset(slide, 0),
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.double_arrow_rounded,
                    color: Color(colors.accent).withValues(alpha: 0.45),
                    size: 30,
                  ),
                ),
                Expanded(
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (details) =>
                        details.data == widget.step.actionKey,
                    onAcceptWithDetails: (details) {
                      setState(() => _dropFxTick += 1);
                      widget.onDragAccepted();
                    },
                    builder: (context, candidateData, rejectedData) {
                      final hovering = candidateData.isNotEmpty;
                      return TweenAnimationBuilder<double>(
                        key: ValueKey<int>(_dropFxTick),
                        tween: Tween<double>(begin: 1.12, end: 1),
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 136,
                              height: 136,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hovering
                                    ? PWColors.mint.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.92),
                                border: Border.all(
                                  color: hovering
                                      ? PWColors.mint
                                      : Color(colors.accent),
                                  width: hovering ? 4 : 3,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color:
                                        (hovering
                                                ? PWColors.mint
                                                : PWColors.navy)
                                            .withValues(
                                              alpha: hovering ? 0.34 : 0.12,
                                            ),
                                    blurRadius: hovering ? 20 : 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    hovering ? '🍲' : '🍳',
                                    style: TextStyle(
                                      fontSize: hovering ? 44 : 38,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hovering ? 'Drop!' : 'Pot',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: hovering
                                          ? PWColors.mint
                                          : PWColors.navy.withValues(
                                              alpha: 0.6,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_dropFxTick > 0)
                              IgnorePointer(
                                child: TweenAnimationBuilder<double>(
                                  key: ValueKey<int>(_dropFxTick * 13),
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 360),
                                  builder: (context, t, _) {
                                    if (t <= 0.02) {
                                      return const SizedBox.shrink();
                                    }
                                    return Opacity(
                                      opacity: (1 - t).clamp(0, 1),
                                      child: const Text(
                                        '✨',
                                        style: TextStyle(fontSize: 54),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({
    required this.emoji,
    required this.label,
    this.opacity = 1,
    this.glowing = false,
  });

  final String emoji;
  final String label;
  final double opacity;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 118,
        height: 118,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: glowing
                ? PWColors.coral
                : PWColors.coral.withValues(alpha: 0.45),
            width: glowing ? 3 : 2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: (glowing ? PWColors.coral : PWColors.navy).withValues(
                alpha: glowing ? 0.3 : 0.1,
              ),
              blurRadius: glowing ? 16 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
