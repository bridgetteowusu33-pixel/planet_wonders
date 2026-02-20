import 'dart:ui';

import '../models/sliding_puzzle_types.dart';
import '../painters/puzzle_painters.dart';

// ---------------------------------------------------------------------------
// Ghana — landmark photos
// ---------------------------------------------------------------------------

const _ghanaPuzzle = SlidingPuzzleData(
  countryId: 'ghana',
  title: 'Ghana Sliding Puzzle',
  bgColor: Color(0xFFFFF3D0),
  puzzleImages: [
    PuzzleImageEntry(
      id: 'capecoast',
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_capecoast_castle.jpg',
      label: '\u{1F3F0} Cape Coast Castle',
      historyFact: 'Did you know? This castle is over 370 years old and is '
          'so important that the whole world helps protect it!',
    ),
    PuzzleImageEntry(
      id: 'flagstaff',
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_flagstaffhouse.jpg',
      label: '\u{1F3DB}\u{FE0F} Flagstaff House',
      historyFact: "Fun fact! This is where Ghana's president works and "
          'makes big decisions for the country.',
    ),
    PuzzleImageEntry(
      id: 'independence',
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_independence_square.jpg',
      label: '\u{2B50} Independence Square',
      historyFact: 'Wow! This is where Ghana became free in 1957 \u{2014} '
          'the first country in sub-Saharan Africa to do so!',
    ),
    PuzzleImageEntry(
      id: 'kakum',
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_kakum.jpg',
      label: '\u{1F333} Kakum National Park',
      historyFact: 'Amazing! You can walk high in the trees on a bridge '
          'almost as tall as a 10-story building!',
    ),
    PuzzleImageEntry(
      id: 'nkrumah',
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_kwame_nkrumah.jpg',
      label: '\u{1F1EC}\u{1F1ED} Kwame Nkrumah Memorial Park',
      historyFact: 'Did you know? Dr. Kwame Nkrumah helped Ghana gain '
          "freedom and became the country's first president.",
    ),
  ],
);

// ---------------------------------------------------------------------------
// USA — flag, landmarks
// ---------------------------------------------------------------------------

const _usaPuzzle = SlidingPuzzleData(
  countryId: 'usa',
  title: 'USA Sliding Puzzle',
  bgColor: Color(0xFFE3F2FD),
  puzzleImages: [
    PuzzleImageEntry(
      id: 'flag',
      painter: UsaFlagPainter(),
      label: 'USA Flag',
    ),
    PuzzleImageEntry(
      id: 'landmarks',
      painter: UsaLandmarksPainter(),
      label: 'Landmarks',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Nigeria — landmark photos
// ---------------------------------------------------------------------------

const _nigeriaPuzzle = SlidingPuzzleData(
  countryId: 'nigeria',
  title: 'Nigeria Sliding Puzzle',
  bgColor: Color(0xFFE8F5E9),
  puzzleImages: [
    PuzzleImageEntry(
      id: 'asorock',
      imagePath: 'assets/sliding_puzzles/nigeria/nigeria_monument_01_aso_rock.jpg',
      label: '\u{1F3DB}\u{FE0F} Aso Rock',
      historyFact: 'Fun fact! Aso Rock is where the president of '
          'Nigeria lives and works, in the capital city Abuja.',
    ),
    PuzzleImageEntry(
      id: 'theatre',
      imagePath: 'assets/sliding_puzzles/nigeria/nigeria_monument_03_national_theatre.png',
      label: '\u{1F3AD} National Theatre',
      historyFact: 'Wow! The National Theatre in Lagos is shaped like '
          'a military hat and hosts amazing plays, music, and dance!',
    ),
    PuzzleImageEntry(
      id: 'tinubu',
      imagePath: 'assets/sliding_puzzles/nigeria/nigeria_monument_04_tinubu_square.jpg',
      label: '\u{2B50} Tinubu Square',
      historyFact: 'Did you know? Tinubu Square in Lagos is named after '
          'Madam Tinubu, a powerful trader and leader in Nigerian history.',
    ),
    PuzzleImageEntry(
      id: 'freedompark',
      imagePath: 'assets/sliding_puzzles/nigeria/nigeria_monument_05_freedom_park.jpg',
      label: '\u{1F3DE}\u{FE0F} Freedom Park',
      historyFact: 'Amazing! Freedom Park in Lagos was once a prison but '
          'is now a beautiful park where people enjoy art and music.',
    ),
    PuzzleImageEntry(
      id: 'olumo',
      imagePath: 'assets/sliding_puzzles/nigeria/nigeria_monument_05_olumo_rock.jpg',
      label: '\u{26F0}\u{FE0F} Olumo Rock',
      historyFact: 'Did you know? Olumo Rock in Abeokuta was used as a '
          'fortress during wars — people sheltered inside its caves!',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Registry
// ---------------------------------------------------------------------------

/// All sliding puzzle data, keyed by country ID.
final Map<String, SlidingPuzzleData> slidingPuzzleRegistry = {
  'ghana': _ghanaPuzzle,
  'usa': _usaPuzzle,
  'nigeria': _nigeriaPuzzle,
};

/// Quick lookup — returns themed data or null.
SlidingPuzzleData? findSlidingPuzzleData(String countryId) =>
    slidingPuzzleRegistry[countryId];

/// Fallback: Cape Coast Castle for countries without themed data.
const fallbackSlidingPuzzle = SlidingPuzzleData(
  countryId: 'generic',
  title: 'Sliding Puzzle',
  bgColor: Color(0xFFF3E5F5),
  puzzleImages: [
    PuzzleImageEntry(
      id: 'capecoast',
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_capecoast_castle.jpg',
      label: 'Cape Coast Castle',
    ),
  ],
);
