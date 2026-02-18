import 'package:flutter/material.dart';

import '../models/ingredient.dart';

class IngredientWidget extends StatefulWidget {
  const IngredientWidget({
    super.key,
    required this.ingredient,
    required this.onTapToss,
  });

  final Ingredient ingredient;
  final VoidCallback onTapToss;

  @override
  State<IngredientWidget> createState() => _IngredientWidgetState();
}

class _IngredientWidgetState extends State<IngredientWidget> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        scale: _dragging ? 1.08 : 1,
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
