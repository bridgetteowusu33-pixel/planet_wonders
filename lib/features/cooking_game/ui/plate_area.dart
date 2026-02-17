import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

class PlateArea extends StatelessWidget {
  const PlateArea({
    super.key,
    required this.progress,
    required this.onServe,
  });

  final double progress;
  final VoidCallback onServe;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: DragTarget<String>(
                  onWillAcceptWithDetails: (details) => details.data == 'spoon',
                  onAcceptWithDetails: (_) => onServe(),
                  builder: (context, candidateData, rejectedData) {
                    final active = candidateData.isNotEmpty;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: active ? PWColors.mint : PWColors.navy,
                          width: active ? 8 : 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: PWColors.navy.withValues(alpha: 0.14),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 220,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 18,
                              backgroundColor: PWColors.navy.withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(PWColors.yellow),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 28,
              bottom: 20,
              child: Draggable<String>(
                data: 'spoon',
                feedback: const _SpoonIcon(size: 86),
                childWhenDragging: const Opacity(
                  opacity: 0.35,
                  child: _SpoonIcon(size: 78),
                ),
                child: const _SpoonIcon(size: 78),
              ),
            ),
            Positioned(
              right: 24,
              top: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: PWColors.yellow.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PWColors.navy.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  'Serve: ${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SpoonIcon extends StatelessWidget {
  const _SpoonIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: PWColors.navy.withValues(alpha: 0.2)),
      ),
      alignment: Alignment.center,
      child: const Text('🥄', style: TextStyle(fontSize: 36)),
    );
  }
}
