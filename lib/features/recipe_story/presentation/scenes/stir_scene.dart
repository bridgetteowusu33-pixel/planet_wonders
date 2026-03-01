import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/pw_theme.dart';
import '../../domain/recipe.dart';
import '../../engine/recipe_engine.dart';
import '../widgets/scene_background.dart';

class StirScene extends StatefulWidget {
  const StirScene({
    super.key,
    required this.step,
    required this.progress,
    required this.interactionCount,
    required this.onProgressDelta,
  });

  final RecipeStoryStep step;
  final double progress;
  final int interactionCount;
  final ValueChanged<double> onProgressDelta;

  @override
  State<StirScene> createState() => _StirSceneState();
}

class _StirSceneState extends State<StirScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swirlAnim;

  @override
  void initState() {
    super.initState();
    _swirlAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();
  }

  @override
  void dispose() {
    _swirlAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = const RecipeEngine().sceneColorsForAction(
      widget.step.action,
    );
    final isDone = widget.progress >= 1;

    return SceneBackground(
      sceneColors: colors,
      child: GestureDetector(
        onPanUpdate: (details) {
          final delta = details.delta.distance / 220;
          widget.onProgressDelta(delta.clamp(0.0, 0.08));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Stir Storm! 🥄',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1D3557),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: AnimatedBuilder(
                  animation: _swirlAnim,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        CustomPaint(
                          size: const Size.square(240),
                          painter: _StirProgressPainter(
                            progress: widget.progress,
                            spin: _swirlAnim.value,
                          ),
                        ),
                        Container(
                          width: 176,
                          height: 176,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.8),
                            border: Border.all(
                              color: Color(
                                colors.accent,
                              ).withValues(alpha: 0.35),
                              width: 3,
                            ),
                          ),
                          child: CustomPaint(
                            painter: _LiquidSwirlPainter(
                              spin: _swirlAnim.value,
                              progress: widget.progress,
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: _swirlAnim.value * math.pi * 2,
                          child: const Text(
                            '🌀',
                            style: TextStyle(fontSize: 42),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isDone
                    ? 'Perfect stir!'
                    : 'Stir in circles! ${(widget.progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDone
                      ? PWColors.mint
                      : PWColors.navy.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StirProgressPainter extends CustomPainter {
  const _StirProgressPainter({required this.progress, required this.spin});

  final double progress;
  final double spin;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.44;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = Colors.white.withValues(alpha: 0.45);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFFFC971), Color(0xFFFF8E72)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + spin * 0.8,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _StirProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.spin != spin;
  }
}

class _LiquidSwirlPainter extends CustomPainter {
  const _LiquidSwirlPainter({required this.spin, required this.progress});

  final double spin;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(
      center: center,
      radius: size.shortestSide * 0.45,
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    final liquid = Paint()
      ..shader = LinearGradient(
        colors: const <Color>[
          Color(0xFFFFC971),
          Color(0xFFFFA855),
          Color(0xFFFFD88A),
        ],
        transform: GradientRotation(spin * math.pi * 2),
      ).createShader(rect);

    final wavePath = Path()..moveTo(rect.left, rect.bottom);
    final baseline = center.dy + 8;
    for (double x = rect.left; x <= rect.right; x += 4) {
      final nx = (x - rect.left) / rect.width;
      final wave = math.sin((nx * 8 + spin * 3) * math.pi) * 5;
      wavePath.lineTo(x, baseline + wave);
    }
    wavePath
      ..lineTo(rect.right, rect.bottom)
      ..close();

    canvas.drawPath(wavePath, liquid);

    final swirl = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..color = Colors.white.withValues(alpha: 0.6);

    for (int i = 0; i < 3; i++) {
      final radius = 16 + i * 11;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius.toDouble()),
        spin * math.pi * 2 + i * 0.4,
        math.pi * (1.1 + progress * 0.7),
        false,
        swirl,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiquidSwirlPainter oldDelegate) {
    return oldDelegate.spin != spin || oldDelegate.progress != progress;
  }
}
