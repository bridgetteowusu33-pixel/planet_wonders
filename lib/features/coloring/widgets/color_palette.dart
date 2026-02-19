import 'package:flutter/material.dart';

import '../../../coloring/palette_bar.dart';

/// Backward-compatible wrapper for legacy usages.
///
/// Prefer using [PaletteBar] directly in new screens.
class ColorPalette extends StatelessWidget {
  const ColorPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaletteBar(height: 56);
  }
}
