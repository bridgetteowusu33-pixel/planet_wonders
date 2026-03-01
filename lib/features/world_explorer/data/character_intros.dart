// Character introduction data for each country.
//
// Used by the "Meet the Characters" section on the country hub to let each
// country's character(s) introduce themselves, share their name meaning,
// and tell the user about the country.

class CharacterIntro {
  const CharacterIntro({
    required this.countryId,
    required this.characterName,
    required this.characterEmoji,
    required this.characterAvatar,
    required this.greeting,
    required this.nameMeaning,
    required this.selfIntro,
    required this.countryFacts,
    required this.signOff,
  });

  final String countryId;
  final String characterName;
  final String characterEmoji;

  /// Path to the character's illustrated avatar image.
  final String characterAvatar;

  /// First line greeting, e.g. "Hi there! I'm Afia!"
  final String greeting;

  /// Name meaning shown in a tappable bubble.
  final String nameMeaning;

  /// 2-3 sentence self introduction.
  final String selfIntro;

  /// Short fun facts about the country (shown as animated cards).
  final List<String> countryFacts;

  /// Sign-off message inviting the kid to explore.
  final String signOff;
}

// ---------------------------------------------------------------------------
// Per-country character introductions
// ---------------------------------------------------------------------------

const ghanaIntro = CharacterIntro(
  countryId: 'ghana',
  characterName: 'Afia',
  characterEmoji: '\u{1F467}\u{1F3FE}', // 👧🏾
  characterAvatar: 'assets/v2/ghana/afia/afia_happy.webp',
  greeting: 'Hi there! I\u{2019}m Afia!',
  nameMeaning:
      'My name means "born on Friday" in the Akan language of Ghana.',
  selfIntro:
      'I love cooking jollof rice with my grandma and dancing to highlife '
      'music. Ghana is called the "Gateway to Africa" and our people are '
      'famous for being super friendly!',
  countryFacts: [
    'Ghana was the first African country south of the Sahara to gain independence!',
    'Lake Volta in Ghana is one of the largest man-made lakes in the world.',
    'Ghanaians love colourful kente cloth \u{2014} every pattern tells a story!',
  ],
  signOff: 'Come explore Ghana with me! There\u{2019}s so much to discover!',
);

const nigeriaIntro = CharacterIntro(
  countryId: 'nigeria',
  characterName: 'Adetutu',
  characterEmoji: '\u{1F467}\u{1F3FE}', // 👧🏾
  characterAvatar: 'assets/v2/nigreia/adetutu/happy.webp',
  greeting: 'Hey! My name is Adetutu!',
  nameMeaning:
      'My name means "the crown is calm" in Yoruba \u{2014} like royalty!',
  selfIntro:
      'I\u{2019}m from Lagos, the biggest city in all of Africa! I love '
      'making suya with my dad and watching Nollywood movies. Nigeria has '
      'over 250 different languages \u{2014} how cool is that?',
  countryFacts: [
    'Nigeria is called the "Giant of Africa" because it has the most people!',
    'Nollywood makes more movies than Hollywood every year.',
    'The ancient Benin Kingdom created amazing bronze sculptures hundreds of years ago.',
  ],
  signOff:
      'Let\u{2019}s have fun learning about my beautiful country together!',
);

const usaIntro = CharacterIntro(
  countryId: 'usa',
  characterName: 'Ava',
  characterEmoji: '\u{1F469}', // 👩
  characterAvatar: 'assets/v2/USA/ava/ava_happy.webp',
  greeting: 'Hey there! I\u{2019}m Ava!',
  nameMeaning: 'My name means "life" \u{2014} and I love living it to the fullest!',
  selfIntro:
      'I live in Fredericksburg, Virginia \u{2014} a beautiful town with rivers, '
      'parks, and lots of history to explore.\n\n'
      'But I was born in Huntsville, Alabama \u{2014} a city known as '
      '\u{201C}The Rocket City\u{201D} because scientists and engineers there '
      'build real rockets that go to space!\n\n'
      'That means my story started in a place full of big dreams and stars\u{2026} '
      'and now I\u{2019}m growing up in a town filled with adventure and discovery.\n\n'
      'I love learning about different countries, trying new foods, visiting '
      'museums, and imagining where I\u{2019}ll travel next.\n\n'
      'The United States is a big country with 50 states \u{2014} and each one '
      'has something special to discover!',
  countryFacts: [
    'Fredericksburg is famous for its history and beautiful river views.',
    'Huntsville helped send astronauts to the moon!',
    'The USA has mountains, beaches, forests, deserts, and even space centres!',
  ],
  signOff: 'Ready to explore the USA with me? Let\u{2019}s go!',
);

const ukIntro = CharacterIntro(
  countryId: 'uk',
  characterName: 'Heze & Aza',
  characterEmoji: '\u{1F467}\u{1F3FD}\u{1F9D1}\u{1F3FD}', // 👧🏽🧑🏽
  characterAvatar: 'assets/v2/uk/twins/twins_happy.webp',
  greeting: 'Hello! We\u{2019}re Heze and Aza!',
  nameMeaning:
      'Our names are short for Hezekiah and Azariah \u{2014} they\u{2019}re '
      'Hebrew names that mean "God strengthens" and "God has helped."',
  selfIntro:
      'We\u{2019}re twins from London! Heze loves spotting patterns '
      'everywhere \u{2014} you might notice his blue headphones. Aza loves '
      'baking scones and exploring old castles. The UK is made up of four '
      'countries: England, Scotland, Wales, and Northern Ireland!',
  countryFacts: [
    'Big Ben is actually the name of the bell inside the tower, not the tower itself!',
    'The UK invented football (soccer), the World Wide Web, and Harry Potter!',
    'The Queen\u{2019}s Guard soldiers outside Buckingham Palace are not allowed to smile!',
  ],
  signOff:
      'Fancy an adventure? Let\u{2019}s explore the UK together!',
);

// ---------------------------------------------------------------------------
// Registry lookup
// ---------------------------------------------------------------------------

const _introsByCountry = <String, CharacterIntro>{
  'ghana': ghanaIntro,
  'nigeria': nigeriaIntro,
  'usa': usaIntro,
  'uk': ukIntro,
};

/// Returns the character intro for [countryId], or `null` for countries that
/// don't have one yet (locked countries).
CharacterIntro? characterIntroFor(String countryId) =>
    _introsByCountry[countryId];
