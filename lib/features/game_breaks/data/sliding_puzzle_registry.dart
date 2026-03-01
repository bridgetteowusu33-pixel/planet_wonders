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
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_capecoast_castle.webp',
      label: '\u{1F3F0} Cape Coast Castle',
      historyFact: 'Did you know? This castle is over 370 years old and is '
          'so important that the whole world helps protect it!',
    ),
    PuzzleImageEntry(
      id: 'flagstaff',
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_flagstaffhouse.webp',
      label: '\u{1F3DB}\u{FE0F} Flagstaff House',
      historyFact: "Fun fact! This is where Ghana's president works and "
          'makes big decisions for the country.',
    ),
    PuzzleImageEntry(
      id: 'independence',
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_independence_square.webp',
      label: '\u{2B50} Independence Square',
      historyFact: 'Wow! This is where Ghana became free in 1957 \u{2014} '
          'the first country in sub-Saharan Africa to do so!',
    ),
    PuzzleImageEntry(
      id: 'kakum',
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_kakum.webp',
      label: '\u{1F333} Kakum National Park',
      historyFact: 'Amazing! You can walk high in the trees on a bridge '
          'almost as tall as a 10-story building!',
    ),
    PuzzleImageEntry(
      id: 'nkrumah',
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_kwame_nkrumah.webp',
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
      imagePath: 'assets/sliding_puzzles/nigeria/nigeria_monument_01_aso_rock.webp',
      label: '\u{1F3DB}\u{FE0F} Aso Rock',
      historyFact: 'Fun fact! Aso Rock is where the president of '
          'Nigeria lives and works, in the capital city Abuja.',
    ),
    PuzzleImageEntry(
      id: 'theatre',
      imagePath: 'assets/sliding_puzzles/nigeria/nigeria_monument_03_national_theatre.webp',
      label: '\u{1F3AD} National Theatre',
      historyFact: 'Wow! The National Theatre in Lagos is shaped like '
          'a military hat and hosts amazing plays, music, and dance!',
    ),
    PuzzleImageEntry(
      id: 'tinubu',
      imagePath: 'assets/sliding_puzzles/nigeria/nigeria_monument_04_tinubu_square.webp',
      label: '\u{2B50} Tinubu Square',
      historyFact: 'Did you know? Tinubu Square in Lagos is named after '
          'Madam Tinubu, a powerful trader and leader in Nigerian history.',
    ),
    PuzzleImageEntry(
      id: 'freedompark',
      imagePath: 'assets/sliding_puzzles/nigeria/nigeria_monument_05_freedom_park.webp',
      label: '\u{1F3DE}\u{FE0F} Freedom Park',
      historyFact: 'Amazing! Freedom Park in Lagos was once a prison but '
          'is now a beautiful park where people enjoy art and music.',
    ),
    PuzzleImageEntry(
      id: 'olumo',
      imagePath: 'assets/sliding_puzzles/nigeria/nigeria_monument_05_olumo_rock.webp',
      label: '\u{26F0}\u{FE0F} Olumo Rock',
      historyFact: 'Did you know? Olumo Rock in Abeokuta was used as a '
          'fortress during wars — people sheltered inside its caves!',
    ),
  ],
);

// ---------------------------------------------------------------------------
// UK — landmark photos
// ---------------------------------------------------------------------------

const _ukPuzzle = SlidingPuzzleData(
  countryId: 'uk',
  title: 'UK Sliding Puzzle',
  bgColor: Color(0xFFE8EAF6),
  puzzleImages: [
    PuzzleImageEntry(
      id: 'buckingham',
      imagePath: 'assets/sliding_puzzles/uk/buckingham.webp',
      label: '\u{1F451} Buckingham Palace',
      historyFact: 'Did you know? Buckingham Palace has 775 rooms '
          'and has been the royal family\'s London home since 1837!',
    ),
    PuzzleImageEntry(
      id: 'towerbridge',
      imagePath: 'assets/sliding_puzzles/uk/tower_bridge.webp',
      label: '\u{1F309} Tower Bridge',
      historyFact: 'Amazing! Tower Bridge can open in the middle to let '
          'tall ships pass through on the River Thames!',
    ),
    PuzzleImageEntry(
      id: 'bigben',
      imagePath: 'assets/sliding_puzzles/uk/big_ben.webp',
      label: '\u{1F554} Big Ben',
      historyFact: 'Fun fact! Big Ben is actually the nickname for the '
          'Great Bell inside the Elizabeth Tower at Parliament.',
    ),
    PuzzleImageEntry(
      id: 'stonehenge',
      imagePath: 'assets/sliding_puzzles/uk/stonehenge.webp',
      label: '\u{1FAA8} Stonehenge',
      historyFact: 'Wow! Stonehenge is about 5,000 years old and nobody '
          'knows exactly how the giant stones were moved there!',
    ),
    PuzzleImageEntry(
      id: 'doubledeckerbus',
      imagePath: 'assets/sliding_puzzles/uk/double_decker_bus.webp',
      label: '\u{1F68C} Double Decker Bus',
      historyFact: 'Did you know? London\u{2019}s red double decker buses '
          'have been around since 1956 and are a symbol of the city!',
    ),
    PuzzleImageEntry(
      id: 'redphonebox',
      imagePath: 'assets/sliding_puzzles/uk/red_phone_box.webp',
      label: '\u{260E}\u{FE0F} Red Phone Box',
      historyFact: 'Fun fact! The iconic red telephone box was designed '
          'in 1924 and there are still thousands across the UK!',
    ),
    PuzzleImageEntry(
      id: 'countryside',
      imagePath: 'assets/sliding_puzzles/uk/countryside.webp',
      label: '\u{1F33F} Countryside',
      historyFact: 'Amazing! The British countryside has rolling green '
          'hills, stone walls, and cosy villages hundreds of years old!',
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
  'uk': _ukPuzzle,
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
      imagePath: 'assets/sliding_puzzles/ghana/ghana_01_capecoast_castle.webp',
      label: 'Cape Coast Castle',
    ),
  ],
);
