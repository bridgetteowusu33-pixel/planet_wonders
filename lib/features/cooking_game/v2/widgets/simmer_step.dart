import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/cooking_audio_service.dart';
import '../models/pot_face_state.dart';
import '../models/v2_recipe_step.dart';
import 'illustrated_pot.dart';

class SimmerStep extends StatefulWidget {
  const SimmerStep({
    super.key,
    required this.step,
    required this.progress,
    required this.onProgressDelta,
    this.countryId = 'ghana',
  });

  final V2RecipeStep step;
  final double progress;
  final void Function(double delta) onProgressDelta;
  final String countryId;

  @override
  State<SimmerStep> createState() => _SimmerStepState();
}

class _SimmerStepState extends State<SimmerStep> {
  final math.Random _rng = math.Random();
  final List<_Bubble> _bubbles = <_Bubble>[];
  Timer? _bubbleTimer;
  Timer? _autoProgressTimer;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
  }

  @override
  void initState() {
    super.initState();
    // Spawn bubbles periodically (skip when reduce-motion is active).
    _bubbleTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (!mounted || _reduceMotion) return;
      setState(() {
        _bubbles.add(_Bubble(
          x: 0.2 + _rng.nextDouble() * 0.6,
          id: DateTime.now().microsecondsSinceEpoch,
        ));
        // Clean up old bubbles.
        if (_bubbles.length > 8) {
          _bubbles.removeRange(0, _bubbles.length - 8);
        }
      });
    });

    // Auto-progress slowly (simmering happens over time).
    // When reduce-motion is on, progress faster to compensate for no bubble tapping.
    _autoProgressTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      widget.onProgressDelta(_reduceMotion ? 0.02 : 0.008);
    });
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    _autoProgressTimer?.cancel();
    super.dispose();
  }

  void _tapBubble(int id) {
    setState(() {
      _bubbles.removeWhere((b) => b.id == id);
    });
    HapticFeedback.lightImpact();
    CookingAudioService.instance.playSfx('bubble', widget.countryId);
    // Tapping bubbles gives bonus progress.
    widget.onProgressDelta(0.04);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                children: <Widget>[
                  // Illustrated pot
                  Center(
                    child: IllustratedPot(
                      countryId: widget.countryId,
                      faceState: PotFaceState.delicious,
                      size: 220,
                      progress: widget.progress,
                    ),
                  ),
                  // Bubbles
                  for (final bubble in _bubbles)
                    _BubbleWidget(
                      key: ValueKey<int>(bubble.id),
                      bubble: bubble,
                      countryId: widget.countryId,
                      areaWidth: w,
                      areaHeight: h,
                      onTap: () => _tapBubble(bubble.id),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 8),
        Text(
          _reduceMotion
              ? 'Simmering... ${(widget.progress * 100).round()}%'
              : 'Tap the bubbles for a bonus!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF264653).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Bubble {
  const _Bubble({required this.x, required this.id});

  final double x;
  final int id;
}

class _BubbleWidget extends StatefulWidget {
  const _BubbleWidget({
    super.key,
    required this.bubble,
    required this.countryId,
    required this.areaWidth,
    required this.areaHeight,
    required this.onTap,
  });

  final _Bubble bubble;
  final String countryId;
  final double areaWidth;
  final double areaHeight;
  final VoidCallback onTap;

  @override
  State<_BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<_BubbleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rise;

  @override
  void initState() {
    super.initState();
    _rise = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _rise.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rise,
      builder: (context, child) {
        final t = _rise.value;
        final x = widget.bubble.x * widget.areaWidth;
        final startY = widget.areaHeight * 0.6;
        final y = startY - t * widget.areaHeight * 0.5;
        final opacity = (1 - t).clamp(0.0, 1.0);

        return Positioned(
          left: x - 32,
          top: y,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Image.asset(
          'assets/cooking/v2/${widget.countryId}/effects/bubble.webp',
          width: 100,
          height: 100,
          cacheWidth: 200,
          errorBuilder: (_, _, _) => Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.6),
              border: Border.all(
                color: const Color(0xFF90CAF9),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                '\u{1FAE7}',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
