import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/pw_theme.dart';
import '../../domain/recipe.dart';
import '../../engine/recipe_engine.dart';
import '../widgets/scene_background.dart';

class TapScene extends StatefulWidget {
  const TapScene({
    super.key,
    required this.step,
    required this.progress,
    required this.interactionCount,
    required this.onTap,
  });

  final RecipeStoryStep step;
  final double progress;
  final int interactionCount;
  final VoidCallback onTap;

  @override
  State<TapScene> createState() => _TapSceneState();
}

class _TapSceneState extends State<TapScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleAnim;
  bool _tapPulse = false;

  @override
  void initState() {
    super.initState();
    _idleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = const RecipeEngine().sceneColorsForAction(
      widget.step.action,
    );
    final isDone = widget.progress >= 1;
    final required = widget.step.safeRequiredCount;
    final remaining = (required - widget.interactionCount).clamp(0, required);

    final sceneTitle = switch (widget.step.actionKey) {
      'tap_bowl' => 'Rain Time! 🌧️',
      'tap_chop' => 'Chop Party! 🔪',
      'tap_spice_shaker' => 'Spice Dance! 🧂',
      _ => 'Tap Time! 👆',
    };

    final emoji = switch (widget.step.actionKey) {
      'tap_bowl' => '🥣',
      'tap_chop' => '🔪',
      'tap_spice_shaker' => '🧂',
      _ => '👆',
    };

    return SceneBackground(
      sceneColors: colors,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 210,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        sceneTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1D3557),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          _runTapPulse();
                          widget.onTap();
                        },
                        child: AnimatedScale(
                          scale: _tapPulse ? 0.9 : 1,
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.easeOutBack,
                          child: AnimatedBuilder(
                            animation: _idleAnim,
                            builder: (context, child) {
                              if (_tapPulse) return child!;
                              final bob =
                                  math.sin(_idleAnim.value * math.pi) * 4;
                              return Transform.translate(
                                offset: Offset(0, bob),
                                child: child,
                              );
                            },
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: isDone
                                      ? PWColors.mint
                                      : Color(colors.accent),
                                  width: 4,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Color(
                                      colors.accent,
                                    ).withValues(alpha: 0.24),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  if (widget.step.actionKey == 'tap_bowl')
                                    _RainOverlay(active: _tapPulse),
                                  Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 72),
                                  ),
                                  if (_tapPulse)
                                    ...List.generate(8, (i) {
                                      final angle = i * math.pi / 4;
                                      return Positioned(
                                        left: 95 + math.cos(angle) * 72,
                                        top: 95 + math.sin(angle) * 72,
                                        child: const Text(
                                          '✨',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }),
                                  if (isDone)
                                    const Positioned(
                                      bottom: 10,
                                      child: Text(
                                        '👏',
                                        style: TextStyle(fontSize: 28),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isDone
                            ? 'Amazing! Scene complete!'
                            : '$remaining taps left',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDone
                              ? PWColors.mint
                              : PWColors.navy.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _runTapPulse() {
    setState(() => _tapPulse = true);
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _tapPulse = false);
    });
  }
}

class _RainOverlay extends StatelessWidget {
  const _RainOverlay({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.expand();

    return IgnorePointer(
      child: Stack(
        children: List.generate(10, (index) {
          final left = 24.0 + (index % 5) * 30;
          final top = 18.0 + (index ~/ 5) * 24;
          return Positioned(
            left: left,
            top: top,
            child: const Text('💧', style: TextStyle(fontSize: 18)),
          );
        }),
      ),
    );
  }
}
