import 'dart:math' as math;

enum RecipeActionType {
  tap,
  drag,
  stir,
  shake,
  hold,
}

RecipeActionType recipeActionFromString(String raw) {
  final value = raw.trim().toLowerCase();
  switch (value) {
    case 'tap':
    case 'tap_bowl':
    case 'tap_chop':
    case 'tap_spice_shaker':
      return RecipeActionType.tap;
    case 'drag':
    case 'drag_tomato':
    case 'drag_oil_to_pot':
    case 'drag_tomato_mix':
    case 'drag_rice_to_pot':
      return RecipeActionType.drag;
    case 'stir':
    case 'stir_circle':
      return RecipeActionType.stir;
    case 'shake':
      return RecipeActionType.shake;
    case 'hold':
    case 'hold_cook':
    case 'hold_to_cook':
      return RecipeActionType.hold;
    default:
      throw FormatException('Unsupported recipe action: $raw');
  }
}

class RecipeStoryStep {
  const RecipeStoryStep({
    required this.story,
    required this.actionKey,
    required this.action,
    this.requiredCount,
    this.holdDurationMs,
    this.asset,
    this.fact,
    this.sfx,
  });

  final String story;
  final String actionKey;
  final RecipeActionType action;
  final int? requiredCount;
  final int? holdDurationMs;
  final String? asset;
  final String? fact;
  final String? sfx;

  int get safeRequiredCount {
    final raw = requiredCount;
    if (raw == null || raw < 1) return 1;
    return raw;
  }

  int get safeHoldDurationMs {
    final raw = holdDurationMs;
    if (raw == null || raw < 500) return 2000;
    return raw;
  }

  factory RecipeStoryStep.fromJson(Map<String, dynamic> json) {
    final story = (json['story'] as String?)?.trim() ?? '';
    final actionRaw = (json['action'] as String?)?.trim() ?? '';

    if (story.isEmpty) {
      throw const FormatException('Recipe step story cannot be empty.');
    }
    if (actionRaw.isEmpty) {
      throw const FormatException('Recipe step action cannot be empty.');
    }

    return RecipeStoryStep(
      story: story,
      actionKey: actionRaw,
      action: recipeActionFromString(actionRaw),
      requiredCount: _optionalInt(json['requiredCount']),
      holdDurationMs: _optionalInt(json['holdDurationMs']),
      asset: _optionalString(json['asset']),
      fact: _optionalString(json['fact']),
      sfx: _optionalString(json['sfx']),
    );
  }
}

class RecipeStory {
  const RecipeStory({
    required this.id,
    required this.title,
    required this.country,
    required this.emoji,
    required this.difficulty,
    required this.imageAsset,
    this.thumbnailAsset,
    required this.intro,
    this.introFact,
    required this.completionMessage,
    this.completionAsset,
    this.completionFact,
    this.badgeTitle,
    this.rewardCultureStars = 1,
    required this.steps,
  });

  final String id;
  final String title;
  final String country;
  final String emoji;
  final int difficulty;
  final String imageAsset;
  final String? thumbnailAsset;
  final String intro;
  final String? introFact;
  final String completionMessage;
  final String? completionAsset;
  final String? completionFact;
  final String? badgeTitle;
  final int rewardCultureStars;
  final List<RecipeStoryStep> steps;

  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      default:
        return 'Challenging';
    }
  }

  int get safeDifficulty => math.max(1, math.min(difficulty, 3));

  factory RecipeStory.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final title = (json['title'] as String?)?.trim() ?? '';
    final country = (json['country'] as String?)?.trim() ?? '';
    final emoji = (json['emoji'] as String?)?.trim() ?? '';
    final imageAsset = (json['imageAsset'] as String?)?.trim() ?? '';
    final thumbnailAsset = _optionalString(json['thumbnailAsset']);
    final intro = (json['intro'] as String?)?.trim() ?? '';
    final introFact = _optionalString(json['introFact']);
    final completionMessage = (json['completionMessage'] as String?)?.trim() ?? '';
    final completionAsset = _optionalString(json['completionAsset']);
    final completionFact = _optionalString(json['completionFact']);
    final badgeTitle = _optionalString(json['badgeTitle']);
    final rewardCultureStars = _optionalInt(json['rewardCultureStars']) ?? 1;
    final difficulty = json['difficulty'] is int
        ? json['difficulty'] as int
        : int.tryParse('${json['difficulty']}') ?? 1;

    final rawSteps = json['steps'];
    if (id.isEmpty || title.isEmpty || country.isEmpty || rawSteps is! List) {
      throw const FormatException('Recipe story has missing required fields.');
    }

    final steps = rawSteps
        .whereType<Map>()
        .map((step) => RecipeStoryStep.fromJson(step.cast<String, dynamic>()))
        .toList(growable: false);

    if (steps.isEmpty) {
      throw const FormatException('Recipe story must include at least one step.');
    }

    return RecipeStory(
      id: id,
      title: title,
      country: country,
      emoji: emoji.isEmpty ? '🍲' : emoji,
      difficulty: difficulty,
      imageAsset: imageAsset,
      thumbnailAsset: thumbnailAsset,
      intro: intro,
      introFact: introFact,
      completionMessage: completionMessage,
      completionAsset: completionAsset,
      completionFact: completionFact,
      badgeTitle: badgeTitle,
      rewardCultureStars: rewardCultureStars < 1 ? 1 : rewardCultureStars,
      steps: steps,
    );
  }
}

String? _optionalString(Object? raw) {
  if (raw is! String) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return trimmed;
}

int? _optionalInt(Object? raw) {
  if (raw is int) return raw;
  if (raw is String) return int.tryParse(raw.trim());
  return null;
}
