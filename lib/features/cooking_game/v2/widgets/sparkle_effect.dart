import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A burst of sparkle particles that animates and fades out.
/// Trigger by providing a new [triggerKey] value each time.
class SparkleEffect extends StatefulWidget {
  const SparkleEffect({
    super.key,
    required this.triggerKey,
    this.countryId = 'ghana',
    this.particleCount = 6,
    this.size = 120,
  });

  /// Changing this value triggers a new sparkle burst.
  final int triggerKey;
  final String countryId;
  final int particleCount;
  final double size;

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Particle> _particles;
  final math.Random _rng = math.Random();
  int _lastTrigger = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _particles = _generateParticles();
  }

  @override
  void didUpdateWidget(SparkleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerKey != _lastTrigger && widget.triggerKey > 0) {
      _lastTrigger = widget.triggerKey;
      // Respect reduce-motion
      if (MediaQuery.of(context).disableAnimations) return;
      _particles = _generateParticles();
      _controller.forward(from: 0);
    }
  }

  List<_Particle> _generateParticles() {
    return List.generate(widget.particleCount, (_) {
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 30 + _rng.nextDouble() * 50;
      return _Particle(
        dx: math.cos(angle) * speed,
        dy: math.sin(angle) * speed,
        rotation: _rng.nextDouble() * math.pi,
        scale: 0.5 + _rng.nextDouble() * 0.5,
        isStar: _rng.nextBool(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.isAnimating && _controller.value == 0) {
            return const SizedBox.shrink();
          }
          final t = _controller.value;
          final opacity = (1 - t).clamp(0.0, 1.0);

          return Stack(
            clipBehavior: Clip.none,
            children: _particles.map((p) {
              final x = widget.size / 2 + p.dx * t;
              final y = widget.size / 2 + p.dy * t;
              return Positioned(
                left: x - 14,
                top: y - 14,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: p.rotation + t * math.pi,
                    child: Transform.scale(
                      scale: p.scale * (1 - t * 0.5),
                      child: _SparkleIcon(isStar: p.isStar, countryId: widget.countryId),
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          );
        },
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.dx,
    required this.dy,
    required this.rotation,
    required this.scale,
    required this.isStar,
  });

  final double dx;
  final double dy;
  final double rotation;
  final double scale;
  final bool isStar;
}

class _SparkleIcon extends StatelessWidget {
  const _SparkleIcon({required this.isStar, required this.countryId});

  final bool isStar;
  final String countryId;

  @override
  Widget build(BuildContext context) {
    // Try asset first, fall back to painted sparkle.
    return Image.asset(
      isStar
          ? 'assets/cooking/v2/$countryId/effects/sparkle_01.webp'
          : 'assets/cooking/v2/$countryId/effects/sparkle_02.webp',
      width: 50,
      height: 50,
      errorBuilder: (_, _, _) => Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: isStar ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: isStar ? BorderRadius.circular(2) : null,
          gradient: const RadialGradient(
            colors: <Color>[Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
        ),
      ),
    );
  }
}
