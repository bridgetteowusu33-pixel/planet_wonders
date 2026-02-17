import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

class StirPad extends StatelessWidget {
  const StirPad({
    super.key,
    required this.progress,
    required this.onStirStart,
    required this.onStirUpdate,
  });

  final double progress;
  final VoidCallback onStirStart;
  final void Function(Offset localPosition, Size size) onStirUpdate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final size = Size(side, side);

        return Center(
          child: GestureDetector(
            onPanStart: (_) => onStirStart(),
            onPanUpdate: (details) => onStirUpdate(details.localPosition, size),
            child: SizedBox(
              width: side,
              height: side,
              child: CustomPaint(
                painter: _StirPadPainter(progress: progress),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌀', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 4),
                      Text(
                        'Stir in circles',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: PWColors.navy,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: PWColors.blue,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StirPadPainter extends CustomPainter {
  _StirPadPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = PWColors.navy.withValues(alpha: 0.12);

    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = PWColors.mint;

    final inner = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    canvas.drawCircle(center, radius, base);
    canvas.drawCircle(center, radius - 18, inner);

    final sweep = (math.pi * 2) * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _StirPadPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
