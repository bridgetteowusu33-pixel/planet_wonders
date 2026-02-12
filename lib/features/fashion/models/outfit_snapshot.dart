/// Immutable snapshot of a dressed character, passed to the Color Outfit screen.
class OutfitSnapshot {
  const OutfitSnapshot({
    required this.bodyAsset,
    required this.bodyShiftY,
    required this.bodyScale,
    this.layers = const [],
  });

  final String bodyAsset;
  final double bodyShiftY;
  final double bodyScale;
  final List<OutfitLayer> layers;
}

/// A single clothing layer to render on top of the body.
class OutfitLayer {
  const OutfitLayer({
    required this.assetPath,
    required this.shiftY,
    required this.scale,
  });

  final String assetPath;
  final double shiftY;
  final double scale;
}
