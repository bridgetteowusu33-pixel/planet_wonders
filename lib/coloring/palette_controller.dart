import 'dart:collection';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/coloring/providers/drawing_provider.dart';

/// Single source of truth for palette colors + color selection actions.
///
/// Active color remains in [drawingProvider] so brush/fill behavior stays
/// unified across coloring and drawing screens.
final paletteControllerProvider =
    NotifierProvider.autoDispose<PaletteController, PaletteState>(
      PaletteController.new,
    );

final activePaletteColorProvider = Provider.autoDispose<Color>(
  (ref) => ref.watch(drawingProvider.select((s) => s.currentColor)),
);

class PaletteState {
  const PaletteState({required this.colors});

  final UnmodifiableListView<Color> colors;
}

class PaletteController extends Notifier<PaletteState> {
  // Expanded default bar:
  // primaries, secondaries, pastels, skin tones, browns, dark shades.
  static const List<Color> _defaultColors = <Color>[
    Color(0xFFE53935), // red
    Color(0xFFEF5350), // light red
    Color(0xFFFB8C00), // orange
    Color(0xFFFFA726), // amber orange
    Color(0xFFFDD835), // yellow
    Color(0xFFFFF176), // soft yellow
    Color(0xFF43A047), // green
    Color(0xFF66BB6A), // light green
    Color(0xFF9CCC65), // lime green
    Color(0xFF00ACC1), // cyan
    Color(0xFF26C6DA), // aqua
    Color(0xFF1E88E5), // blue
    Color(0xFF42A5F5), // sky blue
    Color(0xFF5C6BC0), // indigo blue
    Color(0xFF5E35B1), // violet
    Color(0xFF7E57C2), // lavender violet
    Color(0xFFD81B60), // pink
    Color(0xFFEC407A), // bright pink
    Color(0xFFF06292), // soft pink
    Color(0xFFFF8A80), // pastel coral
    Color(0xFFFFAB91), // pastel salmon
    Color(0xFFFFCC80), // pastel peach
    Color(0xFFFFE0B2), // pastel apricot
    Color(0xFFFFF59D), // pastel lemon
    Color(0xFFA5D6A7), // pastel mint
    Color(0xFFB3E5FC), // pastel sky
    Color(0xFFCE93D8), // pastel lilac
    Color(0xFFEED9C4), // skin very light
    Color(0xFFE0BFA3), // skin light beige
    Color(0xFFD7A97B), // skin warm tan
    Color(0xFFC68642), // skin tan
    Color(0xFFB57A4A), // skin medium brown
    Color(0xFFA56B46), // skin warm brown
    Color(0xFF8D5524), // skin deep brown
    Color(0xFF6F4627), // skin rich brown
    Color(0xFF5D4037), // chocolate brown
    Color(0xFF8D6E63), // mocha
    Color(0xFFA1887F), // taupe
    Color(0xFFD7CCC8), // warm gray beige
    Color(0xFF3E2723), // dark brown
    Color(0xFF263238), // blue black
    Color(0xFF455A64), // blue gray
    Color(0xFF2F3A4A), // navy
    Color(0xFF424242), // charcoal
    Color(0xFF757575), // medium gray
    Color(0xFFBDBDBD), // light gray
    Color(0xFFFFFFFF), // white
    Color(0xFF000000), // black
  ];

  static final UnmodifiableListView<Color> _memoizedPalette =
      UnmodifiableListView<Color>(_defaultColors);

  @override
  PaletteState build() {
    return PaletteState(colors: _memoizedPalette);
  }

  void selectColor(Color color) {
    ref.read(drawingProvider.notifier).setColor(color);
  }
}
