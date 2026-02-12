import 'dart:ui';

import '../models/game_break_types.dart';

// ---------------------------------------------------------------------------
// Ghana — drums, beads, kente, crowns
// ---------------------------------------------------------------------------

const _ghanaMemoryMatch = MemoryMatchData(
  countryId: 'ghana',
  title: 'Ghana Memory Match',
  bgColor: Color(0xFFFFF3D0),
  pairs: [
    MatchPair(id: 'drum', emoji: '\u{1F941}', label: 'Drum'), // 🥁
    MatchPair(id: 'bead', emoji: '\u{1F4FF}', label: 'Beads'), // 📿
    MatchPair(id: 'kente', emoji: '\u{1F3A8}', label: 'Kente'), // 🎨
    MatchPair(id: 'crown', emoji: '\u{1F451}', label: 'Crown'), // 👑
  ],
);

// ---------------------------------------------------------------------------
// USA — stars, flags, rockets, mountains
// ---------------------------------------------------------------------------

const _usaMemoryMatch = MemoryMatchData(
  countryId: 'usa',
  title: 'USA Memory Match',
  bgColor: Color(0xFFE3F2FD),
  pairs: [
    MatchPair(id: 'star', emoji: '\u{2B50}', label: 'Star'), // ⭐
    MatchPair(
        id: 'flag',
        emoji: '\u{1F1FA}\u{1F1F8}',
        label: 'Flag'), // 🇺🇸
    MatchPair(id: 'rocket', emoji: '\u{1F680}', label: 'Rocket'), // 🚀
    MatchPair(
        id: 'mountain',
        emoji: '\u{1F3D4}\u{FE0F}',
        label: 'Mountain'), // 🏔️
  ],
);

// ---------------------------------------------------------------------------
// Nigeria — masks, drums, fabric, stars
// ---------------------------------------------------------------------------

const _nigeriaMemoryMatch = MemoryMatchData(
  countryId: 'nigeria',
  title: 'Nigeria Memory Match',
  bgColor: Color(0xFFE8F5E9),
  pairs: [
    MatchPair(id: 'mask', emoji: '\u{1F3AD}', label: 'Mask'), // 🎭
    MatchPair(id: 'drum', emoji: '\u{1F941}', label: 'Drum'), // 🥁
    MatchPair(id: 'fabric', emoji: '\u{1F9F5}', label: 'Fabric'), // 🧵
    MatchPair(id: 'star', emoji: '\u{2B50}', label: 'Star'), // ⭐
  ],
);

// ---------------------------------------------------------------------------
// Japan — origami, lanterns, cherry blossoms, fans
// ---------------------------------------------------------------------------

const _japanMemoryMatch = MemoryMatchData(
  countryId: 'japan',
  title: 'Japan Memory Match',
  bgColor: Color(0xFFFCE4EC),
  pairs: [
    MatchPair(id: 'crane', emoji: '\u{1F9A2}', label: 'Crane'), // 🦢
    MatchPair(id: 'lantern', emoji: '\u{1F3EE}', label: 'Lantern'), // 🏮
    MatchPair(id: 'cherry', emoji: '\u{1F338}', label: 'Cherry'), // 🌸
    MatchPair(id: 'fan', emoji: '\u{1FA87}', label: 'Fan'), // 🪇 (or similar)
  ],
);

// ---------------------------------------------------------------------------
// India — elephants, peacocks, lotus, stars
// ---------------------------------------------------------------------------

const _indiaMemoryMatch = MemoryMatchData(
  countryId: 'india',
  title: 'India Memory Match',
  bgColor: Color(0xFFFFF8E1),
  pairs: [
    MatchPair(id: 'elephant', emoji: '\u{1F418}', label: 'Elephant'), // 🐘
    MatchPair(id: 'peacock', emoji: '\u{1F99A}', label: 'Peacock'), // 🦚
    MatchPair(id: 'lotus', emoji: '\u{1FAB7}', label: 'Lotus'), // 🪷
    MatchPair(id: 'star', emoji: '\u{2B50}', label: 'Star'), // ⭐
  ],
);

// ---------------------------------------------------------------------------
// Brazil — parrots, music, soccer, sun
// ---------------------------------------------------------------------------

const _brazilMemoryMatch = MemoryMatchData(
  countryId: 'brazil',
  title: 'Brazil Memory Match',
  bgColor: Color(0xFFF1F8E9),
  pairs: [
    MatchPair(id: 'parrot', emoji: '\u{1F99C}', label: 'Parrot'), // 🦜
    MatchPair(id: 'music', emoji: '\u{1F3B6}', label: 'Music'), // 🎶
    MatchPair(id: 'soccer', emoji: '\u{26BD}', label: 'Soccer'), // ⚽
    MatchPair(id: 'sun', emoji: '\u{2600}\u{FE0F}', label: 'Sun'), // ☀️
  ],
);

// ---------------------------------------------------------------------------
// Registry
// ---------------------------------------------------------------------------

/// All memory match data, keyed by country ID.
final Map<String, MemoryMatchData> memoryMatchRegistry = {
  'ghana': _ghanaMemoryMatch,
  'usa': _usaMemoryMatch,
  'nigeria': _nigeriaMemoryMatch,
  'japan': _japanMemoryMatch,
  'india': _indiaMemoryMatch,
  'brazil': _brazilMemoryMatch,
};

/// Quick lookup — returns themed data or null.
MemoryMatchData? findMemoryMatchData(String countryId) =>
    memoryMatchRegistry[countryId];

/// Fallback: generic emoji set for countries without themed data.
const fallbackMemoryMatch = MemoryMatchData(
  countryId: 'generic',
  title: 'Memory Match',
  bgColor: Color(0xFFF3E5F5),
  pairs: [
    MatchPair(id: 'star', emoji: '\u{2B50}', label: 'Star'), // ⭐
    MatchPair(
        id: 'heart', emoji: '\u{2764}\u{FE0F}', label: 'Heart'), // ❤️
    MatchPair(id: 'sun', emoji: '\u{2600}\u{FE0F}', label: 'Sun'), // ☀️
    MatchPair(id: 'moon', emoji: '\u{1F319}', label: 'Moon'), // 🌙
  ],
);
