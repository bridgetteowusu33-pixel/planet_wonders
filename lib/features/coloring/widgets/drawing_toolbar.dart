import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/drawing_state.dart';
import '../providers/drawing_provider.dart';

/// Compact icon-only toolbar: Brush, Fill, Eraser, Undo.
///
/// Set [showFill] to `false` to hide the Fill button (e.g. on transparent
/// canvases where flood-fill doesn't work).
class DrawingToolbar extends ConsumerWidget {
  const DrawingToolbar({super.key, this.showFill = true});

  final bool showFill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTool =
        ref.watch(drawingProvider.select((s) => s.currentTool));
    final canUndo = ref.watch(drawingProvider.select((s) => s.canUndo));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ToolButton(
          icon: Icons.brush_rounded,
          label: 'Brush',
          isActive: currentTool == DrawingTool.brush,
          onTap: () =>
              ref.read(drawingProvider.notifier).setTool(DrawingTool.brush),
        ),
        if (showFill) ...[
          const SizedBox(width: 16),
          _ToolButton(
            icon: Icons.format_color_fill_rounded,
            label: 'Fill',
            isActive: currentTool == DrawingTool.fill,
            onTap: () =>
                ref.read(drawingProvider.notifier).setTool(DrawingTool.fill),
          ),
        ],
        const SizedBox(width: 16),
        _ToolButton(
          icon: Icons.auto_fix_high_rounded,
          label: 'Eraser',
          isActive: currentTool == DrawingTool.eraser,
          onTap: () =>
              ref.read(drawingProvider.notifier).setTool(DrawingTool.eraser),
        ),
        const SizedBox(width: 16),
        _ToolButton(
          icon: Icons.undo_rounded,
          label: 'Undo',
          isActive: false,
          enabled: canUndo,
          onTap: () => ref.read(drawingProvider.notifier).undo(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.enabled = true,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabledOpacity = enabled ? 1.0 : 0.3;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: disabledOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive ? PWColors.blue : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? PWColors.blue : PWColors.navy.withValues(alpha: 0.15),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : PWColors.navy,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? PWColors.blue : PWColors.navy.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
