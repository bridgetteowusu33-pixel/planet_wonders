/// A collectible sticker earned by completing activities.
class Sticker {
  const Sticker({
    required this.id,
    required this.countryId,
    required this.label,
    required this.emoji,
    required this.assetPath,
    required this.funFact,
    required this.earnCondition,
  });

  /// Unique sticker identifier, e.g. `ghana_kente`.
  final String id;

  /// Country this sticker belongs to.
  final String countryId;

  /// Short display name shown below the sticker image.
  final String label;

  /// Fallback emoji rendered when the PNG asset is missing.
  final String emoji;

  /// Path to the sticker PNG, e.g. `assets/stickers/ghana/kente_cloth.png`.
  final String assetPath;

  /// Fun educational fact shown in the detail sheet.
  final String funFact;

  /// Condition that must be met to earn this sticker.
  final StickerEarnCondition earnCondition;

  factory Sticker.fromJson(Map<String, dynamic> json) {
    final countryId = (json['countryId'] as String).trim();
    final assetName = (json['assetName'] as String).trim();
    return Sticker(
      id: (json['id'] as String).trim(),
      countryId: countryId,
      label: (json['label'] as String).trim(),
      emoji: (json['emoji'] as String).trim(),
      assetPath: 'assets/stickers/$countryId/$assetName',
      funFact: (json['funFact'] as String? ?? '').trim(),
      earnCondition: StickerEarnCondition.fromJson(
        json['earnCondition'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Describes what a player must do to earn a [Sticker].
class StickerEarnCondition {
  const StickerEarnCondition({
    required this.type,
    this.countryId,
  });

  /// Condition type — matches against activity completion events.
  ///
  /// Values: `story_completed`, `cooking_completed`, `pack_suitcase_completed`.
  final String type;

  /// Optional country filter. When set, only completions for this country
  /// satisfy the condition.
  final String? countryId;

  factory StickerEarnCondition.fromJson(Map<String, dynamic> json) {
    return StickerEarnCondition(
      type: (json['type'] as String).trim(),
      countryId: (json['countryId'] as String?)?.trim(),
    );
  }
}
