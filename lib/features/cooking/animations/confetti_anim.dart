import 'dart:math' as math;

import 'package:flutter/material.dart';

class ConfettiAnim extends StatefulWidget {
  const ConfettiAnim({super.key, required this.playTick});

  final int playTick;

  @override
  State<ConfettiAnim> createState() => _ConfettiAnimState();
}

class _ConfettiAnimState extends State<ConfettiAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void didUpdateWidget(covariant ConfettiAnim oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playTick != oldWidget.playTick) {
      _controller
        ..reset()
        ..forward();
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
            if (_controller.value == 0) {
              return const SizedBox.expand();
            }
            return CustomPaint(
              painter: _ConfettiPainter(_controller.value),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = <Color>[
      const Color(0xFFFFB703),
      const Color(0xFFFB8500),
      const Color(0xFF8ECAE6),
      const Color(0xFF219EBC),
      const Color(0xFFFF6B6B),
    ];

    for (int i = 0; i < 45; i++) {
      final lane = i % 9;
      final burst = (i ~/ 9) / 5;
      final progress = Curves.easeOut.transform(t);
      final dx = size.width * (0.1 + lane * 0.1) + math.sin(i * 2.1 + t) * 18;
      final dy =
          size.height * (0.15 + burst * 0.04) + progress * size.height * 0.8;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(
          alpha: (1 - t).clamp(0, 1),
        )
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(i * 0.3 + progress * 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 7, height: 12),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
