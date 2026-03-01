// File: lib/features/creative_studio/creative_controller.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../coloring/controllers/coloring_save_controller.dart';
import '../coloring/models/drawing_state.dart';
import 'creative_state.dart';

final creativeControllerProvider =
    NotifierProvider<CreativeController, CreativeState>(CreativeController.new);

class CreativeController extends Notifier<CreativeState> {
  static const Duration _saveDebounce = Duration(milliseconds: 500);
  static const int _undoLimit = 60;
  static const double _minPointDistanceSquared = 9.0;

  Timer? _saveTimer;
  bool _isHydrating = false;
  bool _stickerTransformInProgress = false;

  @override
  CreativeState build() {
    ref.onDispose(() {
      _saveTimer?.cancel();
      unawaited(saveNow(updateSavingState: false));
    });
    return CreativeState.initial();
  }

  Future<void> loadProject({
    required CreativeEntryMode mode,
    String? promptId,
    String? sceneId,
    String? projectOverride,
  }) async {
    _isHydrating = true;
    _stickerTransformInProgress = false;

    final projectKey =
        projectOverride ??
        _buildProjectKey(mode: mode, promptId: promptId, sceneId: sceneId);

    final prompt = promptId == null ? null : promptById(promptId);
    final scene = sceneId == null ? null : sceneById(sceneId);

    state = state.copyWith(
      mode: mode,
      promptId: promptId,
      sceneId: scene?.id,
      projectKey: projectKey,
      canvasTitle: _titleForMode(mode, prompt),
      isLoaded: false,
      clearActiveStroke: true,
      clearSelectedStickerId: true,
    );

    final saveController = _saveController(projectKey);
    final restoredDrawing = await saveController.restoreSavedState();
    final restoredMeta = await _loadMeta(projectKey);

    final restoredStrokes = _strokesFromDrawingState(restoredDrawing);
    final restoredSceneId =
        restoredMeta?['sceneId'] as String? ?? scene?.id ?? state.sceneId;

    final restoredStickers = _stickersFromJson(restoredMeta?['stickers']);
    final restoredFavorites = _colorsFromJson(restoredMeta?['favoriteColors']);
    final restoredRecents = _colorsFromJson(restoredMeta?['recentColors']);

    final restoredCanvasColor =
        _colorFromJson(restoredMeta?['canvasColor']) ?? const Color(0xFFFFFFFF);

    final restoredBrushSize =
        (restoredMeta?['brushSize'] as num?)?.toDouble() ?? state.brushSize;

    final restoredBrushType = _brushTypeFromName(
      restoredMeta?['brushType'] as String?,
    );

    final restoredColor =
        _colorFromJson(restoredMeta?['currentColor']) ?? state.currentColor;

    state = state.copyWith(
      mode: mode,
      promptId: promptId,
      sceneId: restoredSceneId,
      projectKey: projectKey,
      canvasTitle: _titleForMode(mode, prompt),
      strokes: restoredStrokes,
      clearActiveStroke: true,
      stickers: restoredStickers,
      clearSelectedStickerId: true,
      currentColor: restoredColor,
      brushSize: restoredBrushSize.clamp(2, 48).toDouble(),
      brushType: restoredBrushType,
      canvasColor: restoredCanvasColor,
      favoriteColors: restoredFavorites,
      recentColors: restoredRecents,
      undoStack: const <CreativeSnapshot>[],
      redoStack: const <CreativeSnapshot>[],
      isLoaded: true,
      isSaving: false,
    );

    _isHydrating = false;
  }

  void setTool(CreativeTool tool) {
    state = state.copyWith(tool: tool);
  }

  void setBrushSize(double size) {
    state = state.copyWith(brushSize: size.clamp(2, 48).toDouble());
  }

  void setBrushType(BrushType type) {
    state = state.copyWith(brushType: type);
  }

  void selectColor(Color color) {
    final recents = <Color>[
      color,
      ...state.recentColors.where((c) => c != color),
    ].take(8).toList(growable: false);

    state = state.copyWith(currentColor: color, recentColors: recents);
    _scheduleSave();
  }

  void toggleFavoriteColor(Color color) {
    final favorites = [...state.favoriteColors];
    if (favorites.contains(color)) {
      favorites.remove(color);
    } else {
      favorites.add(color);
    }
    state = state.copyWith(favoriteColors: favorites);
    _scheduleSave();
  }

