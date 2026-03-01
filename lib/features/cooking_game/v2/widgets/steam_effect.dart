import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated steam wisps rising from the pot.
/// Respects reduce-motion preferences.
class SteamEffect extends StatefulWidget {
  const SteamEffect({
    super.key,
    this.countryId = 'ghana',
    this.width = 120,
    this.height = 80,
    this.wispCount = 3,
  });

  final String countryId;
  final double width;
  final double height;
  final int wispCount;

  @override
  State<SteamEffect> createState() => _SteamEffectState();
}

class _SteamEffectState extends State<SteamEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Wisp> _wisps;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _wisps = List.generate(widget.wispCount, (_) => _Wisp(
      xOffset: _rng.nextDouble() * 0.6 + 0.2,
      phase: _rng.nextDouble(),
      speed: 0.6 + _rng.nextDouble() * 0.4,
    ));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) return;
      _controller.repeat();
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
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: _wisps.map((wisp) {
              final t = (_controller.value + wisp.phase) % 1.0;
              final x = wisp.xOffset * widget.width +
                  math.sin(t * math.pi * 2) * 8;
              final y = widget.height * (1 - t * wisp.speed);
              final opacity = (1 - t).clamp(0.0, 0.6);
              final scale = 0.5 + t * 0.5;

              return Positioned(
                left: x - 20,
                top: y,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Image.asset(
                      'assets/cooking/v2/${widget.countryId}/effects/steam.webp',
                      width: 50,
                      height: 50,
                      errorBuilder: (_, _, _) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              Colors.white.withValues(alpha: 0.5),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
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

class _Wisp {
  const _Wisp({
    required this.xOffset,
    required this.phase,
    required this.speed,
  });

  final double xOffset;
  final double phase;
  final double speed;
}
