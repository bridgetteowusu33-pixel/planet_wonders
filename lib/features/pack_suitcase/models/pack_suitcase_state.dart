import 'pack_difficulty.dart';
import 'suitcase_pack.dart';

/// Phases of the Pack the Suitcase game.
enum PackPhase { gate, playing, success, timeUp }

/// Immutable game state for Pack the Suitcase.
class PackSuitcaseState {
  const PackSuitcaseState({
    this.phase = PackPhase.gate,
    this.pack,
    this.difficulty = PackDifficulty.easy,
    this.packedItemIds = const <String>{},
    this.wrongDropCount = 0,
    this.timerRemainingSec = 0,
    this.timerTotalSec = 0,
    this.characterLine = '',
    this.characterMood = 'happy',
    this.sparkleAnimTrigger = 0,
    this.bounceAnimTrigger = 0,
    this.lastPackedItemId,
  });

  final PackPhase phase;
  final SuitcasePack? pack;
  final PackDifficulty difficulty;
  final Set<String> packedItemIds;
  final int wrongDropCount;
  final int timerRemainingSec;
  final int timerTotalSec;
  final String characterLine;
  final String characterMood;
  final int sparkleAnimTrigger;
  final int bounceAnimTrigger;
  final String? lastPackedItemId;

  // -- Computed ---------------------------------------------------------------

  double get timerFraction =>
      timerTotalSec > 0 ? timerRemainingSec / timerTotalSec : 1.0;

  int get packedCount => packedItemIds.length;

  int get requiredCount => pack?.requiredCount ?? 0;

  double get progress =>
      requiredCount > 0 ? (packedCount / requiredCount).clamp(0.0, 1.0) : 0.0;

  bool get isComplete => packedCount >= requiredCount;

  // -- Copy -------------------------------------------------------------------

  PackSuitcaseState copyWith({
    PackPhase? phase,
    SuitcasePack? pack,
    PackDifficulty? difficulty,
    Set<String>? packedItemIds,
    int? wrongDropCount,
    int? timerRemainingSec,
    int? timerTotalSec,
    String? characterLine,
    String? characterMood,
    int? sparkleAnimTrigger,
    int? bounceAnimTrigger,
    String? lastPackedItemId,
  }) {
    return PackSuitcaseState(
      phase: phase ?? this.phase,
      pack: pack ?? this.pack,
      difficulty: difficulty ?? this.difficulty,
      packedItemIds: packedItemIds ?? this.packedItemIds,
      wrongDropCount: wrongDropCount ?? this.wrongDropCount,
      timerRemainingSec: timerRemainingSec ?? this.timerRemainingSec,
      timerTotalSec: timerTotalSec ?? this.timerTotalSec,
      characterLine: characterLine ?? this.characterLine,
      characterMood: characterMood ?? this.characterMood,
      sparkleAnimTrigger: sparkleAnimTrigger ?? this.sparkleAnimTrigger,
      bounceAnimTrigger: bounceAnimTrigger ?? this.bounceAnimTrigger,
      lastPackedItemId: lastPackedItemId ?? this.lastPackedItemId,
    );
  }
}
