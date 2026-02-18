import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animations/bubble_anim.dart';
import '../animations/steam_anim.dart';
import '../engine/cooking_step.dart';
import '../models/ingredient.dart';
import 'stir_widget.dart';

class PotWidget extends StatefulWidget {
  const PotWidget({
    super.key,
    required this.potAsset,
    required this.step,
    required this.progress,
    required this.splashTick,
    required this.successGlow,
    required this.dropAssetPath,
    required this.onIngredientAccepted,
    required this.onStirStart,
    required this.onStirUpdate,
    required this.onStirEnd,
  });

  final String potAsset;
  final CookingStep step;
  final double progress;
  final int splashTick;
  final bool successGlow;
  final String? dropAssetPath;
  final ValueChanged<Ingredient> onIngredientAccepted;
  final ValueChanged<Offset> onStirStart;
  final void Function(Offset localPosition, Size size) onStirUpdate;
  final VoidCallback onStirEnd;

  @override
  State<PotWidget> createState() => _PotWidgetState();
}

class _PotWidgetState extends State<PotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStirStep = widget.step == CookingStep.stir;
    final steamActive =
        widget.step == CookingStep.serve || widget.step == CookingStep.complete;

    return RepaintBoundary(
      child: DragTarget<Ingredient>(
        onAcceptWithDetails: (details) =>
            widget.onIngredientAccepted(details.data),
        builder: (context, candidateData, rejectedData) {
          final isDraggingOver = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(42),
              gradient: const LinearGradient(
                colors: <Color>[Color(0xCCF8FEFF), Color(0xA3DDF6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isDraggingOver
                    ? const Color(0xFFFFD166)
                    : const Color(0xFFFFFFFF),
                width: isDraggingOver ? 3 : 2,
              ),
              boxShadow: <BoxShadow>[
                const BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 20,
                  offset: Offset(0, 12),
                ),
                if (widget.successGlow)
                  const BoxShadow(
                    color: Color(0x66FFD166),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 1.12,
              child: AnimatedBuilder(
                animation: _loop,
                builder: (context, child) {
                  return TweenAnimationBuilder<double>(
                    key: ValueKey<int>(widget.splashTick),
                    tween: Tween<double>(begin: 1.08, end: 1),
                    curve: Curves.elasticOut,
                    duration: const Duration(milliseconds: 420),
                    builder: (context, pop, child) {
                      return Transform.scale(scale: pop, child: child);
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        CustomPaint(
                          painter: _StorybookPotPainter(
                            waveT: _loop.value,
                            progress: widget.progress,
                            showSwirl: isStirStep,
                            isDraggingOver: isDraggingOver,
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _ProgressRingPainter(
                                progress: isStirStep ? widget.progress : 0,
                              ),
                            ),
                          ),
                        ),
                        BubbleAnim(
                          enabled: widget.step != CookingStep.addIngredients,
                          color: const Color(0x77FFFFFF),
                        ),
                        SteamAnim(active: steamActive),
                        if (isStirStep)
                          Center(
                            child: Transform.rotate(
                              angle: _loop.value * math.pi * 2,
                              child: Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  size: 46,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (isStirStep)
                          Positioned.fill(
                            child: StirWidget(
                              progress: widget.progress,
                              onStart: widget.onStirStart,
                              onUpdate: widget.onStirUpdate,
                              onEnd: widget.onStirEnd,
                            ),
                          ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey<int>(widget.splashTick * 17),
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, t, child) {
                                if (t <= 0.01) {
                                  return const SizedBox.expand();
                                }

                                return Stack(
                                  children: <Widget>[
                                    CustomPaint(
                                      painter: _DropBurstPainter(t: t),
                                      size: Size.infinite,
                                    ),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Transform.translate(
                                        offset: Offset(0, -40 + 140 * t),
                                        child: Transform.scale(
                                          scale: (1.2 - (t * 1.0)).clamp(
                                            0,
                                            1.2,
                                          ),
                                          child: Opacity(
                                            opacity: (1 - t).clamp(0, 1),
                                            child: _FlyingIngredient(
                                              assetPath: widget.dropAssetPath,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FlyingIngredient extends StatelessWidget {
  const _FlyingIngredient({required this.assetPath});

  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path == null || path.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFF6D6),
        ),
        child: const Icon(
          Icons.ramen_dining,
          color: Color(0xFF355070),
          size: 34,
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFF6D6),
      ),
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.ramen_dining,
            color: Color(0xFF355070),
            size: 34,
          );
        },
      ),
    );
  }
}

class _StorybookPotPainter extends CustomPainter {
  const _StorybookPotPainter({
    required this.waveT,
    required this.progress,
    required this.showSwirl,
    required this.isDraggingOver,
  });

  final double waveT;
  final double progress;
  final bool showSwirl;
  final bool isDraggingOver;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final potRect = Rect.fromCenter(
      center: center.translate(0, 18),
      width: size.width * 0.58,
      height: size.height * 0.48,
    );
    final rimRect = Rect.fromCenter(
      center: center.translate(0, -2),
      width: size.width * 0.56,
      height: size.height * 0.14,
    );

    final shadowPaint = Paint()
      ..color = const Color(0x2A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size.height * 0.35),
        width: size.width * 0.56,
        height: size.height * 0.1,
      ),
      shadowPaint,
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFF6C7AA0), Color(0xFF47577F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(potRect);

    final potRRect = RRect.fromRectAndRadius(
      potRect,
      const Radius.circular(42),
    );
    canvas.drawRRect(potRRect, bodyPaint);

    final rimPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFA8B6DA), Color(0xFF6D7CA3)],
      ).createShader(rimRect);
    canvas.drawOval(rimRect, rimPaint);

    final liquidRect = Rect.fromCenter(
      center: center.translate(0, 6),
      width: rimRect.width * 0.92,
      height: rimRect.height * 0.86,
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(liquidRect));

    final liquidPaint = Paint()
      ..shader = LinearGradient(
        colors: <Color>[
          const Color(0xFFFFC971),
          const Color(0xFFFF9E4A),
          const Color(0xFFFFB86B),
        ],
        transform: GradientRotation(waveT * math.pi * 2),
      ).createShader(liquidRect);

    final wavePath = Path()..moveTo(liquidRect.left, liquidRect.bottom);
    final topBase = liquidRect.center.dy - 3;
    for (double x = liquidRect.left; x <= liquidRect.right + 4; x += 4) {
      final normalized = (x - liquidRect.left) / liquidRect.width;
      final wave =
          math.sin((normalized * 6 + waveT * 2) * math.pi) * 4 +
          math.cos((normalized * 4 + waveT * 1.4) * math.pi) * 1.8;
      wavePath.lineTo(x, topBase + wave);
    }
    wavePath
      ..lineTo(liquidRect.right, liquidRect.bottom)
      ..close();
    canvas.drawPath(wavePath, liquidPaint);

    canvas.restore();

    final lidRect = Rect.fromCenter(
      center: center.translate(0, -potRect.height * 0.44),
      width: rimRect.width * 0.9,
      height: size.height * 0.1,
    );
    final lidPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFD4DCF2), Color(0xFF9CAACC)],
      ).createShader(lidRect);
    canvas.drawOval(lidRect, lidPaint);

    final knobPaint = Paint()..color = const Color(0xFF596B93);
    canvas.drawCircle(lidRect.center.translate(0, -8), 11, knobPaint);

    final handlePaint = Paint()..color = const Color(0xFF546289);
    canvas.drawOval(
      Rect.fromCenter(
        center: potRect.centerLeft.translate(-14, 0),
        width: 28,
        height: 14,
      ),
      handlePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: potRect.centerRight.translate(14, 0),
        width: 28,
        height: 14,
      ),
      handlePaint,
    );

    if (showSwirl) {
      final swirlPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.4
        ..color = Colors.white.withValues(alpha: 0.74);

      for (int i = 0; i < 3; i++) {
        final radius = 18 + i * 10;
        final start = waveT * math.pi * 2 + i * 0.5;
        canvas.drawArc(
          Rect.fromCircle(center: liquidRect.center, radius: radius.toDouble()),
          start,
          math.pi * 1.15,
          false,
          swirlPaint,
        );
      }
    }

    final rimStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = isDraggingOver
          ? const Color(0xFFFFE08A)
          : const Color(0x99FFFFFF);
    canvas.drawOval(rimRect, rimStroke);

    final sparklePaint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.4 + progress.clamp(0, 1) * 0.4,
      );
    canvas.drawCircle(rimRect.topLeft.translate(24, 10), 3.2, sparklePaint);
    canvas.drawCircle(rimRect.topRight.translate(-22, 12), 2.8, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant _StorybookPotPainter oldDelegate) {
    return oldDelegate.waveT != waveT ||
        oldDelegate.progress != progress ||
        oldDelegate.showSwirl != showSwirl ||
        oldDelegate.isDraggingOver != isDraggingOver;
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.44;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = const Color(0x3DFFFFFF);

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFFFD166), Color(0xFFFF8E72)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress.clamp(0, 1) * math.pi * 2,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _DropBurstPainter extends CustomPainter {
  const _DropBurstPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = Curves.easeOut.transform(t);
    final center = Offset(size.width * 0.5, size.height * 0.46);

    final splashPaint = Paint()
      ..color = const Color(0x99FFF3B0).withValues(alpha: (1 - t).clamp(0, 1));
    canvas.drawCircle(center, 20 + 46 * progress, splashPaint);

    final sparklePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4
      ..color = Colors.white.withValues(alpha: (1 - t).clamp(0, 1));

    for (int i = 0; i < 14; i++) {
      final angle = (i / 14) * math.pi * 2;
      final start =
          center +
          Offset(math.cos(angle), math.sin(angle)) * (12 + progress * 14);
      final end =
          center +
          Offset(math.cos(angle), math.sin(angle)) * (22 + progress * 34);
      canvas.drawLine(start, end, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DropBurstPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
