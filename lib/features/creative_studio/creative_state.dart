// File: lib/features/creative_studio/creative_state.dart
import 'package:flutter/material.dart';

/// Entry modes for Creative Studio drawing sessions.
enum CreativeEntryMode { freeDraw, drawWithMe, sceneBuilder }

/// Main tool selection on the canvas toolbar.
enum CreativeTool { brush, eraser, fill }

class PromptIdea {
  const PromptIdea({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

class SceneOption {
  const SceneOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

class StickerItem {
  const StickerItem({
    required this.id,
    required this.label,
    required this.emoji,
  });

  final String id;
  final String label;
  final String emoji;
}

class CreativeStroke {
  const CreativeStroke({
    required this.points,
    required this.color,
    required this.width,
    required this.isEraser,
  });

  final List<Offset> points;
  final Color color;
  final double width;
  final bool isEraser;

  CreativeStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? width,
    bool? isEraser,
  }) {
    return CreativeStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
      isEraser: isEraser ?? this.isEraser,
    );
  }
}

class StickerInstance {
  const StickerInstance({
    required this.id,
    required this.itemId,
    required this.label,
    required this.emoji,
    required this.position,
    required this.scale,
    required this.rotation,
  });

  final String id;
  final String itemId;
  final String label;
  final String emoji;
  final Offset position;
  final double scale;
  final double rotation;

