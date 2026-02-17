import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/recipe.dart';

class PotArea extends StatefulWidget {
  const PotArea({
    super.key,
    required this.ingredients,
    required this.addedIngredientIds,
    required this.onIngredientDropped,
    this.bubbling = false,
    this.dropAnimationTick = 0,
  });

  final List<Ingredient> ingredients;
  final Set<String> addedIngredientIds;
  final ValueChanged<Ingredient> onIngredientDropped;
  final bool bubbling;
  final int dropAnimationTick;

  @override
  State<PotArea> createState() => _PotAreaState();
}

class _PotAreaState extends State<PotArea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant PotArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bubbling && !_bubbleController.isAnimating) {
      _bubbleController.repeat();
    } else if (!widget.bubbling && _bubbleController.isAnimating) {
      _bubbleController.stop();
    }
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final added = widget.ingredients
        .where((i) => widget.addedIngredientIds.contains(i.id))
        .toList(growable: false);

    return DragTarget<Ingredient>(
      onWillAcceptWithDetails: (details) {
        return !widget.addedIngredientIds.contains(details.data.id);
      },
      onAcceptWithDetails: (details) {
        widget.onIngredientDropped(details.data);
      },
      builder: (context, candidate, rejected) {
        final isActive = candidate.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: PWColors.blue.withValues(alpha: 0.08),
            border: Border.all(
              color: isActive ? PWColors.mint : PWColors.navy.withValues(alpha: 0.12),
              width: isActive ? 3 : 1,
            ),
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(widget.dropAnimationTick),
              tween: Tween<double>(begin: 1.10, end: 1.0),
              curve: Curves.easeOutBack,
              duration: const Duration(milliseconds: 260),
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: SizedBox(
                width: 280,
                height: 220,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: PWColors.navy, width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: PWColors.navy.withValues(alpha: 0.14),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      top: 30,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: PWColors.yellow.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: PWColors.navy.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      right: -20,
                      top: -40,
                      height: 70,
                      child: CustomPaint(
                        painter: _SteamPainter(
                          progress: _bubbleController.value,
                          visible: widget.bubbling,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BubblePainter(
                          progress: _bubbleController.value,
                          visible: widget.bubbling,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 36,
                      right: 36,
                      bottom: 24,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final ingredient in added)
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: PWColors.mint.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: PWColors.navy.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(ingredient.emoji, style: const TextStyle(fontSize: 18)),
                            ),
                        ],
                      ),
                    ),
                    if (added.isEmpty)
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            'Drop ingredients here',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: PWColors.navy.withValues(alpha: 0.65),
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SteamPainter extends CustomPainter {
  _SteamPainter({required this.progress, required this.visible});

  final double progress;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..color = PWColors.navy.withValues(alpha: 0.35);

    final centers = [size.width * 0.25, size.width * 0.5, size.width * 0.75];
    for (int i = 0; i < centers.length; i++) {
      final x = centers[i];
      final path = Path()..moveTo(x, size.height);
      for (int step = 1; step <= 7; step++) {
        final t = step / 7;
        final y = size.height - (t * size.height);
        final wave = math.sin((t * math.pi * 2) + (progress * math.pi * 2) + i) * 9;
        path.lineTo(x + wave, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SteamPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.visible != visible;
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({required this.progress, required this.visible});

  final double progress;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;

    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = PWColors.navy.withValues(alpha: 0.45);

    final baseY = size.height * 0.56;
    for (int i = 0; i < 8; i++) {
      final t = ((progress + (i * 0.13)) % 1.0);
      final x = 45 + (i * 28.0);
      final y = baseY - (t * 48);
      final r = 4 + (i % 3) * 2.0;
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.visible != visible;
  }
}
