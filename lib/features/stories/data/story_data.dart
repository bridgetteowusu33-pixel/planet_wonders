import 'dart:ui';

import '../models/story.dart';

// ---------------------------------------------------------------------------
// Ghana — "Afia's Colorful Day in Ghana"
// ---------------------------------------------------------------------------

const _ghanaStory = Story(
  countryId: 'ghana',
  title: "Afia's Colorful Day in Ghana",
  badgeName: 'Ghana Story Explorer',
  pages: [
    // Page 1 — Meet Afia
    StoryPage(
      title: 'Meet Afia',
      text:
          'This is Afia! She lives in Kumasi, a big and busy city in Ghana.\n\n'
          'Today is a special day — Afia is wearing her favourite Kente cloth, '
          'a beautiful fabric made of bright colours woven together.',
      emoji: '\u{1F467}\u{1F3FE}', // 👧🏾
      bgColor: Color(0xFFFFF3D0), // warm yellow tint
      fact: 'Kente cloth tells stories with its colours and patterns. '
          'Each design has a special meaning!',
      factCategory: 'Culture',
    ),

    // Page 2 — Market Day
    StoryPage(
      title: 'Market Day',
      text:
          'Afia walks through the busy Kejetia market with her grandmother.\n\n'
          'She sees piles of golden mangoes, stacks of colourful fabrics, '
          'and baskets overflowing with warm spices. The air smells amazing!',
      emoji: '\u{1F6D2}', // 🛒
      bgColor: Color(0xFFFFE5CC), // warm orange tint
      fact: 'Kejetia Market in Kumasi is one of the largest open-air '
          'markets in West Africa!',
      factCategory: 'Culture',
    ),

    // Page 3 — The Talking Drum
    StoryPage(
      title: 'The Talking Drum',
      text:
          'In the town square, a drummer plays a very special drum.\n\n'
          'Afia listens closely — the drum seems to speak! '
          'It goes high and low, fast and slow, '
          'sending messages through its rhythm.',
      emoji: '\u{1F941}', // 🥁
      bgColor: Color(0xFFE8F5E9), // soft green tint
      fact: 'Talking drums can copy the rise and fall of human speech. '
          'People use them to send messages across long distances!',
      factCategory: 'History',
    ),

    // Page 4 — The Golden Stool
    StoryPage(
      title: 'The Golden Stool',
      text:
          "Afia's grandmother tells her about the Golden Stool — "
          'a sacred symbol of the Ashanti people.\n\n'
          '"It reminds us that we are strong together," '
          'Grandma says with a warm smile. Afia feels proud of her home.',
      emoji: '\u{1F451}', // 👑
      bgColor: Color(0xFFFFF8E1), // golden tint
      fact: 'The Golden Stool is very important to the Ashanti people '
          'of Ghana. It represents unity and the soul of the nation.',
      factCategory: 'History',
    ),
  ],
);

// ---------------------------------------------------------------------------
// United States — "Ava's Journey Through America"
// ---------------------------------------------------------------------------

