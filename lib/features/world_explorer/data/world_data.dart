import '../models/continent.dart';
import '../models/country.dart';

/// Static seed data for the World Explorer.
///
/// Designed to be data-driven: add a country here and the UI picks it up
/// automatically — no screen changes needed.  For v1 MVP only Ghana is
/// unlocked; everything else is locked so kids see what's coming.
final List<Continent> worldContinents = [
  Continent(
    id: 'africa',
    name: 'Africa',
    emoji: '\u{1F30D}', // 🌍
    countries: [
      const Country(
        id: 'ghana',
        name: 'Ghana',
        flagEmoji: '\u{1F1EC}\u{1F1ED}', // 🇬🇭
        flagAsset: 'assets/flags/ghana.webp',
        continentId: 'africa',
        isUnlocked: true,
        greeting: 'Welcome to Ghana!',
        localGreeting: 'AKWAABA!',
      ),
      const Country(
        id: 'nigeria',
        name: 'Nigeria',
        flagEmoji: '\u{1F1F3}\u{1F1EC}', // 🇳🇬
        flagAsset: 'assets/flags/nigeria.webp',
        continentId: 'africa',
        isUnlocked: true,
        greeting: 'Welcome to Nigeria!',
      ),
      const Country(
        id: 'kenya',
        name: 'Kenya',
        flagEmoji: '\u{1F1F0}\u{1F1EA}', // 🇰🇪
        flagAsset: 'assets/flags/kenya.webp',
        continentId: 'africa',
        greeting: 'Welcome to Kenya!',
      ),
      const Country(
        id: 'egypt',
        name: 'Egypt',
        flagEmoji: '\u{1F1EA}\u{1F1EC}', // 🇪🇬
        flagAsset: 'assets/flags/egypt.webp',
        continentId: 'africa',
        greeting: 'Welcome to Egypt!',
      ),
      const Country(
        id: 'south_africa',
        name: 'South Africa',
        flagEmoji: '\u{1F1FF}\u{1F1E6}', // 🇿🇦
        flagAsset: 'assets/flags/south_africa.webp',
        continentId: 'africa',
        greeting: 'Welcome to South Africa!',
      ),
    ],
  ),
  Continent(
    id: 'asia',
    name: 'Asia',
    emoji: '\u{1F30F}', // 🌏
    countries: [
      const Country(
        id: 'japan',
        name: 'Japan',
        flagEmoji: '\u{1F1EF}\u{1F1F5}', // 🇯🇵
        flagAsset: 'assets/flags/japan.webp',
        continentId: 'asia',
        greeting: 'Welcome to Japan!',
      ),
      const Country(
        id: 'india',
        name: 'India',
        flagEmoji: '\u{1F1EE}\u{1F1F3}', // 🇮🇳
        flagAsset: 'assets/flags/india.webp',
        continentId: 'asia',
        greeting: 'Welcome to India!',
      ),
      const Country(
        id: 'south_korea',
        name: 'South Korea',
        flagEmoji: '\u{1F1F0}\u{1F1F7}', // 🇰🇷
        flagAsset: 'assets/flags/south_korea.webp',
        continentId: 'asia',
        greeting: 'Welcome to South Korea!',
      ),
      const Country(
        id: 'china',
        name: 'China',
        flagEmoji: '\u{1F1E8}\u{1F1F3}', // 🇨🇳
        flagAsset: 'assets/flags/china.webp',
        continentId: 'asia',
        greeting: 'Welcome to China!',
      ),
    ],
  ),
  Continent(
    id: 'europe',
    name: 'Europe',
    emoji: '\u{1F30D}', // 🌍
    countries: [
      const Country(
        id: 'italy',
        name: 'Italy',
        flagEmoji: '\u{1F1EE}\u{1F1F9}', // 🇮🇹
        flagAsset: 'assets/flags/italy.webp',
        continentId: 'europe',
        greeting: 'Welcome to Italy!',
      ),
      const Country(
        id: 'france',
        name: 'France',
        flagEmoji: '\u{1F1EB}\u{1F1F7}', // 🇫🇷
        flagAsset: 'assets/flags/france.webp',
        continentId: 'europe',
        greeting: 'Welcome to France!',
      ),
      const Country(
        id: 'uk',
        name: 'United Kingdom',
        flagEmoji: '\u{1F1EC}\u{1F1E7}', // 🇬🇧
        flagAsset: 'assets/flags/uk.webp',
        continentId: 'europe',
        greeting: 'Welcome to the UK!',
        isUnlocked: true,
      ),
      const Country(
        id: 'spain',
        name: 'Spain',
        flagEmoji: '\u{1F1EA}\u{1F1F8}', // 🇪🇸
        flagAsset: 'assets/flags/spain.webp',
        continentId: 'europe',
        greeting: 'Welcome to Spain!',
      ),
    ],
  ),
  Continent(
    id: 'north_america',
    name: 'North America',
    emoji: '\u{1F30E}', // 🌎
    countries: [
      const Country(
        id: 'mexico',
        name: 'Mexico',
        flagEmoji: '\u{1F1F2}\u{1F1FD}', // 🇲🇽
        flagAsset: 'assets/flags/mexico.png',
        continentId: 'north_america',
        greeting: 'Welcome to Mexico!',
      ),
      const Country(
        id: 'usa',
        name: 'United States',
        flagEmoji: '\u{1F1FA}\u{1F1F8}', // 🇺🇸
        flagAsset: 'assets/flags/usa.webp',
        continentId: 'north_america',
        isUnlocked: true,
        greeting: 'Welcome to the USA!',
      ),
      const Country(
        id: 'canada',
        name: 'Canada',
        flagEmoji: '\u{1F1E8}\u{1F1E6}', // 🇨🇦
        flagAsset: 'assets/flags/canada.webp',
        continentId: 'north_america',
        greeting: 'Welcome to Canada!',
      ),
    ],
  ),
  Continent(
    id: 'south_america',
    name: 'South America',
    emoji: '\u{1F30E}', // 🌎
    countries: [
      const Country(
        id: 'brazil',
        name: 'Brazil',
        flagEmoji: '\u{1F1E7}\u{1F1F7}', // 🇧🇷
        flagAsset: 'assets/flags/brazil.webp',
        continentId: 'south_america',
        greeting: 'Welcome to Brazil!',
      ),
      const Country(
        id: 'peru',
        name: 'Peru',
        flagEmoji: '\u{1F1F5}\u{1F1EA}', // 🇵🇪
        flagAsset: 'assets/flags/peru.webp',
        continentId: 'south_america',
        greeting: 'Welcome to Peru!',
      ),
      const Country(
        id: 'colombia',
        name: 'Colombia',
        flagEmoji: '\u{1F1E8}\u{1F1F4}', // 🇨🇴
        flagAsset: 'assets/flags/colombia.webp',
        continentId: 'south_america',
        greeting: 'Welcome to Colombia!',
      ),
    ],
  ),
  Continent(
    id: 'oceania',
    name: 'Oceania',
    emoji: '\u{1F30F}', // 🌏
    countries: [
      const Country(
        id: 'australia',
        name: 'Australia',
        flagEmoji: '\u{1F1E6}\u{1F1FA}', // 🇦🇺
        flagAsset: 'assets/flags/australia.webp',
        continentId: 'oceania',
        greeting: 'Welcome to Australia!',
      ),
      const Country(
        id: 'new_zealand',
        name: 'New Zealand',
        flagEmoji: '\u{1F1F3}\u{1F1FF}', // 🇳🇿
        flagAsset: 'assets/flags/new_zealand.webp',
        continentId: 'oceania',
        greeting: 'Welcome to New Zealand!',
      ),
    ],
  ),
];

/// Quick lookup helpers so screens don't need to search lists.
Continent? findContinent(String id) {
  for (final c in worldContinents) {
    if (c.id == id) return c;
  }
  return null;
}

Country? findCountry(String continentId, String countryId) {
  final continent = findContinent(continentId);
  if (continent == null) return null;
  for (final country in continent.countries) {
    if (country.id == countryId) return country;
  }
  return null;
}

/// Finds a country across all continents by ID alone.
Country? findCountryById(String countryId) {
  for (final continent in worldContinents) {
    for (final country in continent.countries) {
      if (country.id == countryId) return country;
    }
  }
  return null;
}
