// File: lib/features/creative_studio/creative_state.dart
import 'package:flutter/material.dart';

import '../coloring/models/drawing_state.dart' show BrushType;

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
    this.assetPath,
  });

  final String id;
  final String label;
  final String emoji;
  final String? assetPath;
}

class CreativeStroke {
  const CreativeStroke({
    required this.points,
    required this.color,
    required this.width,
    required this.isEraser,
    this.brushType = BrushType.marker,
  });

  final List<Offset> points;
  final Color color;
  final double width;
  final bool isEraser;
  final BrushType brushType;

  CreativeStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? width,
    bool? isEraser,
    BrushType? brushType,
  }) {
    return CreativeStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
      isEraser: isEraser ?? this.isEraser,
      brushType: brushType ?? this.brushType,
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
    this.assetPath,
  });

  final String id;
  final String itemId;
  final String label;
  final String emoji;
  final Offset position;
  final double scale;
  final double rotation;
  final String? assetPath;

  StickerInstance copyWith({
    String? id,
    String? itemId,
    String? label,
    String? emoji,
    Offset? position,
    double? scale,
    double? rotation,
    String? assetPath,
  }) {
    return StickerInstance(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      assetPath: assetPath ?? this.assetPath,
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
    required this.brushType,
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
      brushType: BrushType.marker,
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
  final BrushType brushType;
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
    BrushType? brushType,
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
      brushType: brushType ?? this.brushType,
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


const List<Color> kDefaultCreativePalette = <Color>[
  // Primaries & secondaries
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
  // Pastels
  Color(0xFFFF8A80), // coral
  Color(0xFFFFAB91), // salmon
  Color(0xFFFFCC80), // peach
  Color(0xFFFFE0B2), // apricot
  Color(0xFFFFF59D), // lemon
  Color(0xFFA5D6A7), // mint
  Color(0xFFB3E5FC), // sky
  Color(0xFFCE93D8), // lilac
  // Skin tones
  Color(0xFFEED9C4), // very light
  Color(0xFFE0BFA3), // light beige
  Color(0xFFD7A97B), // warm tan
  Color(0xFFC68642), // tan
  Color(0xFFB57A4A), // medium brown
  Color(0xFFA56B46), // warm brown
  Color(0xFF8D5524), // deep brown
  Color(0xFF6F4627), // rich brown
  // Browns & neutrals
  Color(0xFF5D4037), // chocolate
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