  void startStroke(Offset point) {
    if (state.tool == CreativeTool.fill) {
      fillCanvas(state.currentColor);
      return;
    }

    final stroke = CreativeStroke(
      points: <Offset>[point],
      color: state.tool == CreativeTool.eraser
          ? const Color(0x00000000)
          : state.currentColor,
      width: state.brushSize,
      isEraser: state.tool == CreativeTool.eraser,
      brushType: state.brushType,
    );
    state = state.copyWith(activeStroke: stroke);
  }

  void updateStroke(Offset point) {
    final active = state.activeStroke;
    if (active == null) return;
    if (active.points.isNotEmpty) {
      final last = active.points.last;
      final dx = point.dx - last.dx;
      final dy = point.dy - last.dy;
      if ((dx * dx + dy * dy) < _minPointDistanceSquared) {
        return;
      }
    }

    final updated = active.copyWith(points: [...active.points, point]);
    state = state.copyWith(activeStroke: updated);
  }

  void endStroke() {
    final active = state.activeStroke;
    if (active == null) return;

    if (active.points.length < 2) {
      state = state.copyWith(clearActiveStroke: true);
      return;
    }

    _pushUndoSnapshot();

    state = state.copyWith(
      strokes: [...state.strokes, active],
      clearActiveStroke: true,
      redoStack: const <CreativeSnapshot>[],
    );
    _scheduleSave();
  }

  void fillCanvas(Color color) {
    _pushUndoSnapshot();
    state = state.copyWith(
      canvasColor: color,
      clearSceneId: true,
      redoStack: const <CreativeSnapshot>[],
    );
    _scheduleSave();
  }

  void applyScene(String sceneId) {
    _pushUndoSnapshot();
    state = state.copyWith(
      sceneId: sceneId,
      redoStack: const <CreativeSnapshot>[],
    );
    _scheduleSave();
  }

  void clearScene() {
    _pushUndoSnapshot();
    state = state.copyWith(
      clearSceneId: true,
      redoStack: const <CreativeSnapshot>[],
    );
    _scheduleSave();
  }

  void addSticker(StickerItem item, {Offset? position}) {
    _pushUndoSnapshot();

    final instance = StickerInstance(
      id: 'sticker_${DateTime.now().microsecondsSinceEpoch}',
      itemId: item.id,
      label: item.label,
      emoji: item.emoji,
      assetPath: item.assetPath,
      // Keep default insertion near the top-left visible viewport area
      // so kids immediately see the sticker after tapping.
      position: position ?? const Offset(220, 220),
      scale: 1,
      rotation: 0,
    );

    state = state.copyWith(
      stickers: [...state.stickers, instance],
      selectedStickerId: instance.id,
      redoStack: const <CreativeSnapshot>[],
    );
    _scheduleSave();
  }

  void selectSticker(String? id) {
    if (id == state.selectedStickerId) return;
    state = state.copyWith(selectedStickerId: id);
  }

  void updateStickerTransform({
    required String stickerId,
    required Offset position,
    required double scale,
    required double rotation,
  }) {
    final updated = state.stickers
        .map(
          (sticker) => sticker.id == stickerId
              ? sticker.copyWith(
                  position: position,
                  scale: scale.clamp(0.35, 3.0).toDouble(),
                  rotation: rotation,
                )
              : sticker,
        )
        .toList(growable: false);

    state = state.copyWith(stickers: updated, selectedStickerId: stickerId);
  }

  void commitStickerTransform() {
    if (!_stickerTransformInProgress) return;
    _stickerTransformInProgress = false;
    _scheduleSave();
  }

  void beginStickerTransform() {
    if (_stickerTransformInProgress) return;
    _stickerTransformInProgress = true;
    _pushUndoSnapshot();
    state = state.copyWith(redoStack: const <CreativeSnapshot>[]);
  }

  void removeSticker(String stickerId) {
    _pushUndoSnapshot();

    state = state.copyWith(
      stickers: state.stickers
          .where((sticker) => sticker.id != stickerId)
          .toList(growable: false),
      clearSelectedStickerId: true,
      redoStack: const <CreativeSnapshot>[],
    );
    _scheduleSave();
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    _stickerTransformInProgress = false;

    final undoStack = [...state.undoStack];
    final snapshot = undoStack.removeLast();

    final redoSnapshot = _snapshotFromState(state);

    state = state.copyWith(
      strokes: _cloneStrokes(snapshot.strokes),
      stickers: _cloneStickers(snapshot.stickers),
      canvasColor: snapshot.canvasColor,
      sceneId: snapshot.sceneId,
      clearSelectedStickerId: true,
      undoStack: undoStack,
      redoStack: [...state.redoStack, redoSnapshot],
      clearActiveStroke: true,
    );

    _scheduleSave();
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    _stickerTransformInProgress = false;

    final redoStack = [...state.redoStack];
    final snapshot = redoStack.removeLast();

    final undoSnapshot = _snapshotFromState(state);

    state = state.copyWith(
      strokes: _cloneStrokes(snapshot.strokes),
      stickers: _cloneStickers(snapshot.stickers),
      canvasColor: snapshot.canvasColor,
      sceneId: snapshot.sceneId,
      clearSelectedStickerId: true,
      redoStack: redoStack,
      undoStack: [...state.undoStack, undoSnapshot],
      clearActiveStroke: true,
    );

    _scheduleSave();
  }

