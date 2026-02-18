import 'package:flutter/material.dart';

import '../engine/cooking_step.dart';

class ServeWidget extends StatelessWidget {
  const ServeWidget({
    super.key,
    required this.step,
    required this.progress,
    required this.servedCount,
    required this.requiredServes,
    required this.onServe,
  });

  final CookingStep step;
  final double progress;
  final int servedCount;
  final int requiredServes;
  final Future<void> Function() onServe;

  @override
  Widget build(BuildContext context) {
    final isActive = step == CookingStep.serve;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFFFF9E6), Color(0xFFFFE6C9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 12,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Serve',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF3A506B),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$servedCount/$requiredServes',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3A506B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 12,
                backgroundColor: const Color(0x33FFFFFF),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF8C42),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Opacity(
                    opacity: isActive ? 1 : 0.45,
                    child: Draggable<String>(
                      data: 'scoop',
                      feedback: const _ScoopChip(scale: 1.06),
                      childWhenDragging: const _ScoopChip(opacity: 0.4),
                      child: const _ScoopChip(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (details) => isActive,
                    onAcceptWithDetails: (_) {
                      onServe();
                    },
                    builder: (context, candidateData, rejectedData) {
                      final highlight = candidateData.isNotEmpty && isActive;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        height: 92,
                        decoration: BoxDecoration(
                          color: highlight
                              ? const Color(0xFFFFD166)
                              : const Color(0xFFF7F5E9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Drop on Plate',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2D3142),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoopChip extends StatelessWidget {
  const _ScoopChip({this.scale = 1, this.opacity = 1});

  final double scale;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF8ECAE6), Color(0xFF56CFE1)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.icecream, size: 42, color: Colors.white),
        ),
      ),
    );
  }
}
