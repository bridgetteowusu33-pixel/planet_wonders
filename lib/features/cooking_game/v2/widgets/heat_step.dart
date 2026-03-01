import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/cooking_audio_service.dart';
import '../models/step_type.dart';
import '../models/v2_recipe_step.dart';
import 'prop_image.dart';

class HeatStep extends StatefulWidget {
  const HeatStep({
    super.key,
    required this.step,
    required this.progress,
    required this.onProgressDelta,
    required this.onMistake,
    this.countryId = 'ghana',
  });

  final V2RecipeStep step;
  final double progress;
  final void Function(double delta) onProgressDelta;
  final VoidCallback onMistake;
  final String countryId;

  @override
  State<HeatStep> createState() => _HeatStepState();
}

class _HeatStepState extends State<HeatStep> {
  bool _holding = false;
  Timer? _heatTimer;

  static const _greenZoneStart = 0.7;
  static const _greenZoneEnd = 0.9;
  static const _overshoot = 0.95;

  void _startHolding() {
    if (_holding) return;
    setState(() => _holding = true);
    HapticFeedback.lightImpact();
    CookingAudioService.instance.playSfx('sizzle', widget.countryId);
    _heatTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!_holding) return;
      // Each tick adds a small amount.
      widget.onProgressDelta(0.02);
      if (widget.progress >= _overshoot) {
        _stopHolding();
        widget.onMistake();
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _stopHolding() {
    if (!_holding) return;
    _heatTimer?.cancel();
    _heatTimer = null;
    setState(() => _holding = false);

    // If released in the green zone, auto-complete step.
    if (widget.progress >= _greenZoneStart &&
        widget.progress <= _greenZoneEnd) {
      // Fill to 1.0 to trigger completion.
      widget.onProgressDelta(1.0 - widget.progress);
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _heatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress.clamp(0.0, 1.0);
    final inGreenZone =
        progress >= _greenZoneStart && progress <= _greenZoneEnd;
    final overheated = progress >= _overshoot;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 16),
        // Thermometer
        Expanded(
          child: Center(
            child: SizedBox(
              width: 80,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  final fillColor = overheated
                      ? const Color(0xFFEF5350)
                      : inGreenZone
                          ? const Color(0xFF66BB6A)
                          : const Color(0xFFFFB74D);
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      // Track background
                      Container(
                        width: 40,
                        height: h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: <double>[0.0, 0.7, 0.9, 1.0],
                            colors: <Color>[
                              Color(0xFFE0E0E0),
                              Color(0xFFFFE082),
                              Color(0xFF66BB6A),
                              Color(0xFFEF5350),
                            ],
                          ),
                        ),
                      ),
                      // Fill level
                      Container(
                        width: 40,
                        height: h * progress,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: fillColor,
                        ),
                      ),
                      // Green zone marker
                      Positioned(
                        bottom: h * _greenZoneStart,
                        left: 20,
                        right: 20,
                        height: h * (_greenZoneEnd - _greenZoneStart),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF388E3C),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Hold button
        Semantics(
          button: true,
          label: _holding
              ? '${widget.step.type.heatLabel[0].toUpperCase()}${widget.step.type.heatLabel.substring(1)}ing. Release in the green zone. ${(widget.progress * 100).round()} percent'
              : 'Hold to ${widget.step.type.heatLabel} the pot',
          child: GestureDetector(
            onTapDown: (_) => _startHolding(),
            onTapUp: (_) => _stopHolding(),
            onTapCancel: _stopHolding,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _holding ? 110 : 100,
              height: _holding ? 110 : 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _holding
                      ? const <Color>[Color(0xFFFF7043), Color(0xFFFF5722)]
                      : const <Color>[Color(0xFFFFB74D), Color(0xFFFFA726)],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _holding
                        ? const Color(0x55FF5722)
                        : const Color(0x33FFB74D),
                    blurRadius: _holding ? 24 : 12,
                    spreadRadius: _holding ? 4 : 1,
                  ),
                ],
              ),
              child: Center(
                child: PropImage(
                  countryId: widget.countryId,
                  propName: widget.step.type == V2StepType.fry
                      ? 'frying_pan'
                      : 'fire',
                  fallbackEmoji: widget.step.type.heatEmoji,
                  size: _holding ? 48 : 40,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _holding
              ? 'Release in the green zone!'
              : 'Hold to ${widget.step.type.heatLabel}!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF264653).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
