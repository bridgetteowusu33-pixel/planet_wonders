import 'dart:convert';

import 'step_reward.dart';

/// A completed recipe saved to the player's album.
///
/// Persisted via SharedPreferences as JSON. Tracks which recipes
/// were completed, when, how many stars, and which per-step rewards
/// were earned.
class RecipeAlbumEntry {
  const RecipeAlbumEntry({
    required this.recipeId,
    required this.countryId,
    required this.title,
    required this.emoji,
    required this.completedAt,
    this.stars = 3,
    this.badgeTitle,
    this.earnedRewards = const [],
    this.playCount = 1,
  });

  final String recipeId;
  final String countryId;
  final String title;
  final String emoji;
  final DateTime completedAt;
  final int stars;
  final String? badgeTitle;
  final List<StepReward> earnedRewards;
  final int playCount;

  RecipeAlbumEntry copyWith({
    int? stars,
    int? playCount,
    List<StepReward>? earnedRewards,
  }) {
    return RecipeAlbumEntry(
      recipeId: recipeId,
      countryId: countryId,
      title: title,
      emoji: emoji,
      completedAt: completedAt,
      stars: stars ?? this.stars,
      badgeTitle: badgeTitle,
      earnedRewards: earnedRewards ?? this.earnedRewards,
      playCount: playCount ?? this.playCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'recipeId': recipeId,
        'countryId': countryId,
        'title': title,
        'emoji': emoji,
        'completedAt': completedAt.toIso8601String(),
        'stars': stars,
        'badgeTitle': badgeTitle,
        'earnedRewards': earnedRewards
            .map((r) => {'id': r.id, 'title': r.title, 'emoji': r.emoji})
            .toList(growable: false),
        'playCount': playCount,
      };

  factory RecipeAlbumEntry.fromJson(Map<String, dynamic> json) {
    final rewards = (json['earnedRewards'] as List?)
            ?.whereType<Map>()
            .map(
              (r) => StepReward(
                id: r['id'] as String? ?? '',
                title: r['title'] as String? ?? '',
                emoji: r['emoji'] as String? ?? '\u{2B50}',
              ),
            )
            .toList(growable: false) ??
        const [];

    return RecipeAlbumEntry(
      recipeId: json['recipeId'] as String? ?? '',
      countryId: json['countryId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '\u{1F372}',
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      stars: json['stars'] as int? ?? 3,
      badgeTitle: json['badgeTitle'] as String?,
      earnedRewards: rewards,
      playCount: json['playCount'] as int? ?? 1,
    );
  }

  /// Serializes the entry to a JSON string for SharedPreferences storage.
  String encode() => jsonEncode(toJson());

  /// Deserializes from a JSON string.
  static RecipeAlbumEntry? decode(String raw) {
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;
      return RecipeAlbumEntry.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
