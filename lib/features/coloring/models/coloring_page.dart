import 'dart:ui';

/// Signature for a function that paints a black-line outline onto the canvas.
/// These outlines sit ON TOP of the kid's brush strokes so the lines are
/// always visible — just like a real coloring book.
typedef OutlinePainter = void Function(Canvas canvas, Size size);

/// A single coloring page with either a programmatic or image-based outline.
///
/// Data-driven: add a [ColoringPage] to the registry and the UI picks it up.
/// Provide [paintOutline] for programmatic outlines (CustomPainter) or
/// [outlineAsset] for PNG image outlines. At least one must be set.
class ColoringPage {
  final String id;
  final String title;
  final String countryId;
  final String emoji; // thumbnail placeholder
  final OutlinePainter? paintOutline;
  final String? outlineAsset; // e.g. 'assets/coloring/ghana/kente.png'
  final String? maskAsset; // e.g. 'assets/coloring/usa/masks/usa_01_map_mask.png'
  final String? fact; // "Did You Know?" text
  final String? factCategory; // Culture, History, etc.

  const ColoringPage({
    required this.id,
    required this.title,
    required this.countryId,
    required this.emoji,
    this.paintOutline,
    this.outlineAsset,
    this.maskAsset,
    this.fact,
    this.factCategory,
  }) : assert(
         paintOutline != null || outlineAsset != null,
         'A ColoringPage must have either a paintOutline or an outlineAsset',
       );

  bool get hasFact => fact != null;
  bool get isImageBased => outlineAsset != null;
  bool get hasMask => maskAsset != null;
}
