import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/motion/motion_settings_provider.dart';
import '../../engine/recipe_engine.dart';

/// Animated scene background that changes color based on the
/// current cooking action type.
///
/// Uses a gradient with floating particle dots to create a
/// warm, lively atmosphere without requiring image assets.
/// The particles are purely decorative and lightweight.
class SceneBackground extends StatefulWidget {
  const SceneBackground({super.key, required this.sceneColors, this.child});

  final SceneColors sceneColors;
  final Widget? child;

  @override
  State<SceneBackground> createState() => _SceneBackgroundState();
}

class _SceneBackgroundState extends State<SceneBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _particleController;
  bool _reduceMotion = false;
  bool _motionResolved = false;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_motionResolved) {
      _motionResolved = true;
      _reduceMotion = MotionUtil.isReducedFromContext(context);
      if (!_reduceMotion) _particleController.repeat();
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: _reduceMotion
            ? const Duration(milliseconds: 120)
            : const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(widget.sceneColors.primary),
              Color(widget.sceneColors.secondary),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Floating particles for ambience (skip when reduced)
              if (!_reduceMotion)
                ...List.generate(
                  6,
                  (i) => _FloatingParticle(
                    controller: _particleController,
                    index: i,
                    accentColor: Color(widget.sceneColors.accent),
                  ),
                ),
              if (widget.child != null) widget.child!,
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingParticle extends StatelessWidget {
  const _FloatingParticle({
    required this.controller,
    required this.index,
    required this.accentColor,
  });

  final AnimationController controller;
  final int index;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    const sceneWidth = 320.0;
    final xFraction = (index * 0.17 + 0.08) % 1.0;
    final yOffset = index * 0.14 + 0.1;
    final size = 6.0 + (index % 3) * 3.0;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + index * 0.16) % 1.0;
        final y = yOffset + math.sin(t * math.pi * 2) * 0.06;
        final opacity = 0.15 + math.sin(t * math.pi) * 0.15;

        return Positioned(
          left: xFraction * sceneWidth,
          top: y * 200,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }
}
