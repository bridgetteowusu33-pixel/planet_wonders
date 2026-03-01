// File: lib/features/creative_studio/color_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../coloring/color_button.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
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
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFD8DC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Colors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (int i = 0; i < kDefaultCreativePalette.length; i++)
                      PaletteColorButton(
                        color: kDefaultCreativePalette[i],
                        selected: kDefaultCreativePalette[i].toARGB32() ==
                            state.currentColor.toARGB32(),
                        onTap: () =>
                            controller.selectColor(kDefaultCreativePalette[i]),
                        semanticLabel:
                            'Color ${i + 1}',
                      ),
                  ],
                ),
              ),
            ),
            if (state.recentColors.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Recently Used',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (int i = 0; i < state.recentColors.length; i++)
                    PaletteColorButton(
                      color: state.recentColors[i],
                      selected: state.recentColors[i].toARGB32() ==
                          state.currentColor.toARGB32(),
                      onTap: () =>
                          controller.selectColor(state.recentColors[i]),
                      semanticLabel: 'Recent color ${i + 1}',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
