import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/cooking_audio_service.dart';
import '../models/v2_recipe_step.dart';
import 'prop_image.dart';

class SeasonStep extends StatefulWidget {
  const SeasonStep({
    super.key,
    required this.step,
    required this.progress,
    required this.interactionCount,
    required this.onTap,
    this.countryId = 'ghana',
  });

  final V2RecipeStep step;
  final double progress;
  final int interactionCount;
  final VoidCallback onTap;
  final String countryId;

  @override
  State<SeasonStep> createState() => _SeasonStepState();
}

class _SeasonStepState extends State<SeasonStep> {
  // Shake-by-drag: accumulate vertical distance, fire a shake every 30px.
  double _accumulated = 0;
  double _shakeAngle = 0;
  static const _shakeThreshold = 30.0;

  void _onPanUpdate(DragUpdateDetails details) {
    _accumulated += details.delta.dy.abs();
    // Tilt the shaker based on drag direction.
    setState(() => _shakeAngle = details.delta.dy > 0 ? 0.12 : -0.12);

    while (_accumulated >= _shakeThreshold) {
      _accumulated -= _shakeThreshold;
      HapticFeedback.mediumImpact();
      CookingAudioService.instance.playSfx('season', widget.countryId);
      widget.onTap();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _accumulated = 0;
    setState(() => _shakeAngle = 0);
  }

  @override
  Widget build(BuildContext context) {
    final required = widget.step.targetCount;
    final done = widget.interactionCount;

    return Semantics(
      button: true,
      label: 'Spice shaker. Tap or shake to add seasoning. $done of $required shakes done',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          CookingAudioService.instance.playSfx('season', widget.countryId);
          widget.onTap();
        },
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: widget.progress),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Glow behind shaker
                        Container(
                          width: 140 + value * 30,
                          height: 140 + value * 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: <Color>[
                                const Color(0xFFFF8C42).withValues(
                                  alpha: 0.2 + value * 0.3,
                                ),
                                const Color(0xFFFF8C42).withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                        // Shaker illustration with shake tilt
                        AnimatedRotation(
                          turns: _shakeAngle,
                          duration: const Duration(milliseconds: 80),
                          child: PropImage(
                            countryId: widget.countryId,
                            propName: 'spice_shaker',
                            fallbackEmoji: '\u{1F9C2}',
                            size: 140 + value * 20,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD166), width: 2),
              ),
              child: Text(
                '$done / $required shakes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D3142),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: widget.progress.clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF8C42),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Shake up & down or tap!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF264653).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
