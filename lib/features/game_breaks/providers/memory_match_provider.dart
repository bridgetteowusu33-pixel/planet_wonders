import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/game_break_registry.dart';
import '../models/game_break_types.dart';

final memoryMatchProvider =
    NotifierProvider.autoDispose<MemoryMatchNotifier, MemoryMatchState>(
  MemoryMatchNotifier.new,
);

class MemoryMatchState {
  const MemoryMatchState({
    this.cards = const [],
    this.revealedIds = const {},
    this.matchedPairIds = const {},
    this.firstFlipId,
    this.checking = false,
    this.completed = false,
  });

  /// Shuffled deck of cards.
  final List<MatchCard> cards;

  /// Card IDs currently face-up.
  final Set<String> revealedIds;

  /// Pair IDs that have been successfully matched.
  final Set<String> matchedPairIds;

  /// Card ID of the first flip in the current turn (null if none).
  final String? firstFlipId;

  /// Brief pause while showing a mismatched pair before flipping back.
  final bool checking;

  /// All pairs matched — game is done.
  final bool completed;

  MemoryMatchState copyWith({
    List<MatchCard>? cards,
    Set<String>? revealedIds,
    Set<String>? matchedPairIds,
    String? firstFlipId,
    bool clearFirstFlip = false,
    bool? checking,
    bool? completed,
  }) {
    return MemoryMatchState(
      cards: cards ?? this.cards,
      revealedIds: revealedIds ?? this.revealedIds,
      matchedPairIds: matchedPairIds ?? this.matchedPairIds,
      firstFlipId: clearFirstFlip ? null : (firstFlipId ?? this.firstFlipId),
      checking: checking ?? this.checking,
      completed: completed ?? this.completed,
    );
  }
}

class MemoryMatchNotifier extends Notifier<MemoryMatchState> {
  @override
  MemoryMatchState build() => const MemoryMatchState();

  /// Initialize with country-themed data. Call once when screen mounts.
  void setup(String countryId) {
    final data = findMemoryMatchData(countryId) ?? fallbackMemoryMatch;
    final cards = <MatchCard>[];
    for (final pair in data.pairs) {
      cards.add(MatchCard(
        id: '${pair.id}_0',
        pairId: pair.id,
        emoji: pair.emoji,
        label: pair.label,
      ));
      cards.add(MatchCard(
        id: '${pair.id}_1',
        pairId: pair.id,
        emoji: pair.emoji,
        label: pair.label,
      ));
    }
    cards.shuffle(Random());
    state = MemoryMatchState(cards: cards);
  }

  /// Handle a card tap.
  void flipCard(String cardId) {
    if (state.checking || state.completed) return;
    // Already face-up or already matched — ignore.
    final card = state.cards.firstWhere((c) => c.id == cardId);
    if (state.revealedIds.contains(cardId)) return;
    if (state.matchedPairIds.contains(card.pairId)) return;

    final revealed = {...state.revealedIds, cardId};

    if (state.firstFlipId == null) {
      // First card of the turn.
      state = state.copyWith(revealedIds: revealed, firstFlipId: cardId);
    } else {
      // Second card — check for match.
      state = state.copyWith(revealedIds: revealed, checking: true);
      final firstCard =
          state.cards.firstWhere((c) => c.id == state.firstFlipId);

      if (firstCard.pairId == card.pairId) {
        // Match!
        final matched = {...state.matchedPairIds, card.pairId};
        final allDone = matched.length == state.cards.length ~/ 2;
        state = state.copyWith(
          matchedPairIds: matched,
          clearFirstFlip: true,
          checking: false,
          completed: allDone,
        );
      } else {
        // No match — brief delay, then flip back.
        Future.delayed(const Duration(milliseconds: 800), () {
          final hidden = {...state.revealedIds}
            ..remove(state.firstFlipId!)
            ..remove(cardId);
          state = state.copyWith(
            revealedIds: hidden,
            clearFirstFlip: true,
            checking: false,
          );
        });
      }
    }
  }
}
