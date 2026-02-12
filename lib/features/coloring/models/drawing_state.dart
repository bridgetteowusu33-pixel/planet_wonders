import 'dart:ui';

/// Tools a kid can use on the canvas.
enum DrawingTool { brush, fill, eraser }

/// Tracks whether the last action was a stroke or a fill (for ordered undo).
enum ActionType { stroke, fill }

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

/// A single continuous stroke (finger-down → finger-up).
class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final DrawingTool tool;

  const Stroke({
    required this.points,
    required this.color,
    required this.width,
    required this.tool,
  });

  bool get isEraser => tool == DrawingTool.eraser;

  /// Returns a copy with one more point appended (used while drawing).
  Stroke addPoint(Offset point) {
    return Stroke(
      points: [...points, point],
      color: color,
      width: width,
      tool: tool,
    );
  }
}

/// The full state of the drawing canvas at any moment.
class DrawingState {
  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final List<Image> fillImages;
  final List<ActionType> actionHistory;
  final DrawingTool currentTool;
  final Color currentColor;
  final BrushSize currentBrushSize;
  final bool filling; // true while a flood fill is in progress

  const DrawingState({
    this.strokes = const [],
    this.activeStroke,
    this.fillImages = const [],
    this.actionHistory = const [],
    this.currentTool = DrawingTool.brush,
    this.currentColor = const Color(0xFF2F3A4A), // navy default
    this.currentBrushSize = BrushSize.medium,
    this.filling = false,
  });

  /// Convenience — the actual pixel width for the active tool.
  double get activeWidth => currentTool == DrawingTool.eraser
      ? currentBrushSize.eraserWidth
      : currentBrushSize.width;

  bool get canUndo => actionHistory.isNotEmpty;

  DrawingState copyWith({
    List<Stroke>? strokes,
    Stroke? activeStroke,
    bool clearActiveStroke = false,
    List<Image>? fillImages,
    List<ActionType>? actionHistory,
    DrawingTool? currentTool,
    Color? currentColor,
    BrushSize? currentBrushSize,
    bool? filling,
  }) {
    return DrawingState(
      strokes: strokes ?? this.strokes,
      activeStroke:
          clearActiveStroke ? null : (activeStroke ?? this.activeStroke),
      fillImages: fillImages ?? this.fillImages,
      actionHistory: actionHistory ?? this.actionHistory,
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      currentBrushSize: currentBrushSize ?? this.currentBrushSize,
      filling: filling ?? this.filling,
    );
  }
}
