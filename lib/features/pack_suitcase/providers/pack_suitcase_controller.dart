import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pack_difficulty.dart';
import '../models/pack_suitcase_state.dart';
import '../models/suitcase_pack.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final packSuitcaseProvider =
    NotifierProvider.autoDispose<PackSuitcaseController, PackSuitcaseState>(
  PackSuitcaseController.new,
);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class PackSuitcaseController extends Notifier<PackSuitcaseState> {
  final math.Random _rng = math.Random();
  Timer? _countdownTimer;

  @override
  PackSuitcaseState build() {
    ref.onDispose(_cancelTimer);
    return const PackSuitcaseState();
  }

  // ---- Lifecycle ----------------------------------------------------------

  void startGame(SuitcasePack pack, PackDifficulty difficulty) {
    _cancelTimer();

    final config = PackDifficultyConfig.forDifficulty(difficulty);

    state = PackSuitcaseState(
      phase: PackPhase.playing,
      pack: pack,
      difficulty: difficulty,
      packedItemIds: const <String>{},
      wrongDropCount: 0,
      timerRemainingSec: config.timerDurationSec,
      timerTotalSec: config.timerDurationSec,
      characterLine: 'Let\u{2019}s pack for ${pack.destination}!',
      characterMood: 'excited',
    );

    if (config.hasTimer) {
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _onTimerTick(),
      );
    }
  }

  void retry() {
    final p = state.pack;
    if (p == null) return;
    startGame(p, state.difficulty);
  }

  // ---- Drop / tap handling ------------------------------------------------

  /// Core interaction — called from drag-drop or tap-to-pack.
  void dropItem(String itemId) {
    if (state.phase != PackPhase.playing) return;
    final pack = state.pack;
    if (pack == null) return;

    // Already packed?
    if (state.packedItemIds.contains(itemId)) return;

    final isCorrect = pack.correctItems.any((i) => i.id == itemId);

    if (isCorrect) {
      _handleCorrectDrop(itemId, pack);
    } else {
      _handleWrongDrop(itemId, pack);
    }
  }

  /// Accessibility alias.
  void tapToPack(String itemId) => dropItem(itemId);

  // ---- Internal -----------------------------------------------------------

  void _handleCorrectDrop(String itemId, SuitcasePack pack) {
    final newPacked = {...state.packedItemIds, itemId};
    final done = newPacked.length >= pack.requiredCount;

    // Find fun fact.
    final item = pack.correctItems.firstWhere((i) => i.id == itemId);
    final line = item.funFact.isNotEmpty
        ? item.funFact
        : _pick(['Great pick!', 'Into the suitcase!', 'Nice one!']);

    if (done) {
      _cancelTimer();
      state = state.copyWith(
        phase: PackPhase.success,
        packedItemIds: newPacked,
        lastPackedItemId: itemId,
        characterLine: 'All packed! Time to board!',
        characterMood: 'excited',
        sparkleAnimTrigger: state.sparkleAnimTrigger + 1,
      );
      return;
    }

    state = state.copyWith(
      packedItemIds: newPacked,
      lastPackedItemId: itemId,
      characterLine: line,
      characterMood: 'happy',
      sparkleAnimTrigger: state.sparkleAnimTrigger + 1,
    );
  }

  void _handleWrongDrop(String itemId, SuitcasePack pack) {
    // Find distractor fun fact if available.
    String line;
    try {
      final distractor = pack.distractors.firstWhere((i) => i.id == itemId);
      line = distractor.funFact.isNotEmpty
          ? distractor.funFact
          : _pick(_wrongMessages);
    } catch (_) {
      line = _pick(_wrongMessages);
    }

    state = state.copyWith(
      wrongDropCount: state.wrongDropCount + 1,
      characterLine: line,
      characterMood: 'thinking',
      bounceAnimTrigger: state.bounceAnimTrigger + 1,
    );
  }

  void _onTimerTick() {
    if (!ref.mounted) return;
    if (state.phase != PackPhase.playing) return;

    final remaining = state.timerRemainingSec - 1;
    if (remaining <= 0) {
      _cancelTimer();
      state = state.copyWith(
        phase: PackPhase.timeUp,
        timerRemainingSec: 0,
        characterLine: 'Time\u{2019}s up! Want to try again?',
        characterMood: 'thinking',
      );
      return;
    }

    state = state.copyWith(timerRemainingSec: remaining);
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  String _pick(List<String> options) => options[_rng.nextInt(options.length)];

  static const _wrongMessages = [
    'Not for this trip!',
    'Hmm, we won\u{2019}t need that!',
    'Try something else!',
  ];
}
