import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/ingredient.dart';

class IngredientWidget extends StatefulWidget {
  const IngredientWidget({
    super.key,
    required this.ingredient,
    required this.onTapToss,
    this.isAdded = false,
    this.wiggleIndex = 0,
  });

  final Ingredient ingredient;
  final VoidCallback onTapToss;
  final bool isAdded;
  final int wiggleIndex;

  @override
  State<IngredientWidget> createState() => _IngredientWidgetState();
}

class _IngredientWidgetState extends State<IngredientWidget>
    with SingleTickerProviderStateMixin {
  bool _dragging = false;
  late final AnimationController _wiggle;

  @override
  void initState() {
    super.initState();
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Stagger the start so cards don't all wiggle in sync.
    Future<void>.delayed(
      Duration(milliseconds: 180 * (widget.wiggleIndex % 5)),
      () {
        if (mounted) _wiggle.repeat(reverse: true);
      },
    );
  }

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _wiggle,
        builder: (context, child) {
          // Subtle ±2° rotation wiggle.
          final angle = math.sin(_wiggle.value * math.pi) * 0.035;
          return Transform.rotate(angle: angle, child: child);
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          scale: _dragging ? 1.08 : 1,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: widget.isAdded ? 0.3 : 1,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              scale: widget.isAdded ? 0.7 : 1,
              child: Draggable<Ingredient>(
                data: widget.ingredient,
                onDragStarted: () => setState(() => _dragging = true),
                onDragEnd: (_) => setState(() => _dragging = false),
                feedback: _chip(widget.ingredient, scale: 1.12),
                childWhenDragging: Opacity(
                  opacity: 0.22,
                  child: _chip(widget.ingredient),
                ),
                child: GestureDetector(
                  onTap: widget.onTapToss,
                  child: _chip(widget.ingredient),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(Ingredient ingredient, {double scale = 1}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 114,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFFFF6D6), Color(0xFFFFE8A3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 52,
              height: 52,
              child: Image.asset(
                ingredient.assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.shopping_basket_rounded,
                    size: 36,
                    color: Color(0xFF9D4EDD),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ingredient.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
