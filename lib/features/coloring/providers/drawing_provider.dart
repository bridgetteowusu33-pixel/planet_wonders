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
  @override
  DrawingState build() => const DrawingState();

  // --- touch lifecycle (brush / eraser) ---

  void startStroke(Offset point) {
    final tool = state.currentTool;
    // Fill tool uses tap, not stroke — ignore pan events.
    if (tool == DrawingTool.fill) return;

    final stroke = Stroke(
      points: [point],
      color: tool == DrawingTool.eraser
          ? const Color(0x00000000)
          : state.currentColor,
      width: state.activeWidth,
      tool: tool,
    );
    state = state.copyWith(activeStroke: stroke);
  }

  void updateStroke(Offset point) {
    final active = state.activeStroke;
    if (active == null) return;
    state = state.copyWith(activeStroke: active.addPoint(point));
  }

  void endStroke() {
    final active = state.activeStroke;
    if (active == null) return;
    state = state.copyWith(
      strokes: [...state.strokes, active],
      actionHistory: [...state.actionHistory, ActionType.stroke],
      clearActiveStroke: true,
    );
  }

  // --- fill tool ---

  void setFilling(bool value) {
    state = state.copyWith(filling: value);
  }

  void addFillImage(Image image) {
    state = state.copyWith(
      fillImages: [...state.fillImages, image],
      actionHistory: [...state.actionHistory, ActionType.fill],
      filling: false,
    );
  }

  // --- toolbar actions ---

  void undo() {
    if (!state.canUndo) return;

    final history = [...state.actionHistory];
    final lastAction = history.removeLast();

    if (lastAction == ActionType.stroke) {
      state = state.copyWith(
        strokes: state.strokes.sublist(0, state.strokes.length - 1),
        actionHistory: history,
      );
    } else {
      // Remove last fill image.
      final fills = [...state.fillImages];
      if (fills.isNotEmpty) fills.removeLast();
      state = state.copyWith(
        fillImages: fills,
        actionHistory: history,
      );
    }
  }

  void clear() {
    state = state.copyWith(
      strokes: [],
      fillImages: [],
      actionHistory: [],
      clearActiveStroke: true,
    );
  }

  void setTool(DrawingTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setColor(Color color) {
    // Picking a color automatically switches back to brush.
    state = state.copyWith(currentColor: color, currentTool: DrawingTool.brush);
  }

  void setBrushSize(BrushSize size) {
    state = state.copyWith(currentBrushSize: size);
  }
}
