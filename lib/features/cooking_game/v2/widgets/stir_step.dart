import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/cooking_audio_service.dart';
import '../models/pot_face_state.dart';
import '../models/v2_recipe_step.dart';
import 'illustrated_pot.dart';

class StirStep extends StatefulWidget {
  const StirStep({
    super.key,
    required this.step,
    required this.progress,
    required this.onProgressDelta,
    this.countryId = 'ghana',
  });

  final V2RecipeStep step;
  final double progress;
  final void Function(double delta) onProgressDelta;
  final String countryId;

  @override
  State<StirStep> createState() => _StirStepState();
}

class _StirStepState extends State<StirStep> {
  Offset? _lastPoint;

  void _onPanStart(DragStartDetails details) {
    _lastPoint = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final previous = _lastPoint;
    if (previous == null) {
      _lastPoint = details.localPosition;
      return;
    }

    final current = details.localPosition;
    // Calculate angular change around center.
    final center = Offset(
      context.size?.width ?? 200 / 2,
      context.size?.height ?? 200 / 2,
    );
    final prevAngle = math.atan2(
      previous.dy - center.dy,
      previous.dx - center.dx,
    );
    final currAngle = math.atan2(
      current.dy - center.dy,
      current.dx - center.dx,
    );
    var delta = currAngle - prevAngle;
    // Normalize to [-pi, pi]
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;

    // Convert to progress (full circle = ~6.28 radians → ~0.70 per full turn).
    final progressDelta = delta.abs() / (2 * math.pi) * 0.70;
    if (progressDelta > 0.001) {
      widget.onProgressDelta(progressDelta);
      HapticFeedback.selectionClick();
      CookingAudioService.instance.playSfx('stir', widget.countryId);
    }

    _lastPoint = current;
  }

  void _onPanEnd(DragEndDetails details) {
    _lastPoint = null;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Stir the pot. Draw circles with your finger. ${(widget.progress * 100).round()} percent done',
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        behavior: HitTestBehavior.opaque,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Progress ring
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: widget.progress.clamp(0, 1),
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.4),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFB703),
                        ),
                      ),
                    ),
                    // Illustrated pot
                    IllustratedPot(
                      countryId: widget.countryId,
                      faceState: PotFaceState.stir,
                      size: 160,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(widget.progress * 100).round()}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stir in circles!',
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
