import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/cooking_audio_service.dart';
import '../models/pot_face_state.dart';
import '../models/v2_recipe.dart';
import '../models/v2_recipe_step.dart';
import 'illustrated_pot.dart';
import 'ingredient_image.dart';

class AddIngredientsStep extends StatelessWidget {
  const AddIngredientsStep({
    super.key,
    required this.step,
    required this.progress,
    required this.ingredients,
    required this.addedIds,
    required this.onIngredientAdded,
    this.countryId = 'ghana',
  });

  final V2RecipeStep step;
  final double progress;
  final List<V2Ingredient> ingredients;
  final Set<String> addedIds;
  final void Function(String ingredientId) onIngredientAdded;
  final String countryId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Pot target area — accepts dragged ingredients
        Expanded(
          flex: 3,
          child: Center(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (details) =>
                  !addedIds.contains(details.data),
              onAcceptWithDetails: (details) {
                HapticFeedback.mediumImpact();
                CookingAudioService.instance.playSfx('drop', countryId);
                onIngredientAdded(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;
                return AnimatedScale(
                  scale: isHovering ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: IllustratedPot(
                    countryId: countryId,
                    size: 200,
                    faceState: isHovering
                        ? PotFaceState.happy
                        : PotFaceState.idle,
                    progress: progress,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Ingredient chips — draggable + tappable
        Expanded(
          flex: 2,
          child: _IngredientTray(
            ingredients: ingredients,
            addedIds: addedIds,
            onIngredientAdded: onIngredientAdded,
          ),
        ),
      ],
    );
  }
}


class _IngredientTray extends StatelessWidget {
  const _IngredientTray({
    required this.ingredients,
    required this.addedIds,
    required this.onIngredientAdded,
  });

  final List<V2Ingredient> ingredients;
  final Set<String> addedIds;
  final void Function(String ingredientId) onIngredientAdded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFF3C4), Color(0xFFFFE8A3)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD166), width: 2),
      ),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: ingredients.asMap().entries.map((entry) {
            final ingredient = entry.value;
            final isAdded = addedIds.contains(ingredient.id);
            return _IngredientChip(
              ingredient: ingredient,
              isAdded: isAdded,
              wiggleIndex: entry.key,
              onTap: () {
                if (!isAdded) {
                  HapticFeedback.lightImpact();
                  onIngredientAdded(ingredient.id);
                }
              },
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class _IngredientChip extends StatefulWidget {
  const _IngredientChip({
    required this.ingredient,
    required this.isAdded,
    required this.wiggleIndex,
    required this.onTap,
  });

  final V2Ingredient ingredient;
  final bool isAdded;
  final int wiggleIndex;
  final VoidCallback onTap;

  @override
  State<_IngredientChip> createState() => _IngredientChipState();
}

class _IngredientChipState extends State<_IngredientChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wiggle;

  @override
  void initState() {
    super.initState();
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Skip wiggle when reduce-motion is active.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) return;
      Future<void>.delayed(
        Duration(milliseconds: 180 * (widget.wiggleIndex % 5)),
        () {
          if (mounted) _wiggle.repeat(reverse: true);
        },
      );
    });
  }

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wiggle,
      builder: (context, child) {
        final angle = math.sin(_wiggle.value * math.pi) * 0.035;
        return Transform.rotate(angle: angle, child: child);
      },
      child: Semantics(
        button: true,
        enabled: !widget.isAdded,
        label: widget.isAdded
            ? '${widget.ingredient.name}, added'
            : 'Drag or tap ${widget.ingredient.name} to add to pot',
        child: _buildChipContent(),
      ),
    );
  }

  Widget _buildChipContent() {
    final chipWidget = AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: widget.isAdded ? 0.3 : 1,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: widget.isAdded ? 0.7 : 1,
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFFFF6D6), Color(0xFFFFE8A3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IngredientImage(
                ingredient: widget.ingredient,
                size: 50,
              ),
              const SizedBox(height: 2),
              Text(
                widget.ingredient.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.isAdded) return chipWidget;

    return Draggable<String>(
      data: widget.ingredient.id,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.15,
          child: Opacity(
            opacity: 0.9,
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFFFF6D6), Color(0xFFFFE8A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IngredientImage(
                    ingredient: widget.ingredient,
                    size: 36,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.ingredient.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: chipWidget),
      onDragStarted: () => HapticFeedback.lightImpact(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: chipWidget,
      ),
    );
  }
}