const _usaStory = Story(
  countryId: 'usa',
  title: "Ava's Journey Through America",
  badgeName: 'USA Story Explorer',
  pages: [
    // Page 1 — Where Ava Was Born
    StoryPage(
      title: 'Where Ava Was Born',
      text:
          'Meet Ava! She was born in Huntsville, Alabama.\n\n'
          'Huntsville is called the "Rocket City" because scientists there '
          'helped build rockets that flew all the way to the Moon! '
          'Ava loves looking up at the stars and dreaming big.',
      emoji: '\u{1F680}', // 🚀
      bgColor: Color(0xFFE3F2FD),
      imagePath: 'assets/stories/usa/page_1.png',
      fact: 'The Saturn V rocket that took astronauts to the Moon was '
          'built in Huntsville. You can see a real one at the U.S. Space '
          '& Rocket Center!',
      factCategory: 'Science',
    ),

    // Page 2 — A New Home in Virginia
    StoryPage(
      title: 'A New Home in Virginia',
      text:
          'Ava and her family move to Virginia — a state full of history.\n\n'
          'They drive past rolling green hills and old brick buildings. '
          '"This is where America began," her mom tells her. '
          'Ava can not wait to explore!',
      emoji: '\u{1F3E0}', // 🏠
      bgColor: Color(0xFFE8F5E9),
      imagePath: 'assets/stories/usa/page_2.png',
      fact: 'Virginia was one of the original 13 colonies and the birthplace '
          'of eight American presidents — more than any other state!',
      factCategory: 'History',
    ),

    // Page 3 — Learning About History
    StoryPage(
      title: 'Learning About History',
      text:
          'At school, Ava learns about people who changed the world.\n\n'
          'She reads about brave leaders who fought for fairness and '
          'equality, so that all children — no matter who they are — '
          'could learn, play, and dream together.',
      emoji: '\u{1F4DA}', // 📚
      bgColor: Color(0xFFFFF3E0),
      imagePath: 'assets/stories/usa/page_3.png',
      fact: 'The Civil Rights Movement helped change unfair laws. '
          'Leaders like Dr. Martin Luther King Jr. dreamed of a world '
          'where everyone is treated equally.',
      factCategory: 'History',
    ),

    // Page 4 — Exploring America
    StoryPage(
      title: 'Exploring America',
      text:
          'Ava loves discovering how big and beautiful America is.\n\n'
          'From the sandy beaches of California to the snowy mountains '
          'of Colorado, every state has something special. '
          '"There\'s so much to explore!" Ava says with a big smile.',
      emoji: '\u{1F30E}', // 🌎
      bgColor: Color(0xFFFCE4EC),
      imagePath: 'assets/stories/usa/page_4.png',
      fact: 'America has 63 national parks! Yellowstone was the very first '
          'national park in the world, created in 1872.',
      factCategory: 'Nature',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Nigeria — "Adetutu's Adventure in Nigeria"
// ---------------------------------------------------------------------------

const _nigeriaStory = Story(
  countryId: 'nigeria',
  title: "Adetutu's Adventure in Nigeria",
  badgeName: 'Nigeria Story Explorer',
  pages: [
    // Page 1 — Meet Adetutu
    StoryPage(
      title: 'Meet Adetutu',
      text:
          'This is Adetutu! She lives in Lagos, one of the biggest '
          'and busiest cities in all of Africa.\n\n'
          'Today she is wearing a beautiful Ankara dress with bright '
          'patterns — she is ready for a special day!',
      emoji: '\u{1F467}\u{1F3FE}', // 👧🏾
      bgColor: Color(0xFFE8F5E9),
      imagePath: 'assets/stories/nigeria/page_1.png',
      fact: 'Lagos is the largest city in Africa with over 20 million '
          'people — that is more than many whole countries!',
      factCategory: 'Geography',
    ),

    // Page 2 — The Bustling Market
    StoryPage(
      title: 'The Bustling Market',
      text:
          'Adetutu walks through Balogun Market with her auntie.\n\n'
          'She sees towers of colourful fabrics, baskets of juicy '
          'oranges, and traders calling out in Yoruba and Igbo. '
          'The energy is amazing!',
      emoji: '\u{1F6D2}', // 🛒
      bgColor: Color(0xFFFFF3E0),
      imagePath: 'assets/stories/nigeria/page_2.png',
      fact: 'Nigeria has over 250 different languages — more than '
          'almost any other country in the world!',
      factCategory: 'Culture',
    ),

    // Page 3 — Rhythms of Nigeria
    StoryPage(
      title: 'Rhythms of Nigeria',
      text:
          'In the town square, Adetutu watches musicians play the '
          'dundun, a beautiful talking drum.\n\n'
          'The drum speaks in high and low tones, and people dance '
          'and clap along. Adetutu taps her feet to the beat!',
      emoji: '\u{1F941}', // 🥁
      bgColor: Color(0xFFFCE4EC),
      imagePath: 'assets/stories/nigeria/page_3.png',
      fact: 'Afrobeats is a popular music genre that started in Nigeria '
          'and is now loved all around the world!',
      factCategory: 'Culture',
    ),

    // Page 4 — A Land of Stories
    StoryPage(
      title: 'A Land of Stories',
      text:
          "Adetutu's grandmother tells her about Zuma Rock — "
          'a giant rock that towers over the land like a sleeping guardian.\n\n'
          '"Nigeria is full of wonders," Grandma says with a warm smile. '
          'Adetutu feels proud of her beautiful home.',
      emoji: '\u{26F0}\u{FE0F}', // ⛰️
      bgColor: Color(0xFFFFF8E1),
      imagePath: 'assets/stories/nigeria/page_4.png',
      fact: 'Zuma Rock is a massive 725-metre rock near Abuja. '
          "Some people call it the 'Gateway to Abuja!'",
      factCategory: 'Nature',
    ),
  ],
);

// ---------------------------------------------------------------------------
// United Kingdom — "Hezekiah & Azariah: Twins in London"
// ---------------------------------------------------------------------------

const _ukStory = Story(
  countryId: 'uk',
  title: 'Hezekiah & Azariah: Twins in London',
  badgeName: 'UK Story Explorer',
  pages: [
    // Page 1 — Our Big, Busy City
    StoryPage(
      title: 'Our Big, Busy City',
      text:
          'Hezekiah and Azariah are twins who live in London, '
          'a big city full of buses, bridges, and bright lights.\n\n'
          'Hezekiah, called Heze, loves quiet places and patterns. '
          'He notices tiny details, like how raindrops race down windows. '
          'Loud noises sometimes make him feel overwhelmed, '
          'so he carries his special blue headphones.\n\n'
          'Azariah, called Aza, loves talking, laughing, and asking questions. '
          'She enjoys helping her brother when things feel too busy.\n\n'
          'Every morning, they look out their window and smile.\n'
          '\u{201C}London is our home,\u{201D} Aza says.\n'
          '\u{201C}And it\u{2019}s full of shapes and sounds,\u{201D} '
          'Heze adds softly.',
      emoji: '\u{1F467}\u{1F3FD}', // 👧🏽
      bgColor: Color(0xFFE3F2FD), // light blue tint
      imagePath: 'assets/stories/uk/page_1.png',
      fact: 'London is one of the biggest cities in Europe with '
          'nearly 9 million people! It has been an important city '
          'for over 2,000 years.',
      factCategory: 'Geography',
    ),

    // Page 2 — A Trip Across the Thames
    StoryPage(
      title: 'A Trip Across the Thames',
      text:
          'One sunny afternoon, Mum takes the twins to see '
          'the River Thames.\n\n'
          'They walk across Tower Bridge, watching boats float below.\n\n'
          '\u{201C}Look!\u{201D} Aza points. '
          '\u{201C}That boat is shaped like a triangle!\u{201D}\n\n'
          'Heze smiles. \u{201C}And that one makes waves in perfect lines.\u{201D}\n\n'
          'Suddenly, a bus honks loudly. Heze feels nervous and covers his ears.\n\n'
          'Aza gently holds his hand.\n'
          '\u{201C}It\u{2019}s okay, Heze. Let\u{2019}s count the red buses together.\u{201D}\n\n'
          '\u{201C}One\u{2026} two\u{2026} three\u{2026}\u{201D} Heze whispers.\n\n'
          'Soon, he feels calm again.\n\n'
          'Together, they watch the water sparkle like tiny stars.',
      emoji: '\u{1F309}', // 🌉
      bgColor: Color(0xFFFFF8E1), // golden tint
      imagePath: 'assets/stories/uk/page_2.png',
      fact: 'Tower Bridge was built in 1894 and can open in the middle '
          'to let tall ships pass through on the River Thames!',
      factCategory: 'History',
    ),

    // Page 3 — Learning in Their Own Way
    StoryPage(
      title: 'Learning in Their Own Way',
      text:
          'At school, Heze and Aza sit side by side.\n\n'
          'Today, they are learning about famous people from Britain.\n\n'
          'Their teacher says,\n'
          '\u{201C}Everyone learns differently \u{2014} and that\u{2019}s wonderful.\u{201D}\n\n'
          'Heze uses colourful cards to organise his thoughts.\n'
          'Aza writes stories and draws pictures.\n\n'
          'When it\u{2019}s time for group work, Aza helps explain ideas.\n'
          'Heze notices details others miss.\n\n'
          '\u{201C}You\u{2019}re amazing at puzzles,\u{201D} Aza says.\n'
          '\u{201C}And you\u{2019}re amazing at explaining things,\u{201D} Heze replies.\n\n'
          'Their teacher smiles.\n'
          '\u{201C}You make a great team.\u{201D}',
      emoji: '\u{1F4DA}', // 📚
      bgColor: Color(0xFFFCE4EC), // soft pink tint
      imagePath: 'assets/stories/uk/page_3.png',
      fact: 'Everyone\u{2019}s brain works differently! Some people are '
          'extra good at noticing patterns, details, and solving puzzles. '
          'We all have our own special strengths.',
      factCategory: 'Culture',
    ),

    // Page 4 — Stronger Together
    StoryPage(
      title: 'Stronger Together',
      text:
          'That evening, the twins sit in the park near their home.\n\n'
          'Big Ben chimes in the distance.\n'
          'Birds fly across the sky.\n\n'
          '\u{201C}I like how you help me,\u{201D} Heze says quietly.\n'
          '\u{201C}And I like how you teach me to see things differently,\u{201D} '
          'Aza answers.\n\n'
          'Mum wraps them in a warm hug.\n'
          '\u{201C}You both shine in your own special ways.\u{201D}\n\n'
          'Heze looks up at the stars.\n'
          'Aza squeezes his hand.\n\n'
          '\u{201C}No matter where we go,\u{201D} Aza says,\n'
          '\u{201C}We\u{2019}ll always be together.\u{201D}\n\n'
          '\u{201C}And together,\u{201D} Heze smiles,\n'
          '\u{201C}We can do anything.\u{201D}',
      emoji: '\u{2B50}', // ⭐
      bgColor: Color(0xFFE8F5E9), // soft green tint
      imagePath: 'assets/stories/uk/page_4.png',
      fact: 'The UK has over 1,500 castles! Some are over 900 years old. '
          'Big Ben\u{2019}s bell weighs as much as a small elephant!',
      factCategory: 'Nature',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Story registry — add future country stories here.
// ---------------------------------------------------------------------------

/// All available stories, keyed by country ID.
final Map<String, Story> storyRegistry = {
  'ghana': _ghanaStory,
  'usa': _usaStory,
  'nigeria': _nigeriaStory,
  'uk': _ukStory,
};

/// Quick lookup.
Story? findStory(String countryId) => storyRegistry[countryId];
