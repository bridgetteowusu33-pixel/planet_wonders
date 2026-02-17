import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';

class BadgeUnlockAnimationListener extends ConsumerStatefulWidget {
  const BadgeUnlockAnimationListener({super.key});

  @override
  ConsumerState<BadgeUnlockAnimationListener> createState() =>
      _BadgeUnlockAnimationListenerState();
}

class _BadgeUnlockAnimationListenerState
    extends ConsumerState<BadgeUnlockAnimationListener> {
  Achievement? _active;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(achievementProvider);
    final pending = state.pendingUnlockAchievement;

    if (_active == null && pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _start(pending);
      });
    }

    if (_active == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(child: BadgeUnlockAnimation(achievement: _active!));
  }

  void _start(Achievement achievement) {
    setState(() {
      _active = achievement;
    });

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      ref.read(achievementProvider.notifier).consumePendingUnlock();
      setState(() {
        _active = null;
      });
    });
  }
}

class BadgeUnlockAnimation extends StatefulWidget {
  const BadgeUnlockAnimation({super.key, required this.achievement});

  final Achievement achievement;

  @override
  State<BadgeUnlockAnimation> createState() => _BadgeUnlockAnimationState();
}

class _BadgeUnlockAnimationState extends State<BadgeUnlockAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    final pop =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.75, end: 1.12),
            weight: 45,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.12, end: 1.0),
            weight: 55,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              0.1,
              0.65,
              curve: _ClampedCurve(Curves.easeOutBack),
            ),
          ),
        );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: math.max(0.0, math.min(1.0, 1.15 - _controller.value)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _ConfettiPainter(progress: _controller.value),
              ),
              Center(
                child: FadeTransition(
                  opacity: fade,
                  child: ScaleTransition(
                    scale: pop,
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: PWColors.yellow.withValues(alpha: 0.5),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: PWColors.yellow.withValues(alpha: 0.8),
                          width: 2.4,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              widget.achievement.iconPath,
                              width: 86,
                              height: 86,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.emoji_events_rounded,
                                    color: PWColors.yellow,
                                    size: 58,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Badge Unlocked!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: PWColors.navy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.achievement.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: PWColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = <Color>[
      PWColors.yellow,
      PWColors.coral,
      PWColors.mint,
      PWColors.blue,
      const Color(0xFF9C27B0),
    ];

    for (var i = 0; i < 54; i++) {
      final seed = i * 13.0;
      final startX = (seed * 97) % size.width;
      final drift = math.sin(seed) * 90;
      final y = -30 + (progress * (size.height + 120));
      final x = (startX + drift * progress) % size.width;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.9);

      canvas.save();
      canvas.translate(x, y - (i % 12) * 40);
      canvas.rotate(progress * (i % 7));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-5, -8, 10, 16),
          const Radius.circular(3),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Prevents overshoot curves from returning values outside 0..1.
class _ClampedCurve extends Curve {
  const _ClampedCurve(this.base);

  final Curve base;

  @override
  double transformInternal(double t) {
    return base.transform(t).clamp(0.0, 1.0).toDouble();
  }
}
