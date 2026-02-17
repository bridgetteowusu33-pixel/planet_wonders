class AchievementUnlockCondition {
  const AchievementUnlockCondition({
    required this.type,
    this.countryId,
    this.recipeId,
    this.minCount = 1,
    this.minCountries = 0,
  });

  final String type;
  final String? countryId;
  final String? recipeId;
  final int minCount;
  final int minCountries;

  factory AchievementUnlockCondition.fromJson(Map<String, dynamic> json) {
    return AchievementUnlockCondition(
      type: (json['type'] as String?)?.trim() ?? 'unknown',
      countryId: _optString(json['countryId']),
      recipeId: _optString(json['recipeId']),
      minCount: _optInt(json['minCount']) ?? 1,
      minCountries: _optInt(json['minCountries']) ?? 0,
    );
  }
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.unlockCondition,
    this.score = 10,
  });

  final String id;
  final String title;
  final String description;
  final String iconPath;
  final AchievementUnlockCondition unlockCondition;
  final int score;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final condition = json['unlockCondition'];
    if (condition is! Map<String, dynamic>) {
      throw const FormatException('Achievement unlockCondition is required.');
    }

    final id = (json['id'] as String?)?.trim() ?? '';
    final title = (json['title'] as String?)?.trim() ?? '';
    final description = (json['description'] as String?)?.trim() ?? '';
    final iconPath = (json['iconPath'] as String?)?.trim() ?? '';

    if (id.isEmpty || title.isEmpty || description.isEmpty || iconPath.isEmpty) {
      throw const FormatException('Achievement has missing required fields.');
    }

    return Achievement(
      id: id,
      title: title,
      description: description,
      iconPath: iconPath,
      unlockCondition: AchievementUnlockCondition.fromJson(condition),
      score: _optInt(json['score']) ?? 10,
    );
  }
}

String? _optString(Object? raw) {
  if (raw is! String) return null;
  final value = raw.trim();
  if (value.isEmpty) return null;
  return value;
}

int? _optInt(Object? raw) {
  if (raw is int) return raw;
  if (raw is String) return int.tryParse(raw.trim());
  return null;
}
