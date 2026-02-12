import '../models/coloring_page.dart';
import '../painters/ghana_outlines.dart';
import '../painters/usa_outlines.dart';

/// All coloring pages grouped by country.
///
/// Data-driven: add pages here and every screen picks them up.
final Map<String, List<ColoringPage>> coloringRegistry = {
  'ghana': _ghanaPages,
  'usa': _usaPages,
};

final _ghanaPages = [
  ColoringPage(
    id: 'kente',
    title: 'Kente Pattern',
    countryId: 'ghana',
    emoji: '\u{1F3A8}', // 🎨
    paintOutline: paintKentePattern,
    fact: 'Kente cloth is woven by the Ashanti people. Each colour '
        'and pattern tells a different story!',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'drum',
    title: 'Talking Drum',
    countryId: 'ghana',
    emoji: '\u{1F941}', // 🥁
    paintOutline: paintTalkingDrum,
    fact: 'The talking drum can mimic human speech! Drummers squeeze '
        'the strings to change the pitch.',
    factCategory: 'Music',
  ),
  ColoringPage(
    id: 'adinkra',
    title: 'Adinkra Symbol',
    countryId: 'ghana',
    emoji: '\u{1F300}', // 🌀
    paintOutline: paintAdinkraSymbol,
    fact: 'Adinkra symbols come from the Ashanti people. "Gye Nyame" '
        'means "Except God" and represents the power of the creator.',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'star',
    title: 'Ghana Star',
    countryId: 'ghana',
    emoji: '\u{2B50}', // ⭐
    paintOutline: paintGhanaStar,
    fact: 'The black star on Ghana\'s flag is called the "Lodestar of '
        'African Freedom." Ghana was the first African country south '
        'of the Sahara to gain independence!',
    factCategory: 'History',
  ),
];

final _usaPages = [
  ColoringPage(
    id: 'landmarks',
    title: 'American Landmarks',
    countryId: 'usa',
    emoji: '\u{1F5FD}', // 🗽
    paintOutline: paintAmericanLandmarks,
    fact: 'The Statue of Liberty was a gift from France in 1886! '
        'Her real name is "Liberty Enlightening the World."',
    factCategory: 'History',
  ),
  ColoringPage(
    id: 'kids',
    title: 'Kids of America',
    countryId: 'usa',
    emoji: '\u{1F9D2}', // 🧒
    paintOutline: paintKidsOfAmerica,
    fact: 'America is called a "melting pot" because people from '
        'all over the world live here together!',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'jazz',
    title: 'Music & Jazz',
    countryId: 'usa',
    emoji: '\u{1F3B7}', // 🎷
    paintOutline: paintMusicJazz,
    fact: 'Jazz music was born in New Orleans! It blends African '
        'rhythms, blues, and ragtime into something totally new.',
    factCategory: 'Music',
  ),
  ColoringPage(
    id: 'nature',
    title: 'National Parks',
    countryId: 'usa',
    emoji: '\u{1F3D4}', // 🏔
    paintOutline: paintNationalParks,
    fact: 'Yellowstone became the world\'s first national park in 1872! '
        'America has over 60 national parks today.',
    factCategory: 'Nature',
  ),
  ColoringPage(
    id: 'food',
    title: 'Food Favorites',
    countryId: 'usa',
    emoji: '\u{1F354}', // 🍔
    paintOutline: paintFoodFavorites,
    fact: 'Americans eat about 50 billion hamburgers every year! '
        'That\'s enough to circle the Earth over 32 times.',
    factCategory: 'Fun Fact',
  ),
  ColoringPage(
    id: 'transport',
    title: 'Transportation & Cities',
    countryId: 'usa',
    emoji: '\u{1F695}', // 🚕
    paintOutline: paintTransportCities,
    fact: 'New York City\'s subway has 472 stations — more than any '
        'other subway system in the world!',
    factCategory: 'Fun Fact',
  ),
  ColoringPage(
    id: 'map',
    title: 'US Map',
    countryId: 'usa',
    emoji: '\u{1F5FA}', // 🗺
    paintOutline: paintUSMap,
    fact: 'The United States has 50 states, and the two newest — '
        'Alaska and Hawaii — joined in 1959!',
    factCategory: 'Geography',
  ),
];

/// All pages across every country, preserving registry order.
List<ColoringPage> get allColoringPages =>
    coloringRegistry.values.expand((pages) => pages).toList();

/// Quick lookups.
List<ColoringPage> pagesForCountry(String countryId) =>
    coloringRegistry[countryId] ?? [];

ColoringPage? findColoringPage(String countryId, String pageId) {
  final pages = pagesForCountry(countryId);
  for (final page in pages) {
    if (page.id == pageId) return page;
  }
  return null;
}
