import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/drawing_state.dart';

/// AutoDispose so every time the user opens the drawing screen they get
/// a fresh canvas, and memory is freed when they leave.
final drawingProvider =
    NotifierProvider.autoDispose<DrawingNotifier, DrawingState>(
      DrawingNotifier.new,
    );

class DrawingNotifier extends Notifier<DrawingState> {
  static const double _minPointDistanceSquared = 9.0;
  final Set<Image> _ownedBitmapImages = <Image>{};

  @override
  DrawingState build() {
    ref.onDispose(_disposeOwnedBitmapImages);
    return const DrawingState();
  }

  // --- touch lifecycle (brush / eraser) ---

  void startStroke(Offset point) {
    final tool = state.currentTool;
    // Fill tool uses tap, not stroke — ignore pan events.
    if (tool == DrawingTool.fill) return;

    final isEraser = tool == DrawingTool.eraser;

    final stroke = Stroke(
      points: [point],
      color: isEraser ? const Color(0x00000000) : state.currentColor,
      width: state.activeWidth,
      brushType: state.currentBrushType,
      isEraser: isEraser,
    );

    state = state.copyWith(activeStroke: stroke);
  }

  void updateStroke(Offset point) {
    final active = state.activeStroke;
    if (active == null) return;
    final points = active.points;
    if (points.isNotEmpty) {
      final last = points.last;
      final dx = point.dx - last.dx;
      final dy = point.dy - last.dy;
      if ((dx * dx + dy * dy) < _minPointDistanceSquared) {
        return;
      }
    }
    state = state.copyWith(activeStroke: active.addPoint(point));
  }

  void endStroke() {
    final active = state.activeStroke;
    if (active == null) return;

    _disposeBitmapImages(state.redoStack);

    // Push StrokeAction to actions, clear redoStack
    state = state.copyWith(
      actions: [...state.actions, StrokeAction(active)],
      redoStack: [], // new action clears redo
      clearActiveStroke: true,
    );
  }

  // --- fill tool (region-based) ---

  /// Fills a region with the current color.
  ///
  /// Pushes a RegionFillAction to the action stack.
  /// If the same region is filled again, it just replaces the color.
  void fillRegion(int regionId, Color color) {
    _disposeBitmapImages(state.redoStack);
    state = state.copyWith(
      actions: [
        ...state.actions,
        RegionFillAction(regionId: regionId, color: color),
      ],
      redoStack: [], // new action clears redo
      filling: false,
    );
  }

  /// Adds a flood-fill bitmap overlay action.
  void addBitmapFill(Image image) {
    _ownedBitmapImages.add(image);
    _disposeBitmapImages(state.redoStack);
    state = state.copyWith(
      actions: [...state.actions, BitmapFillAction(image)],
      redoStack: [],
      filling: false,
    );
  }

  /// Legacy setter for filling state (used during async flood fill).
  /// In Phase 1 with region masks, fills are instant, so this is rarely used.
  void setFilling(bool value) {
    state = state.copyWith(filling: value);
  }

  // --- undo / redo ---

  void undo() {
    if (!state.canUndo) return;

    final actions = [...state.actions];
    final lastAction = actions.removeLast();

    state = state.copyWith(
      actions: actions,
      redoStack: [...state.redoStack, lastAction],
    );
  }

  void redo() {
    if (!state.canRedo) return;

    final redoStack = [...state.redoStack];
    final action = redoStack.removeLast();

    state = state.copyWith(
      actions: [...state.actions, action],
      redoStack: redoStack,
    );
  }

  void clear() {
    _disposeBitmapImages(state.actions);
    _disposeBitmapImages(state.redoStack);
    state = state.copyWith(actions: [], redoStack: [], clearActiveStroke: true);
  }

  /// Replaces the current drawing state with a restored snapshot.
  ///
  /// Used by the persistence layer when a page is reopened.
  void restoreState(DrawingState restored) {
    _disposeBitmapImages(state.actions);
    _disposeBitmapImages(state.redoStack);

    // Restored data contains only serializable actions (strokes + region fills).
    state = restored.copyWith(
      redoStack: const [],
      clearActiveStroke: true,
      filling: false,
    );
  }

  // --- toolbar actions ---

  void setTool(DrawingTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setBrushType(BrushType type) {
    state = state.copyWith(currentBrushType: type);
  }

  void setColor(Color color) {
    // Keep Fill selected when changing colors in fill mode.
    // Otherwise preserve the existing behavior of returning to brush.
    final nextTool = state.currentTool == DrawingTool.fill
        ? DrawingTool.fill
        : DrawingTool.marker;

    state = state.copyWith(currentColor: color, currentTool: nextTool);
  }

  void setBrushSize(BrushSize size) {
    state = state.copyWith(currentBrushSize: size);
  }

  void setPrecisionMode(bool enabled) {
    state = state.copyWith(precisionMode: enabled);
  }

  void togglePrecisionMode() {
    state = state.copyWith(precisionMode: !state.precisionMode);
  }

  void setPaperTextureEnabled(bool enabled) {
    state = state.copyWith(paperTextureEnabled: enabled);
  }

  void _disposeBitmapImages(Iterable<DrawingAction> actions) {
    for (final action in actions) {
      if (action is BitmapFillAction) {
        final image = action.image;
        if (_ownedBitmapImages.remove(image)) {
          image.dispose();
        }
      }
    }
  }

  void _disposeOwnedBitmapImages() {
    for (final image in _ownedBitmapImages) {
      image.dispose();
    }
    _ownedBitmapImages.clear();
  }
}
