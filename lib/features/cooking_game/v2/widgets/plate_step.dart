import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/cooking_audio_service.dart';
import '../models/pot_face_state.dart';
import '../models/v2_recipe_step.dart';
import 'illustrated_pot.dart';
import 'prop_image.dart';

class PlateStep extends StatelessWidget {
  const PlateStep({
    super.key,
    required this.step,
    required this.progress,
    required this.interactionCount,
    required this.onScoop,
    this.countryId = 'ghana',
  });

  final V2RecipeStep step;
  final double progress;
  final int interactionCount;
  final VoidCallback onScoop;
  final String countryId;

  @override
  Widget build(BuildContext context) {
    final required = step.targetCount;
    final done = interactionCount;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Pot (source) — draggable + tappable
                _PotSource(
                  countryId: countryId,
                  onScoop: () {
                    HapticFeedback.lightImpact();
                    CookingAudioService.instance.playSfx('plate', countryId);
                    onScoop();
                  },
                ),
                // Arrow
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 36,
                    color: Color(0xFFFFB74D),
                  ),
                ),
                // Plate (target) — accepts drag scoops
                DragTarget<String>(
                  onWillAcceptWithDetails: (_) => true,
                  onAcceptWithDetails: (_) {
                    HapticFeedback.mediumImpact();
                    CookingAudioService.instance.playSfx('plate', countryId);
                    onScoop();
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    return AnimatedScale(
                      scale: isHovering ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: _PlateTarget(
                        scoops: done,
                        required: required,
                        countryId: countryId,
                        highlighted: isHovering,
                      ),
                    );
                  },
                ),
              ],
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
            '$done / $required scoops',
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
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF74C69D),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Drag from pot to plate, or tap!',
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

class _PotSource extends StatelessWidget {
  const _PotSource({required this.onScoop, required this.countryId});

  final VoidCallback onScoop;
  final String countryId;

  @override
  Widget build(BuildContext context) {
    final potWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IllustratedPot(
          countryId: countryId,
          faceState: PotFaceState.love,
          size: 140,
        ),
        const SizedBox(height: 4),
        PropImage(
          countryId: countryId,
          propName: 'spoon',
          fallbackEmoji: '\u{1F944}',
          size: 72,
        ),
      ],
    );

    return Semantics(
      button: true,
      label: 'Pot. Drag to plate or tap to scoop food',
      child: Draggable<String>(
        data: 'scoop',
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.8,
            child: PropImage(
              countryId: countryId,
              propName: 'spoon',
              fallbackEmoji: '\u{1F944}',
              size: 95,
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: potWidget),
        onDragStarted: () => HapticFeedback.lightImpact(),
        child: GestureDetector(
          onTap: onScoop,
          child: potWidget,
        ),
      ),
    );
  }
}

class _PlateTarget extends StatelessWidget {
  const _PlateTarget({
    required this.scoops,
    required this.required,
    required this.countryId,
    this.highlighted = false,
  });

  final int scoops;
  final int required;
  final String countryId;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final fillFraction = (scoops / required).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Opacity(
          opacity: 0.3 + fillFraction * 0.7,
          child: Image.asset(
            'assets/cooking/v2/$countryId/props/plate.webp',
            width: 200,
            height: 200,
            cacheWidth: 400,
            errorBuilder: (_, _, _) => Text(
              '\u{1F37D}',
              style: TextStyle(
                fontSize: 60,
                color: Colors.black.withValues(
                  alpha: 0.3 + fillFraction * 0.7,
                ),
              ),
            ),
          ),
        ),
        if (scoops > 0)
          Text(
            List.filled(scoops.clamp(0, 5), '\u{2B50}').join(),
            style: const TextStyle(fontSize: 14),
          ),
      ],
    );
  }
}
