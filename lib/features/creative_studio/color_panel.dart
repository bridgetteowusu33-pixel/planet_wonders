// File: lib/features/creative_studio/color_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/pw_theme.dart';
import 'creative_controller.dart';
import 'creative_state.dart';

class ColorPanel extends ConsumerWidget {
  const ColorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creativeControllerProvider);
    final controller = ref.read(creativeControllerProvider.notifier);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFD9E3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Text(
              'Color Palette',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ColorWrap(
              colors: kDefaultCreativePalette,
              selected: state.currentColor,
              onTap: controller.selectColor,
              onFavoriteToggle: controller.toggleFavoriteColor,
              favorites: state.favoriteColors,
            ),
            const SizedBox(height: 14),
            Text('Favorites', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _MiniStrip(
              colors: state.favoriteColors,
              emptyLabel: 'Tap the star on a color to save it here',
              onTap: controller.selectColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Recently Used',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _MiniStrip(
              colors: state.recentColors,
              emptyLabel: 'Your recent colors will appear here',
              onTap: controller.selectColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorWrap extends StatelessWidget {
  const _ColorWrap({
    required this.colors,
    required this.selected,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.favorites,
  });

  final List<Color> colors;
  final Color selected;
  final List<Color> favorites;
  final ValueChanged<Color> onTap;
  final ValueChanged<Color> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final color in colors)
          GestureDetector(
            onTap: () => onTap(color),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected == color ? PWColors.navy : Colors.white,
                      width: selected == color ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onFavoriteToggle(color),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: favorites.contains(color)
                            ? PWColors.yellow
                            : const Color(0xFFE5EAF0),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: favorites.contains(color)
                            ? const Color(0xFF7A5B00)
                            : const Color(0xFF7D8DA1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MiniStrip extends StatelessWidget {
  const _MiniStrip({
    required this.colors,
    required this.emptyLabel,
    required this.onTap,
  });

  final List<Color> colors;
  final String emptyLabel;
  final ValueChanged<Color> onTap;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) {
      return Text(
        emptyLabel,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF708499),
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final color in colors)
          GestureDetector(
            onTap: () => onTap(color),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
