import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/puzzle_models.dart';
import 'star_row.dart';

Future<void> showPuzzleWinModal({
  required BuildContext context,
  required PuzzleItem puzzle,
  required int stars,
  required int elapsedMs,
  required int moves,
  required bool reduceMotion,
  required VoidCallback onReplay,
  required VoidCallback onNext,
  required VoidCallback onDone,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PuzzleWinModal(
      puzzle: puzzle,
      stars: stars,
      elapsedMs: elapsedMs,
      moves: moves,
      reduceMotion: reduceMotion,
      onReplay: onReplay,
      onNext: onNext,
      onDone: onDone,
    ),
  );
}

class _PuzzleWinModal extends StatefulWidget {
  const _PuzzleWinModal({
    required this.puzzle,
    required this.stars,
    required this.elapsedMs,
    required this.moves,
    required this.reduceMotion,
    required this.onReplay,
    required this.onNext,
    required this.onDone,
  });

  final PuzzleItem puzzle;
  final int stars;
  final int elapsedMs;
  final int moves;
  final bool reduceMotion;
  final VoidCallback onReplay;
  final VoidCallback onNext;
  final VoidCallback onDone;

  @override
  State<_PuzzleWinModal> createState() => _PuzzleWinModalState();
}

class _PuzzleWinModalState extends State<_PuzzleWinModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: widget.reduceMotion
          ? const Duration(milliseconds: 1)
          : const Duration(milliseconds: 2400),
    )..forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSec = widget.elapsedMs ~/ 1000;
    final mins = totalSec ~/ 60;
    final secs = totalSec % 60;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Stack(
        children: [
          if (!widget.reduceMotion)
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, _) => CustomPaint(
                      painter: _ConfettiPainter(
                        progress: _confettiController.value,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Great Job!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F3B78),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.puzzle.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF365A9A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                StarRow(stars: widget.stars, size: 30),
                const SizedBox(height: 14),
                _StatLine(
                  label: 'Time',
                  value: '$mins:${secs.toString().padLeft(2, '0')}',
                ),
                _StatLine(label: 'Moves', value: '${widget.moves}'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'Replay',
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onReplay();
                          },
                          child: const Text('Replay'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'Next puzzle',
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onNext();
                          },
                          child: const Text('Next Puzzle'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Semantics(
                  button: true,
                  label: 'Done',
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDone();
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF415B90),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF203E7A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});

  final double progress;

  static const _colors = <Color>[
    Color(0xFFFF7043),
    Color(0xFFFFCA28),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final count = 36;
    for (var i = 0; i < count; i++) {
      final t = (i / count + progress).remainder(1);
      final x = (size.width * ((i * 0.618) % 1));
      final y = (size.height * t) - 20;
      final paint = Paint()..color = _colors[i % _colors.length];
      final r = 4 + (i % 4).toDouble();
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * math.pi * (i.isEven ? 1 : -1));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: r * 1.4, height: r * 0.8),
          const Radius.circular(2),
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
