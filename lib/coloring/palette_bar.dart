import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'color_button.dart';
import 'palette_controller.dart';

/// Fixed-height, single-row horizontal palette bar.
///
/// Keeps the canvas visible by never expanding vertically.
class PaletteBar extends ConsumerWidget {
  const PaletteBar({super.key, this.height = 56, this.showMoreButton = true});

  final double height;
  final bool showMoreButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(
      paletteControllerProvider.select((s) => s.colors),
    );
    final activeColor = ref.watch(activePaletteColorProvider);
    final controller = ref.read(paletteControllerProvider.notifier);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: palette.length + (showMoreButton ? 1 : 0),
        separatorBuilder: (_, index) => const SizedBox(width: 2),
        itemBuilder: (context, index) {
          if (showMoreButton && index == palette.length) {
            return _MoreColorsButton(
              onTap: () => _showFullPaletteSheet(
                context: context,
                colors: palette,
                activeColor: activeColor,
                onColorPicked: (color) => controller.selectColor(color),
              ),
            );
          }

          final color = palette[index];
          final isSelected = color.toARGB32() == activeColor.toARGB32();
          return PaletteColorButton(
            color: color,
            selected: isSelected,
            onTap: () => controller.selectColor(color),
            semanticLabel: 'Color ${index + 1} ${_hexLabel(color)}',
          );
        },
      ),
    );
  }

  Future<void> _showFullPaletteSheet({
    required BuildContext context,
    required List<Color> colors,
    required Color activeColor,
    required ValueChanged<Color> onColorPicked,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFD8DC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'More Colors',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (int i = 0; i < colors.length; i++)
                      PaletteColorButton(
                        color: colors[i],
                        selected:
                            colors[i].toARGB32() == activeColor.toARGB32(),
                        onTap: () {
                          onColorPicked(colors[i]);
                          Navigator.of(context).pop();
                        },
                        semanticLabel:
                            'More color ${i + 1} ${_hexLabel(colors[i])}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoreColorsButton extends StatelessWidget {
  const _MoreColorsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Semantics(
        button: true,
        label: 'More colors',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCFD8DC), width: 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 22,
              color: Color(0xFF37474F),
            ),
          ),
        ),
      ),
    );
  }
}

String _hexLabel(Color color) {
  final hex = color.toARGB32().toRadixString(16).padLeft(8, '0');
  return '#${hex.substring(2).toUpperCase()}';
}
