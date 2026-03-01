import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ingredient_rush_state.dart';
import '../models/rush_difficulty.dart';
import '../models/rush_ingredient.dart';
import '../models/rush_mission.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final ingredientRushProvider =
    NotifierProvider.autoDispose<IngredientRushController, IngredientRushState>(
  IngredientRushController.new,
);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class IngredientRushController extends Notifier<IngredientRushState> {
  final math.Random _rng = math.Random();
  Timer? _countdownTimer;
  Timer? _spawnTimer;
  int _nextUid = 0;

  /// When true, speeds are halved and spawn interval doubled.
  bool reduceMotion = false;

  @override
  IngredientRushState build() {
    ref.onDispose(_cancelTimers);
    return const IngredientRushState();
  }

  // ---- Lifecycle ----------------------------------------------------------

  void startMission(RushMission mission, RushDifficulty difficulty) {
    _cancelTimers();
    _nextUid = 0;

    final config = RushDifficultyConfig.forDifficulty(difficulty);

    final firstObj = mission.objectives.isNotEmpty
        ? mission.objectives[0]
        : null;

    state = IngredientRushState(
      phase: RushPhase.playing,
      mission: mission,
      difficulty: difficulty,
      currentObjectiveIndex: 0,
      collectedCounts: const <String, int>{},
      activeIngredients: const <RushIngredient>[],
      wrongTaps: 0,
      timerRemainingSec: config.timerDurationSec,
      timerTotalSec: config.timerDurationSec,
      potFace: 'idle',
      characterLine: firstObj != null
          ? 'Collect ${firstObj.targetCount} ${firstObj.name}!'
          : 'Let\u{2019}s go!',
    );

    // Start countdown.
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _onTimerTick(),
    );

    // Start spawning.
    final spawnMs = reduceMotion
        ? config.spawnIntervalMs * 2
        : config.spawnIntervalMs;
    _spawnTimer = Timer.periodic(
      Duration(milliseconds: spawnMs),
      (_) => _spawnIngredient(),
    );
  }

  void retry() {
    final m = state.mission;
    if (m == null) return;
    startMission(m, state.difficulty);
  }

  void setDifficulty(RushDifficulty difficulty) {
    if (state.phase != RushPhase.intro) return;
    state = state.copyWith(difficulty: difficulty);
  }

  // ---- Per-frame update ---------------------------------------------------

  void tick(Duration elapsed) {
    if (state.phase != RushPhase.playing) return;
    if (state.activeIngredients.isEmpty) return;

    final dt = elapsed.inMicroseconds / 1e6; // seconds
    if (dt <= 0 || dt > 0.5) return; // skip huge jumps

    final updated = <RushIngredient>[];
    for (final ing in state.activeIngredients) {
      // x is in logical pixels; move by speed * dt
      final dx = ing.speed * dt * ing.direction;
      final newX = ing.x + dx;
      // Keep if still on screen (generous bounds: -120 to screenWidth+120).
      // We use a normalized approach: ingredients placed in screen coords,
      // so we check against a wide range.
      if (newX > -200 && newX < 2000) {
        updated.add(ing.copyWith(x: newX));
      }
    }

    state = state.copyWith(activeIngredients: updated);
  }

  // ---- Tap handling -------------------------------------------------------

  void tapIngredient(int uid) {
    if (state.phase != RushPhase.playing) return;

    final mission = state.mission;
    if (mission == null) return;

    final idx =
        state.activeIngredients.indexWhere((ing) => ing.uid == uid);
    if (idx < 0) return;

    final tapped = state.activeIngredients[idx];
    final currentObj = state.currentObjective;

    // Remove ingredient from active list.
    final remaining = [...state.activeIngredients]..removeAt(idx);

    if (currentObj != null && tapped.ingredientId == currentObj.ingredientId) {
      // Correct tap!
      final counts = {...state.collectedCounts};
      final prev = counts[tapped.ingredientId] ?? 0;
      counts[tapped.ingredientId] = prev + 1;

      final newCollected = prev + 1;
      final isObjectiveDone = newCollected >= currentObj.targetCount;

      if (isObjectiveDone) {
        final nextObjIdx = state.currentObjectiveIndex + 1;
        final allDone = nextObjIdx >= mission.objectives.length;

        if (allDone) {
          // Mission complete!
          _cancelTimers();
          state = state.copyWith(
            phase: RushPhase.success,
            activeIngredients: const [],
            collectedCounts: counts,
            potFace: 'party',
            characterLine: 'Amazing! All ingredients collected!',
            collectAnimTrigger: state.collectAnimTrigger + 1,
          );
          return;
        }

        // Advance to next objective.
        final nextObj = mission.objectives[nextObjIdx];
        state = state.copyWith(
          currentObjectiveIndex: nextObjIdx,
          collectedCounts: counts,
          activeIngredients: remaining,
          potFace: 'happy',
          characterLine: 'Nice! Now collect ${nextObj.targetCount} ${nextObj.name}!',
          collectAnimTrigger: state.collectAnimTrigger + 1,
        );
      } else {
        state = state.copyWith(
          collectedCounts: counts,
          activeIngredients: remaining,
          potFace: 'surprised',
          characterLine: _pick([
            'Yum! Keep going!',
            'Great pick!',
            'Into the pot!',
          ]),
          collectAnimTrigger: state.collectAnimTrigger + 1,
        );
      }
    } else {
      // Wrong tap.
      state = state.copyWith(
        wrongTaps: state.wrongTaps + 1,
        activeIngredients: remaining,
        potFace: 'worried',
        characterLine: _pick([
          'Oops! That\u{2019}s not the right one!',
          'Not quite \u{2014} try again!',
          'Wrong ingredient! Keep looking!',
        ]),
        shakeAnimTrigger: state.shakeAnimTrigger + 1,
      );
    }
  }

  // ---- Internal -----------------------------------------------------------

  void _onTimerTick() {
    if (!ref.mounted) return;
    if (state.phase != RushPhase.playing) return;

    final remaining = state.timerRemainingSec - 1;
    if (remaining <= 0) {
      _cancelTimers();
      state = state.copyWith(
        phase: RushPhase.timeUp,
        timerRemainingSec: 0,
        activeIngredients: const [],
        potFace: 'worried',
        characterLine: 'Time\u{2019}s up! Want to try again?',
      );
      return;
    }

    state = state.copyWith(timerRemainingSec: remaining);
  }

  void _spawnIngredient() {
    if (!ref.mounted) return;
    if (state.phase != RushPhase.playing) return;

    final mission = state.mission;
    if (mission == null) return;

    final config = RushDifficultyConfig.forDifficulty(state.difficulty);
    if (state.activeIngredients.length >= config.maxOnScreen) return;

    final currentObj = state.currentObjective;
    if (currentObj == null) return;

    // Decide target vs distractor.
    final spawnTarget = _rng.nextDouble() > config.distractorRatio;

    RushObjective source;
    bool isTarget;

    if (spawnTarget || mission.distractorPool.isEmpty) {
      source = currentObj;
      isTarget = true;
    } else {
      source = mission.distractorPool[
          _rng.nextInt(mission.distractorPool.length)];
      isTarget = false;
    }

    // Pick lane (0-4) avoiding existing ingredients in the same lane.
    const laneCount = 5;
    final usedLanes =
        state.activeIngredients.map((i) => i.lane).toSet();
    var lane = _rng.nextInt(laneCount);
    if (usedLanes.length < laneCount) {
      while (usedLanes.contains(lane)) {
        lane = _rng.nextInt(laneCount);
      }
    }

    // Random direction and speed.
    final direction = _rng.nextBool() ? 1 : -1;
    final speedRange = config.maxSpeed - config.minSpeed;
    var speed = config.minSpeed + _rng.nextDouble() * speedRange;
    if (reduceMotion) speed *= 0.5;

    // Starting x position: off-screen on the spawn side.
    final startX = direction == 1 ? -80.0 : 1100.0;

    final ingredient = RushIngredient(
      uid: _nextUid++,
      ingredientId: source.ingredientId,
      name: source.name,
      emoji: source.emoji,
      isTarget: isTarget,
      lane: lane,
      x: startX,
      speed: speed,
      direction: direction,
      assetPath: source.assetPath,
    );

    state = state.copyWith(
      activeIngredients: [...state.activeIngredients, ingredient],
    );
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _spawnTimer?.cancel();
    _spawnTimer = null;
  }

  String _pick(List<String> options) => options[_rng.nextInt(options.length)];
}