  Future<void> resetCanvas() async {
    if (state.projectKey.isEmpty) return;
    _stickerTransformInProgress = false;

    final saveController = _saveController(state.projectKey);
    await saveController.clearSavedState();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_metaStorageKey(state.projectKey));

    state = state.copyWith(
      strokes: const <CreativeStroke>[],
      clearActiveStroke: true,
      stickers: const <StickerInstance>[],
      clearSelectedStickerId: true,
      canvasColor: const Color(0xFFFFFFFF),
      clearSceneId: true,
      undoStack: const <CreativeSnapshot>[],
      redoStack: const <CreativeSnapshot>[],
    );
  }

  Future<void> saveNow({bool updateSavingState = true}) async {
    if (!state.isLoaded || state.projectKey.isEmpty) return;

    final projectKey = state.projectKey;
    final saveController = _saveController(state.projectKey);
    final drawingState = _toDrawingState(state);

    if (updateSavingState) {
      state = state.copyWith(isSaving: true);
    }

    try {
      await saveController.saveNow(drawingState);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _metaStorageKey(projectKey),
        jsonEncode(_metaPayload(state)),
      );
    } finally {
      if (updateSavingState &&
          state.projectKey.isNotEmpty &&
          state.projectKey == projectKey) {
        state = state.copyWith(isSaving: false);
      }
    }
  }

  PromptIdea? promptById(String id) {
    for (final prompt in kPromptIdeas) {
      if (prompt.id == id) return prompt;
    }
    return null;
  }

  SceneOption? sceneById(String id) {
    for (final scene in kSceneOptions) {
      if (scene.id == id) return scene;
    }
    return null;
  }

  void _scheduleSave() {
    if (_isHydrating || !state.isLoaded || state.projectKey.isEmpty) return;

    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, () {
      unawaited(saveNow(updateSavingState: false));
    });
  }

  ColoringSaveController _saveController(String projectKey) {
    return ref.read(coloringSaveControllerProvider('creative/$projectKey'));
  }

  String _buildProjectKey({
    required CreativeEntryMode mode,
    String? promptId,
    String? sceneId,
  }) {
    final suffix = promptId ?? sceneId ?? 'default';
    return '${mode.name}_$suffix';
  }

  String _titleForMode(CreativeEntryMode mode, PromptIdea? prompt) {
    switch (mode) {
      case CreativeEntryMode.freeDraw:
        return 'Free Draw';
      case CreativeEntryMode.drawWithMe:
        return prompt == null ? 'Draw With Me' : 'Draw: ${prompt.title}';
      case CreativeEntryMode.sceneBuilder:
        return 'Scene Builder';
    }
  }

  void _pushUndoSnapshot() {
    final next = [...state.undoStack, _snapshotFromState(state)];
    final trimmed = next.length <= _undoLimit
        ? next
        : next.sublist(next.length - _undoLimit);

    state = state.copyWith(undoStack: trimmed);
  }

  CreativeSnapshot _snapshotFromState(CreativeState current) {
    return CreativeSnapshot(
      strokes: _cloneStrokes(current.strokes),
      stickers: _cloneStickers(current.stickers),
      canvasColor: current.canvasColor,
      sceneId: current.sceneId,
    );
  }

  List<CreativeStroke> _cloneStrokes(List<CreativeStroke> source) {
    return source
        .map((stroke) => stroke.copyWith(points: [...stroke.points]))
        .toList(growable: false);
  }

  List<StickerInstance> _cloneStickers(List<StickerInstance> source) {
    return source.map((sticker) => sticker.copyWith()).toList(growable: false);
  }

  DrawingState _toDrawingState(CreativeState current) {
    final actions = <DrawingAction>[];

    for (final stroke in current.strokes) {
      actions.add(
        StrokeAction(
          Stroke(
            points: stroke.points,
            color: stroke.color,
            width: stroke.width,
            brushType: stroke.brushType,
            isEraser: stroke.isEraser,
          ),
        ),
      );
    }

    return DrawingState(
      actions: actions,
      redoStack: const <DrawingAction>[],
      activeStroke: null,
      currentTool: _mapToolToDrawingTool(current.tool),
      currentBrushType: current.brushType,
      currentColor: current.currentColor,
      currentBrushSize: _mapBrushSize(current.brushSize),
      filling: false,
      precisionMode: false,
      paperTextureEnabled: false,
    );
  }

  DrawingTool _mapToolToDrawingTool(CreativeTool tool) {
    switch (tool) {
      case CreativeTool.brush:
        return DrawingTool.marker;
      case CreativeTool.eraser:
        return DrawingTool.eraser;
      case CreativeTool.fill:
        return DrawingTool.fill;
    }
  }

  BrushSize _mapBrushSize(double width) {
    if (width <= 4) return BrushSize.small;
    if (width <= 10) return BrushSize.medium;
    return BrushSize.large;
  }

  List<CreativeStroke> _strokesFromDrawingState(DrawingState? drawingState) {
    if (drawingState == null) return const <CreativeStroke>[];

    final strokes = <CreativeStroke>[];
    for (final action in drawingState.actions) {
      if (action is! StrokeAction) continue;
      final stroke = action.stroke;
      strokes.add(
        CreativeStroke(
          points: [...stroke.points],
          color: stroke.color,
          width: stroke.width,
          isEraser: stroke.isEraser,
          brushType: stroke.brushType,
        ),
      );
    }
    return strokes;
  }

  Map<String, dynamic> _metaPayload(CreativeState current) {
    return <String, dynamic>{
      'version': 1,
      'mode': current.mode.name,
      'canvasTitle': current.canvasTitle,
      'promptId': current.promptId,
      'sceneId': current.sceneId,
      'canvasColor': current.canvasColor.toARGB32(),
      'currentColor': current.currentColor.toARGB32(),
      'brushSize': current.brushSize,
      'brushType': current.brushType.name,
      'favoriteColors': current.favoriteColors
          .map((color) => color.toARGB32())
          .toList(growable: false),
      'recentColors': current.recentColors
          .map((color) => color.toARGB32())
          .toList(growable: false),
      'stickers': current.stickers
          .map(
            (sticker) => <String, dynamic>{
              'id': sticker.id,
              'itemId': sticker.itemId,
              'label': sticker.label,
              'emoji': sticker.emoji,
              'assetPath': sticker.assetPath,
              'x': sticker.position.dx,
              'y': sticker.position.dy,
              'scale': sticker.scale,
              'rotation': sticker.rotation,
            },
          )
          .toList(growable: false),
    };
  }

  Future<Map<String, dynamic>?> _loadMeta(String projectKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metaStorageKey(projectKey));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return null;
    } catch (_) {
      return null;
    }
  }

  String _metaStorageKey(String projectKey) => 'creative_meta_$projectKey';

  List<StickerInstance> _stickersFromJson(Object? raw) {
    if (raw is! List) return const <StickerInstance>[];

    final stickers = <StickerInstance>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = item.cast<String, dynamic>();

      final id = map['id'] as String?;
      final itemId = map['itemId'] as String?;
      final label = map['label'] as String?;
      final emoji = map['emoji'] as String?;
      final assetPath = map['assetPath'] as String?;
      final x = (map['x'] as num?)?.toDouble();
      final y = (map['y'] as num?)?.toDouble();
      final scale = (map['scale'] as num?)?.toDouble();
      final rotation = (map['rotation'] as num?)?.toDouble();

      if (id == null ||
          itemId == null ||
          label == null ||
          emoji == null ||
          x == null ||
          y == null ||
          scale == null ||
          rotation == null) {
        continue;
      }

      stickers.add(
        StickerInstance(
          id: id,
          itemId: itemId,
          label: label,
          emoji: emoji,
          assetPath: assetPath,
          position: Offset(x, y),
          scale: scale,
          rotation: rotation,
        ),
      );
    }
    return stickers;
  }

  List<Color> _colorsFromJson(Object? raw) {
    if (raw is! List) return const <Color>[];

    final colors = <Color>[];
    for (final item in raw) {
      final color = _colorFromJson(item);
      if (color != null) {
        colors.add(color);
      }
    }
    return colors;
  }

  BrushType _brushTypeFromName(String? name) {
    if (name == null) return BrushType.marker;
    for (final type in BrushType.values) {
      if (type.name == name) return type;
    }
    return BrushType.marker;
  }

  Color? _colorFromJson(Object? raw) {
    if (raw is int) return Color(raw);
    if (raw is String) {
      final value = int.tryParse(raw);
      if (value != null) return Color(value);
    }
    return null;
  }
}
