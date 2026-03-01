import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/motion_settings_provider.dart';
import '../../../core/theme/pw_theme.dart';
import '../models/sticker.dart';
import '../providers/sticker_provider.dart';

/// Listens for newly unlocked stickers and shows a celebration overlay.
///
/// Place this widget in a [Stack] alongside the main content — it renders
/// on top when a pending sticker unlock is queued.
class StickerUnlockAnimationListener extends ConsumerStatefulWidget {
  const StickerUnlockAnimationListener({super.key});

  @override
  ConsumerState<StickerUnlockAnimationListener> createState() =>
      _StickerUnlockAnimationListenerState();
}

class _StickerUnlockAnimationListenerState
    extends ConsumerState<StickerUnlockAnimationListener> {
  Sticker? _active;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stickerProvider);
    final pending = state.pendingUnlockSticker;

    if (_active == null && pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _start(pending);
      });
    }

    if (_active == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: _StickerUnlockAnimation(sticker: _active!),
    );
  }

  void _start(Sticker sticker) {
    setState(() => _active = sticker);

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      ref.read(stickerProvider.notifier).consumePendingUnlock();
      setState(() => _active = null);
    });
  }
}

// ---------------------------------------------------------------------------

class _StickerUnlockAnimation extends ConsumerStatefulWidget {
  const _StickerUnlockAnimation({required this.sticker});

  final Sticker sticker;

  @override
  ConsumerState<_StickerUnlockAnimation> createState() =>
      _StickerUnlockAnimationState();
}

class _StickerUnlockAnimationState
    extends ConsumerState<_StickerUnlockAnimation>
    with SingleTickerProviderStateMixin {
  late final bool _reduceMotion;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _reduceMotion = ref.read(motionSettingsProvider).reduceMotionEffective;
    _controller = AnimationController(
      vsync: this,
      duration: _reduceMotion
          ? const Duration(milliseconds: 150)
          : const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: _controller.value.clamp(0.0, 1.0),
            child: Center(child: _stickerCard()),
          );
        },
      );
    }

    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    final pop = TweenSequence<double>([
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
        curve: const Interval(0.1, 0.65, curve: _ClampedCurve(Curves.easeOutBack)),
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
                    child: _stickerCard(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stickerCard() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
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
          // Sticker image (emoji fallback)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              widget.sticker.assetPath,
              width: 96,
              height: 96,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Text(
                widget.sticker.emoji,
                style: const TextStyle(fontSize: 64),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'New Sticker!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: PWColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.sticker.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: PWColors.coral,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

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

class _ClampedCurve extends Curve {
  const _ClampedCurve(this.base);

  final Curve base;

  @override
  double transformInternal(double t) {
    return base.transform(t).clamp(0.0, 1.0).toDouble();
  }
}
