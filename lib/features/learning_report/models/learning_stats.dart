import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

// ---------------------------------------------------------------------------
// Activity types
// ---------------------------------------------------------------------------

enum ActivityType { story, coloring, cooking, drawing, fashion, game }

// ---------------------------------------------------------------------------
// Activity log entry
// ---------------------------------------------------------------------------

class ActivityLogEntry {
  const ActivityLogEntry({
    required this.id,
    required this.type,
    required this.label,
    required this.countryId,
    required this.timestamp,
    required this.emoji,
  });

  final String id;
  final ActivityType type;
  final String label;
  final String countryId;
  final DateTime timestamp;
  final String emoji;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'label': label,
    'countryId': countryId,
    'timestamp': timestamp.toIso8601String(),
    'emoji': emoji,
  };

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntry(
      id: json['id'] as String,
      type: ActivityType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ActivityType.game,
      ),
      label: json['label'] as String,
      countryId: json['countryId'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      emoji: json['emoji'] as String? ?? '',
    );
  }

  static String encodeList(List<ActivityLogEntry> entries) {
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }

  static List<ActivityLogEntry> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ActivityLogEntry.fromJson)
        .toList(growable: false);
  }
}

// ---------------------------------------------------------------------------
// Skill scores
// ---------------------------------------------------------------------------

enum SkillType { creativity, reading, culture, lifeSkills, motorSkills }

class SkillScore {
  const SkillScore({
    required this.type,
    required this.label,
    required this.score,
    required this.color,
    required this.emoji,
  });

  final SkillType type;
  final String label;
  final double score; // 0.0 – 1.0
  final Color color;
  final String emoji;
}

const _skillMeta = <SkillType, (String, Color, String)>{
  SkillType.creativity: ('Creativity', PWColors.coral, '\u{1F3A8}'),
  SkillType.reading: ('Reading', PWColors.blue, '\u{1F4D6}'),
  SkillType.culture: ('Culture', PWColors.yellow, '\u{1F30D}'),
  SkillType.lifeSkills: ('Life Skills', PWColors.mint, '\u{1F331}'),
  SkillType.motorSkills: ('Motor Skills', Color(0xFFAB7BF5), '\u{270D}\u{FE0F}'),
};

SkillScore buildSkillScore(SkillType type, double score) {
  final (label, color, emoji) = _skillMeta[type]!;
  return SkillScore(
    type: type,
    label: label,
    score: score.clamp(0.0, 1.0),
    color: color,
    emoji: emoji,
  );
}

// ---------------------------------------------------------------------------
// Skill derivation from activity types
// ---------------------------------------------------------------------------

/// Returns which skills an activity type contributes to.
Map<SkillType, int> skillPointsFor(ActivityType type) {
  switch (type) {
    case ActivityType.story:
      return {SkillType.reading: 1, SkillType.culture: 1};
    case ActivityType.coloring:
      return {SkillType.creativity: 1, SkillType.motorSkills: 1};
    case ActivityType.cooking:
      return {SkillType.lifeSkills: 1, SkillType.culture: 1};
    case ActivityType.drawing:
      return {SkillType.creativity: 1, SkillType.motorSkills: 1};
    case ActivityType.fashion:
      return {SkillType.creativity: 1, SkillType.culture: 1};
    case ActivityType.game:
      return {SkillType.motorSkills: 1};
  }
}

// ---------------------------------------------------------------------------
// Aggregate learning stats
// ---------------------------------------------------------------------------

enum ReportPeriod { today, week, month, allTime }

class LearningStats {
  const LearningStats({
    this.activitiesCompleted = 0,
    this.countriesExplored = 0,
    this.badgesEarned = 0,
    this.skills = const [],
    this.recentActivities = const [],
    this.loading = true,
  });

  final int activitiesCompleted;
  final int countriesExplored;
  final int badgesEarned;
  final List<SkillScore> skills;
  final List<ActivityLogEntry> recentActivities;
  final bool loading;

  LearningStats copyWith({
    int? activitiesCompleted,
    int? countriesExplored,
    int? badgesEarned,
    List<SkillScore>? skills,
    List<ActivityLogEntry>? recentActivities,
    bool? loading,
  }) {
    return LearningStats(
      activitiesCompleted: activitiesCompleted ?? this.activitiesCompleted,
      countriesExplored: countriesExplored ?? this.countriesExplored,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      skills: skills ?? this.skills,
      recentActivities: recentActivities ?? this.recentActivities,
      loading: loading ?? this.loading,
    );
  }
}
