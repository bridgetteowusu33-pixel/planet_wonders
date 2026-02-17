// File: lib/features/creative_studio/widgets/toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../creative_controller.dart';
import '../creative_state.dart';

class CreativeToolbar extends ConsumerWidget {
  const CreativeToolbar({
    super.key,
    required this.onOpenColors,
    required this.onOpenStickers,
    required this.onOpenBackgrounds,
    required this.onReset,
  });

  final VoidCallback onOpenColors;
  final VoidCallback onOpenStickers;
  final VoidCallback onOpenBackgrounds;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creativeControllerProvider);
    final controller = ref.read(creativeControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          _ToolChip(
            icon: Icons.brush_rounded,
            label: 'Brush',
            active: state.tool == CreativeTool.brush,
            onTap: () => controller.setTool(CreativeTool.brush),
          ),
          _ToolChip(
            icon: Icons.auto_fix_high_rounded,
            label: 'Eraser',
            active: state.tool == CreativeTool.eraser,
            onTap: () => controller.setTool(CreativeTool.eraser),
          ),
          _ToolChip(
            icon: Icons.format_color_fill_rounded,
            label: 'Fill',
            active: state.tool == CreativeTool.fill,
            onTap: () => controller.setTool(CreativeTool.fill),
          ),
          _ToolChip(
            icon: Icons.palette_rounded,
            label: 'Colors',
            active: false,
            onTap: onOpenColors,
          ),
          _ToolChip(
            icon: Icons.emoji_emotions_rounded,
            label: 'Stickers',
            active: false,
            onTap: onOpenStickers,
          ),
          _ToolChip(
            icon: Icons.landscape_rounded,
            label: 'Backgrounds',
            active: false,
            onTap: onOpenBackgrounds,
          ),
          _ToolChip(
            icon: Icons.undo_rounded,
            label: 'Undo',
            active: false,
            enabled: state.canUndo,
            onTap: controller.undo,
          ),
          _ToolChip(
            icon: Icons.redo_rounded,
            label: 'Redo',
            active: false,
            enabled: state.canRedo,
            onTap: controller.redo,
          ),
          _ToolChip(
            icon: Icons.restart_alt_rounded,
            label: 'Reset',
            active: false,
            onTap: onReset,
          ),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: active ? PWColors.blue : const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 72,
            height: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: active ? Colors.white : PWColors.navy,
                  size: 24,
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: active ? Colors.white : PWColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
