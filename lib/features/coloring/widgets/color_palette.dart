import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../providers/drawing_provider.dart';

/// 8 primary color circles + a "More" toggle revealing 8 extra colors.
///
/// Tapping a color switches the active color AND sets tool back to brush.
class ColorPalette extends ConsumerStatefulWidget {
  const ColorPalette({super.key});

  @override
  ConsumerState<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends ConsumerState<ColorPalette> {
  bool _showMore = false;

  /// Primary 8 colors — vibrant, kid-friendly.
  static const _primaryColors = [
    Color(0xFFFF4444), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFFFFD84D), // Yellow
    Color(0xFF4CAF50), // Green
    Color(0xFF6EC6E9), // Sky blue
    Color(0xFF2196F3), // Blue
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF69B4), // Pink
  ];

  /// Extra 8 colors revealed by "More".
  static const _extraColors = [
    Color(0xFF2F3A4A), // Navy
    Color(0xFF795548), // Brown
    Color(0xFF7ED6B2), // Mint
    Color(0xFFFF7A7A), // Coral
    Color(0xFFFFFFFF), // White
    Color(0xFF607D8B), // Gray
    Color(0xFFFF5722), // Deep orange
    Color(0xFF00BCD4), // Teal
  ];

  @override
  Widget build(BuildContext context) {
    final currentColor =
        ref.watch(drawingProvider.select((s) => s.currentColor));

    final visibleColors = [
      ..._primaryColors,
      if (_showMore) ..._extraColors,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            ...visibleColors.map((color) {
              final isSelected =
                  currentColor.toARGB32() == color.toARGB32();
              final isWhite = color.toARGB32() == 0xFFFFFFFF;
              return GestureDetector(
                onTap: () =>
                    ref.read(drawingProvider.notifier).setColor(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? PWColors.navy
                          : isWhite
                              ? PWColors.navy.withValues(alpha: 0.2)
                              : Colors.transparent,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.45),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
            // "More" / "Less" toggle
            GestureDetector(
              onTap: () => setState(() => _showMore = !_showMore),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PWColors.navy.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  _showMore
                      ? Icons.remove_rounded
                      : Icons.add_rounded,
                  color: PWColors.navy,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
