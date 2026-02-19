import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable circular color button for the horizontal palette bar.
class PaletteColorButton extends StatefulWidget {
  const PaletteColorButton({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.semanticLabel,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  State<PaletteColorButton> createState() => _PaletteColorButtonState();
}

class _PaletteColorButtonState extends State<PaletteColorButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isWhite = widget.color.toARGB32() == 0xFFFFFFFF;
    final ringColor = widget.selected
        ? const Color(0xFF2F3A4A)
        : (isWhite ? const Color(0xFFB0BEC5) : Colors.white);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Semantics(
        label: widget.semanticLabel,
        button: true,
        selected: widget.selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: () async {
            await HapticFeedback.selectionClick();
            widget.onTap();
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOutBack,
            scale: _pressed ? 0.92 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                border: Border.all(
                  color: ringColor,
                  width: widget.selected ? 3.2 : 2.0,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                  if (widget.selected)
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.45),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
