import 'rush_difficulty.dart';
import 'rush_ingredient.dart';
import 'rush_mission.dart';

/// Game phase for the Ingredient Rush mini-game.
enum RushPhase { intro, playing, success, timeUp }

/// Immutable state for the Ingredient Rush game.
class IngredientRushState {
  const IngredientRushState({
    this.phase = RushPhase.intro,
    this.mission,
    this.difficulty = RushDifficulty.easy,
    this.currentObjectiveIndex = 0,
    this.collectedCounts = const <String, int>{},
    this.activeIngredients = const <RushIngredient>[],
    this.wrongTaps = 0,
    this.timerRemainingSec = 0,
    this.timerTotalSec = 0,
    this.potFace = 'idle',
    this.characterLine = '',
    this.collectAnimTrigger = 0,
    this.shakeAnimTrigger = 0,
  });

  final RushPhase phase;
  final RushMission? mission;
  final RushDifficulty difficulty;
  final int currentObjectiveIndex;
  final Map<String, int> collectedCounts;
  final List<RushIngredient> activeIngredients;
  final int wrongTaps;
  final int timerRemainingSec;
  final int timerTotalSec;
  final String potFace;
  final String characterLine;

  /// Incremented to trigger a collect animation.
  final int collectAnimTrigger;

  /// Incremented to trigger a shake animation.
  final int shakeAnimTrigger;

  /// Timer fraction remaining (1.0 → 0.0).
  double get timerFraction =>
      timerTotalSec > 0 ? timerRemainingSec / timerTotalSec : 1.0;

  /// Current objective (null when all done or no mission).
  RushObjective? get currentObjective {
    final m = mission;
    if (m == null) return null;
    if (currentObjectiveIndex >= m.objectives.length) return null;
    return m.objectives[currentObjectiveIndex];
  }

  /// How many of the current objective ingredient have been collected.
  int get currentCollected {
    final obj = currentObjective;
    if (obj == null) return 0;
    return collectedCounts[obj.ingredientId] ?? 0;
  }

  /// Progress fraction for the current objective (0.0–1.0).
  double get currentObjectiveProgress {
    final obj = currentObjective;
    if (obj == null) return 0;
    if (obj.targetCount == 0) return 1.0;
    return (currentCollected / obj.targetCount).clamp(0.0, 1.0);
  }

  IngredientRushState copyWith({
    RushPhase? phase,
    RushMission? mission,
    RushDifficulty? difficulty,
    int? currentObjectiveIndex,
    Map<String, int>? collectedCounts,
    List<RushIngredient>? activeIngredients,
    int? wrongTaps,
    int? timerRemainingSec,
    int? timerTotalSec,
    String? potFace,
    String? characterLine,
    int? collectAnimTrigger,
    int? shakeAnimTrigger,
  }) {
    return IngredientRushState(
      phase: phase ?? this.phase,
      mission: mission ?? this.mission,
      difficulty: difficulty ?? this.difficulty,
      currentObjectiveIndex:
          currentObjectiveIndex ?? this.currentObjectiveIndex,
      collectedCounts: collectedCounts ?? this.collectedCounts,
      activeIngredients: activeIngredients ?? this.activeIngredients,
      wrongTaps: wrongTaps ?? this.wrongTaps,
      timerRemainingSec: timerRemainingSec ?? this.timerRemainingSec,
      timerTotalSec: timerTotalSec ?? this.timerTotalSec,
      potFace: potFace ?? this.potFace,
      characterLine: characterLine ?? this.characterLine,
      collectAnimTrigger: collectAnimTrigger ?? this.collectAnimTrigger,
      shakeAnimTrigger: shakeAnimTrigger ?? this.shakeAnimTrigger,
    );
  }
}