  StickerInstance copyWith({
    String? id,
    String? itemId,
    String? label,
    String? emoji,
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    return StickerInstance(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}

class CreativeSnapshot {
  const CreativeSnapshot({
    required this.strokes,
    required this.stickers,
    required this.canvasColor,
    required this.sceneId,
  });

  final List<CreativeStroke> strokes;
  final List<StickerInstance> stickers;
  final Color canvasColor;
  final String? sceneId;
}

class CreativeState {
  const CreativeState({
    required this.mode,
    required this.projectKey,
    required this.canvasTitle,
    required this.promptId,
    required this.sceneId,
    required this.strokes,
    required this.activeStroke,
    required this.stickers,
    required this.selectedStickerId,
    required this.tool,
    required this.currentColor,
    required this.brushSize,
    required this.canvasColor,
    required this.favoriteColors,
    required this.recentColors,
    required this.undoStack,
    required this.redoStack,
    required this.isLoaded,
    required this.isSaving,
  });

  factory CreativeState.initial() {
    return const CreativeState(
      mode: CreativeEntryMode.freeDraw,
      projectKey: '',
      canvasTitle: 'Creative Studio',
      promptId: null,
      sceneId: null,
      strokes: <CreativeStroke>[],
      activeStroke: null,
      stickers: <StickerInstance>[],
      selectedStickerId: null,
      tool: CreativeTool.brush,
      currentColor: Color(0xFF2F3A4A),
      brushSize: 8,
      canvasColor: Color(0xFFFFFFFF),
      favoriteColors: <Color>[],
      recentColors: <Color>[],
      undoStack: <CreativeSnapshot>[],
      redoStack: <CreativeSnapshot>[],
      isLoaded: false,
      isSaving: false,
    );
  }

  final CreativeEntryMode mode;
  final String projectKey;
  final String canvasTitle;
  final String? promptId;
  final String? sceneId;
  final List<CreativeStroke> strokes;
  final CreativeStroke? activeStroke;
  final List<StickerInstance> stickers;
  final String? selectedStickerId;
  final CreativeTool tool;
  final Color currentColor;
  final double brushSize;
  final Color canvasColor;
  final List<Color> favoriteColors;
  final List<Color> recentColors;
  final List<CreativeSnapshot> undoStack;
  final List<CreativeSnapshot> redoStack;
  final bool isLoaded;
  final bool isSaving;

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  CreativeState copyWith({
    CreativeEntryMode? mode,
    String? projectKey,
    String? canvasTitle,
    String? promptId,
    bool clearPromptId = false,
    String? sceneId,
    bool clearSceneId = false,
    List<CreativeStroke>? strokes,
    CreativeStroke? activeStroke,
    bool clearActiveStroke = false,
    List<StickerInstance>? stickers,
    String? selectedStickerId,
    bool clearSelectedStickerId = false,
    CreativeTool? tool,
    Color? currentColor,
    double? brushSize,
    Color? canvasColor,
    List<Color>? favoriteColors,
    List<Color>? recentColors,
    List<CreativeSnapshot>? undoStack,
    List<CreativeSnapshot>? redoStack,
    bool? isLoaded,
    bool? isSaving,
  }) {
    return CreativeState(
      mode: mode ?? this.mode,
      projectKey: projectKey ?? this.projectKey,
      canvasTitle: canvasTitle ?? this.canvasTitle,
      promptId: clearPromptId ? null : (promptId ?? this.promptId),
      sceneId: clearSceneId ? null : (sceneId ?? this.sceneId),
      strokes: strokes ?? this.strokes,
      activeStroke: clearActiveStroke
          ? null
          : (activeStroke ?? this.activeStroke),
      stickers: stickers ?? this.stickers,
      selectedStickerId: clearSelectedStickerId
          ? null
          : (selectedStickerId ?? this.selectedStickerId),
      tool: tool ?? this.tool,
      currentColor: currentColor ?? this.currentColor,
      brushSize: brushSize ?? this.brushSize,
      canvasColor: canvasColor ?? this.canvasColor,
      favoriteColors: favoriteColors ?? this.favoriteColors,
      recentColors: recentColors ?? this.recentColors,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      isLoaded: isLoaded ?? this.isLoaded,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

const List<PromptIdea> kPromptIdeas = <PromptIdea>[
  PromptIdea(
    id: 'friendly_monster',
    title: 'Friendly Monster',
    subtitle: 'Big smile, tiny hat',
    icon: Icons.sentiment_very_satisfied_rounded,
  ),
  PromptIdea(
    id: 'magic_treehouse',
    title: 'Magic Treehouse',
    subtitle: 'Add windows and lights',
    icon: Icons.cottage_rounded,
  ),
  PromptIdea(
    id: 'rocket_puppy',
    title: 'Rocket Puppy',
    subtitle: 'Puppy in space suit',
    icon: Icons.rocket_launch_rounded,
  ),
  PromptIdea(
    id: 'underwater_city',
    title: 'Underwater City',
    subtitle: 'Bubbles and coral streets',
    icon: Icons.water_rounded,
  ),
  PromptIdea(
    id: 'jungle_band',
    title: 'Jungle Band',
    subtitle: 'Animals playing music',
    icon: Icons.music_note_rounded,
  ),
  PromptIdea(
    id: 'robot_picnic',
    title: 'Robot Picnic',
    subtitle: 'Sandwiches and circuits',
    icon: Icons.smart_toy_rounded,
  ),
];

const List<SceneOption> kSceneOptions = <SceneOption>[
  SceneOption(
    id: 'sunny_meadow',
    title: 'Sunny Meadow',
    subtitle: 'Warm and bright',
    icon: Icons.park_rounded,
    colors: <Color>[Color(0xFFA8E6CF), Color(0xFFDDF6A5)],
  ),
  SceneOption(
    id: 'beach_day',
    title: 'Beach Day',
    subtitle: 'Sky and waves',
    icon: Icons.beach_access_rounded,
    colors: <Color>[Color(0xFF8ED6FF), Color(0xFFFDE68A)],
  ),
  SceneOption(
    id: 'night_sky',
    title: 'Night Sky',
    subtitle: 'Stars above',
    icon: Icons.nightlight_round,
    colors: <Color>[Color(0xFF4C5B9A), Color(0xFF1B1E3E)],
  ),
  SceneOption(
    id: 'snow_land',
    title: 'Snow Land',
    subtitle: 'Cool winter tones',
    icon: Icons.ac_unit_rounded,
    colors: <Color>[Color(0xFFDDF4FF), Color(0xFFB7D4FF)],
  ),
  SceneOption(
    id: 'desert_glow',
    title: 'Desert Glow',
    subtitle: 'Soft sunset colors',
    icon: Icons.wb_sunny_rounded,
    colors: <Color>[Color(0xFFFEC89A), Color(0xFFFFE5A8)],
  ),
  SceneOption(
    id: 'space_dream',
    title: 'Space Dream',
    subtitle: 'Nebula vibe',
    icon: Icons.auto_awesome_rounded,
    colors: <Color>[Color(0xFF6A4C93), Color(0xFF1982C4)],
  ),
];

const List<StickerItem> kStickerItems = <StickerItem>[
  StickerItem(id: 'star', label: 'Star', emoji: '\u2B50'),
  StickerItem(id: 'heart', label: 'Heart', emoji: '\u2764\uFE0F'),
  StickerItem(id: 'sun', label: 'Sun', emoji: '\u2600\uFE0F'),
  StickerItem(id: 'tree', label: 'Tree', emoji: '\uD83C\uDF33'),
  StickerItem(id: 'flower', label: 'Flower', emoji: '\uD83C\uDF38'),
  StickerItem(id: 'rocket', label: 'Rocket', emoji: '\uD83D\uDE80'),
  StickerItem(id: 'whale', label: 'Whale', emoji: '\uD83D\uDC33'),
  StickerItem(id: 'lion', label: 'Lion', emoji: '\uD83E\uDD81'),
  StickerItem(id: 'rainbow', label: 'Rainbow', emoji: '\uD83C\uDF08'),
  StickerItem(id: 'sparkle', label: 'Sparkle', emoji: '\u2728'),
  StickerItem(id: 'soccer', label: 'Ball', emoji: '\u26BD'),
  StickerItem(id: 'cake', label: 'Cake', emoji: '\uD83C\uDF70'),
];

const List<Color> kDefaultCreativePalette = <Color>[
  Color(0xFF2F3A4A),
  Color(0xFFE8504D),
  Color(0xFFF2A637),
  Color(0xFFEBCF5C),
  Color(0xFF69B15A),
  Color(0xFF69B9DE),
  Color(0xFF4D8EE6),
  Color(0xFF8F3BB8),
  Color(0xFFE06BA6),
  Color(0xFF8C5A3C),
  Color(0xFF111111),
  Color(0xFFFFFFFF),
];
