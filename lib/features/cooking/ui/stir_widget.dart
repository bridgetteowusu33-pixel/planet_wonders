import 'package:flutter/material.dart';

class StirWidget extends StatelessWidget {
  const StirWidget({
    super.key,
    required this.progress,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
  });

  final double progress;
  final void Function(Offset localPosition) onStart;
  final void Function(Offset localPosition, Size size) onUpdate;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) => onStart(details.localPosition),
            onPanUpdate: (details) => onUpdate(details.localPosition, size),
            onPanEnd: (_) => onEnd(),
            child: CustomPaint(
              painter: _RingPainter(progress: progress),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.43;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = const Color(0x44FFFFFF);

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFFF8FAB), Color(0xFFFFC971)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      progress.clamp(0, 1) * 6.283,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
