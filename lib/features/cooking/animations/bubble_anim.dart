import 'dart:math' as math;

import 'package:flutter/material.dart';

class BubbleAnim extends StatefulWidget {
  const BubbleAnim({
    super.key,
    required this.enabled,
    this.color = const Color(0x88FFFFFF),
  });

  final bool enabled;
  final Color color;

  @override
  State<BubbleAnim> createState() => _BubbleAnimState();
}

class _BubbleAnimState extends State<BubbleAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant BubbleAnim oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.enabled) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _BubblePainter(
                t: _controller.value,
                color: widget.color,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const bubbles = 12;
    for (int i = 0; i < bubbles; i++) {
      final phase = (t + i / bubbles) % 1.0;
      final x = size.width * (0.12 + (i % 6) * 0.14);
      final y = size.height * (1 - phase);
      final radius = 3.5 + math.sin((phase + i) * math.pi) * 2;
      paint.color = color.withValues(alpha: (0.2 + (1 - phase) * 0.5));
      canvas.drawCircle(Offset(x, y), radius.clamp(1.2, 7), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}
