import 'dart:ui';

/// The five game types. Only [memoryMatch] is implemented in MVP.
enum GameType {
  memoryMatch,
  patternMatch,
  tapTheItem,
  miniJigsaw,
  colorBurst,
}

/// A pair of matching items for Memory Match.
class MatchPair {
  const MatchPair({
    required this.id,
    required this.emoji,
    required this.label,
  });

  final String id; // e.g. 'drum'
  final String emoji;
  final String label;
}

/// A single card in a Memory Match game.
class MatchCard {
  const MatchCard({
    required this.id,
    required this.pairId,
    required this.emoji,
    required this.label,
  });

  final String id; // unique per card instance: 'drum_0', 'drum_1'
  final String pairId; // shared by the two cards that match: 'drum'
  final String emoji;
  final String label;
}

/// Country-themed data for one Memory Match round.
class MemoryMatchData {
  const MemoryMatchData({
    required this.countryId,
    required this.title,
    required this.bgColor,
    required this.pairs,
  });

  final String countryId;
  final String title; // e.g. "Ghana Memory Match"
  final Color bgColor;
  final List<MatchPair> pairs; // 4 pairs → 8 cards
}
