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
      bgColor: Color(0xFFE3F2FD), // soft blue tint
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
      bgColor: Color(0xFFE8F5E9), // soft green tint
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
      bgColor: Color(0xFFFFF3E0), // warm cream tint
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
      bgColor: Color(0xFFFCE4EC), // soft pink tint
      fact: 'America has 63 national parks! Yellowstone was the very first '
          'national park in the world, created in 1872.',
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
};

/// Quick lookup.
Story? findStory(String countryId) => storyRegistry[countryId];
