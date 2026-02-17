import 'dart:ui';

/// Tools a kid can use on the canvas.
enum DrawingTool { marker, crayon, softBrush, fill, eraser }

/// Brush type enum for the three brush variants (Phase 2).
/// Currently only Marker is implemented; Crayon and SoftBrush are placeholders.
enum BrushType { marker, crayon, softBrush }

/// Kid-friendly size presets — no sliders, just tap.
enum BrushSize {
  small(3.0),
  medium(6.0),
  large(12.0);

  const BrushSize(this.width);
  final double width;

  /// Eraser is always 3× the brush width so it feels proportional.
  double get eraserWidth => width * 3;
}

/// Base class for all undoable/redoable drawing actions.
///
/// Sealed class ensures exhaustive pattern matching.
/// Each action type captures the minimal data needed to recreate it.
sealed class DrawingAction {
  const DrawingAction();
}

/// A completed stroke action (finger-down → finger-up).
class StrokeAction extends DrawingAction {
  const StrokeAction(this.stroke);
  final Stroke stroke;
}

/// A region fill action (tap on region).
/// Stores only the region ID and color, not a full image.
class RegionFillAction extends DrawingAction {
  const RegionFillAction({
    required this.regionId,
    required this.color,
  });

  final int regionId;
  final Color color;
}

/// A bitmap fill action produced by flood fill.
/// Stores a transparent image containing only the filled region.
class BitmapFillAction extends DrawingAction {
  const BitmapFillAction(this.image);
  final Image image;
}

/// A single continuous stroke (finger-down → finger-up).
class Stroke {
  const Stroke({
    required this.points,
    required this.color,
    required this.width,
    required this.brushType,
    required this.isEraser,
  });

  final List<Offset> points;
  final Color color;
  final double width;
  final BrushType brushType;
  final bool isEraser;

  /// Returns a copy with one more point appended (used while drawing).
  Stroke addPoint(Offset point) {
    return Stroke(
      points: [...points, point],
      color: color,
      width: width,
      brushType: brushType,
      isEraser: isEraser,
    );
  }
}

/// The full state of the drawing canvas at any moment.
///
/// Uses an action-based model for undo/redo:
/// - `actions` is the committed action list (undo stack)
/// - `redoStack` holds actions that were undone (cleared on new action)
/// - Rendering is derived from `actions` via `strokes`, `regionFills`,
///   and `fillImages`
class DrawingState {
  const DrawingState({
    this.actions = const [],
    this.redoStack = const [],
    this.activeStroke,
    this.currentTool = DrawingTool.marker,
    this.currentBrushType = BrushType.marker,
    this.currentColor = const Color(0xFF2F3A4A), // navy default
    this.currentBrushSize = BrushSize.medium,
    this.filling = false,
    this.precisionMode = false,
    this.paperTextureEnabled = true,
  });

  /// Committed actions (undo stack).
  /// Mix of StrokeAction and RegionFillAction in order.
  final List<DrawingAction> actions;

  /// Redo stack (actions that were undone).
  /// Cleared when a new action is committed.
  final List<DrawingAction> redoStack;

  /// The stroke currently being drawn (finger is down).
  /// Null when no active drawing.
  final Stroke? activeStroke;

  /// Current tool selection.
  final DrawingTool currentTool;

  /// Current brush type (for stroke drawing).
  final BrushType currentBrushType;

  /// Current color (for both strokes and fills).
  final Color currentColor;

  /// Current brush size.
  final BrushSize currentBrushSize;

  /// True while a flood fill is in progress (legacy, will be instant in Phase 1).
  final bool filling;

  /// When enabled, zoom/auto-zoom is more aggressive for small regions.
  final bool precisionMode;

  /// Optional subtle paper texture overlay.
  final bool paperTextureEnabled;

  /// Derived: all strokes in order (for rendering).
  List<Stroke> get strokes => actions
      .whereType<StrokeAction>()
      .map((a) => a.stroke)
      .toList();

  /// Derived: all region fills, latest wins per region (for rendering).
  /// Returns a map of regionId → color.
  Map<int, Color> get regionFills {
    final map = <int, Color>{};
    for (final action in actions) {
      if (action is RegionFillAction) {
        map[action.regionId] = action.color;
      }
    }
    return map;
  }

  /// Derived: flood-fill bitmap overlays in order.
  List<Image> get fillImages => actions
      .whereType<BitmapFillAction>()
      .map((a) => a.image)
      .toList();

  /// Convenience — the actual pixel width for the active tool.
  double get activeWidth => currentTool == DrawingTool.eraser
      ? currentBrushSize.eraserWidth
      : currentBrushSize.width;

  /// Can undo if there are committed actions.
  bool get canUndo => actions.isNotEmpty;

  /// Can redo if there are undone actions.
  bool get canRedo => redoStack.isNotEmpty;

  DrawingState copyWith({
    List<DrawingAction>? actions,
    List<DrawingAction>? redoStack,
    Stroke? activeStroke,
    bool clearActiveStroke = false,
    DrawingTool? currentTool,
    BrushType? currentBrushType,
    Color? currentColor,
    BrushSize? currentBrushSize,
    bool? filling,
    bool? precisionMode,
    bool? paperTextureEnabled,
  }) {
    return DrawingState(
      actions: actions ?? this.actions,
      redoStack: redoStack ?? this.redoStack,
      activeStroke:
          clearActiveStroke ? null : (activeStroke ?? this.activeStroke),
      currentTool: currentTool ?? this.currentTool,
      currentBrushType: currentBrushType ?? this.currentBrushType,
      currentColor: currentColor ?? this.currentColor,
      currentBrushSize: currentBrushSize ?? this.currentBrushSize,
      filling: filling ?? this.filling,
      precisionMode: precisionMode ?? this.precisionMode,
      paperTextureEnabled: paperTextureEnabled ?? this.paperTextureEnabled,
    );
  }
}
