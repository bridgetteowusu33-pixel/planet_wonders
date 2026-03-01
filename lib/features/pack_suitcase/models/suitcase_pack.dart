import 'pack_item.dart';

/// A single packing challenge for a country.
class SuitcasePack {
  const SuitcasePack({
    required this.packId,
    required this.countryId,
    required this.destination,
    required this.characterName,
    this.characterEmoji = '',
    required this.correctItems,
    required this.distractors,
    required this.requiredCount,
    this.difficulty = 'easy',
    this.hint = '',
  });

  final String packId;
  final String countryId;
  final String destination;
  final String characterName;
  final String characterEmoji;
  final List<PackItem> correctItems;
  final List<PackItem> distractors;
  final int requiredCount;
  final String difficulty;
  final String hint;

  factory SuitcasePack.fromJson(Map<String, dynamic> json) {
    final packId = (json['packId'] as String?)?.trim() ?? '';
    final countryId = (json['countryId'] as String?)?.trim() ?? '';
    final destination = (json['destination'] as String?)?.trim() ?? '';
    final characterName = (json['characterName'] as String?)?.trim() ?? '';

    assert(packId.isNotEmpty, 'SuitcasePack packId must not be empty');
    assert(countryId.isNotEmpty, 'SuitcasePack countryId must not be empty');

    final correct = (json['correctItems'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(PackItem.fromJson)
            .toList(growable: false) ??
        const [];

    final distractors = (json['distractors'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(PackItem.fromJson)
            .toList(growable: false) ??
        const [];

    return SuitcasePack(
      packId: packId,
      countryId: countryId,
      destination: destination,
      characterName: characterName,
      characterEmoji: (json['characterEmoji'] as String?)?.trim() ?? '',
      correctItems: correct,
      distractors: distractors,
      requiredCount: (json['requiredCount'] as int?) ?? 5,
      difficulty: (json['difficulty'] as String?)?.trim() ?? 'easy',
      hint: (json['hint'] as String?)?.trim() ?? '',
    );
  }
}
