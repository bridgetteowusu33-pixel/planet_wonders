// File: lib/features/creative_studio/widgets/toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../../coloring/models/drawing_state.dart' show BrushType;
import '../creative_controller.dart';
import '../creative_state.dart';

/// Compact drawing toolbar matching coloring pages style (48x48 buttons).
class CreativeToolbar extends ConsumerWidget {
  const CreativeToolbar({
    super.key,
    this.onResetRequested,
  });

  final VoidCallback? onResetRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creativeControllerProvider);
    final controller = ref.read(creativeControllerProvider.notifier);

    final buttons = <Widget>[
      _ToolButton(
        icon: Icons.brush_rounded,
        label: 'Brush',
        isActive: state.tool == CreativeTool.brush,
        onTap: () => controller.setTool(CreativeTool.brush),
      ),
      _ToolButton(
        icon: Icons.format_color_fill_rounded,
        label: 'Fill',
        isActive: state.tool == CreativeTool.fill,
        onTap: () => controller.setTool(CreativeTool.fill),
      ),
      _ToolButton(
        icon: Icons.auto_fix_high_rounded,
        label: 'Eraser',
        isActive: state.tool == CreativeTool.eraser,
        onTap: () => controller.setTool(CreativeTool.eraser),
      ),
      _ToolButton(
        icon: Icons.undo_rounded,
        label: 'Undo',
        isActive: false,
        enabled: state.canUndo,
        onTap: controller.undo,
      ),
      _ToolButton(
        icon: Icons.redo_rounded,
        label: 'Redo',
        isActive: false,
        enabled: state.canRedo,
        onTap: controller.redo,
      ),
      if (onResetRequested != null)
        _ToolButton(
          icon: Icons.restart_alt_rounded,
          label: 'Reset',
          isActive: false,
          onTap: onResetRequested!,
        ),
    ];

    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: buttons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => buttons[index],
      ),
    );
  }
}

/// Brush size selector matching coloring pages (S / M / L dots).
class CreativeBrushSizeSelector extends ConsumerWidget {
  const CreativeBrushSizeSelector({super.key});

  static const _sizes = <(String, double, double)>[
    ('S', 4, 10),
    ('M', 12, 16),
    ('L', 24, 24),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSize = ref.watch(
      creativeControllerProvider.select((s) => s.brushSize),
    );
    final controller = ref.read(creativeControllerProvider.notifier);

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _sizes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final (_, size, dotDiameter) = _sizes[index];
          final isActive = (currentSize - size).abs() < 2;

          return GestureDetector(
            onTap: () => controller.setBrushSize(size),
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
        },
      ),
    );
  }
}

/// Brush type selector matching coloring pages (Marker / Crayon / Soft chips).
class CreativeBrushTypeSelector extends ConsumerWidget {
  const CreativeBrushTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(
      creativeControllerProvider.select((s) => s.brushType),
    );
    final controller = ref.read(creativeControllerProvider.notifier);

    final chips = <Widget>[
      _BrushChip(
        label: 'Marker',
        active: current == BrushType.marker,
        onTap: () => controller.setBrushType(BrushType.marker),
      ),
      _BrushChip(
        label: 'Crayon',
        active: current == BrushType.crayon,
        onTap: () => controller.setBrushType(BrushType.crayon),
      ),
      _BrushChip(
        label: 'Soft',
        active: current == BrushType.softBrush,
        onTap: () => controller.setBrushType(BrushType.softBrush),
      ),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) => chips[index],
      ),
    );
  }
}

class _BrushChip extends StatelessWidget {
  const _BrushChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? PWColors.blue.withValues(alpha: 0.18) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? PWColors.blue : PWColors.navy.withValues(alpha: 0.14),
            width: active ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? PWColors.blue : PWColors.navy,
          ),
        ),
      ),
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
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.3,
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
                  color: isActive
                      ? PWColors.blue
                      : PWColors.navy.withValues(alpha: 0.15),
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
                color: isActive
                    ? PWColors.blue
                    : PWColors.navy.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
