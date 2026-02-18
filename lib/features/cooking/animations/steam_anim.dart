import 'dart:math' as math;

import 'package:flutter/material.dart';

class SteamAnim extends StatefulWidget {
  const SteamAnim({super.key, required this.active});

  final bool active;

  @override
  State<SteamAnim> createState() => _SteamAnimState();
}

class _SteamAnimState extends State<SteamAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant SteamAnim oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.active) {
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
              painter: _SteamPainter(_controller.value),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _SteamPainter extends CustomPainter {
  const _SteamPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final phase = (t + i * 0.25) % 1.0;
      final x = size.width * (0.35 + i * 0.1);
      final startY = size.height * 0.62;
      final height = size.height * (0.2 + phase * 0.4);

      paint.color = Colors.white.withValues(alpha: 0.22 + (1 - phase) * 0.35);

      final path = Path();
      for (int step = 0; step <= 18; step++) {
        final p = step / 18;
        final wave = math.sin((p * 2.5 + phase + i) * math.pi) * 8;
        final px = x + wave;
        final py = startY - height * p;
        if (step == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SteamPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
