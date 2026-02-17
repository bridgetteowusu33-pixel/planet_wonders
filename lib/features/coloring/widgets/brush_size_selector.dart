import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/drawing_state.dart';
import '../providers/drawing_provider.dart';

/// Three dot-sized buttons (S / M / L) — kid taps one to change brush width.
class BrushSizeSelector extends ConsumerWidget {
  const BrushSizeSelector({super.key});

  static const _dotSizes = {
    BrushSize.small: 10.0,
    BrushSize.medium: 16.0,
    BrushSize.large: 24.0,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSize =
        ref.watch(drawingProvider.select((s) => s.currentBrushSize));

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: BrushSize.values.map((size) {
        final isActive = currentSize == size;
        final dotDiameter = _dotSizes[size]!;

        return GestureDetector(
          onTap: () => ref.read(drawingProvider.notifier).setBrushSize(size),
          // Fixed outer box keeps spacing even between different dot sizes.
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? PWColors.blue
                    : PWColors.navy.withValues(alpha: 0.12),
                width: isActive ? 2 : 1,
              ),
              color: isActive
                  ? PWColors.blue.withValues(alpha: 0.08)
                  : Colors.white,
            ),
            child: Center(
              child: Container(
                width: dotDiameter,
                height: dotDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? PWColors.blue : PWColors.navy,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
