import '../models/coloring_page.dart';

/// All coloring pages grouped by country.
///
/// Data-driven: add pages here and every screen picks them up.
final Map<String, List<ColoringPage>> coloringRegistry = {
  'ghana': _ghanaPages,
  'usa': _usaPages,
  'nigeria': _nigeriaPages,
  'uk': _ukPages,
};

final _ghanaPages = [
  ColoringPage(
    id: 'home',
    title: 'Home',
    countryId: 'ghana',
    emoji: '\u{1F3E0}', // 🏠
    outlineAsset: 'assets/coloring/ghana/ghana_01_home.png',
    fact: 'Many homes in Ghana share space for family gatherings, music, '
        'and storytelling.',
    factCategory: 'Daily Life',
  ),
  ColoringPage(
    id: 'village',
    title: 'Village Morning',
    countryId: 'ghana',
    emoji: '\u{1F305}', // 🌅
    outlineAsset: 'assets/coloring/ghana/ghana_02_village.png',
    fact: 'Roosters, sunrise, and busy footpaths are part of morning '
        'life in many Ghanaian communities.',
    factCategory: 'Daily Life',
  ),
  ColoringPage(
    id: 'school',
    title: 'School Day',
    countryId: 'ghana',
    emoji: '\u{1F3EB}', // 🏫
    outlineAsset: 'assets/coloring/ghana/ghana_03_school.png',
    fact: 'Ghana celebrates education with school uniforms, morning '
        'assembly, and active classroom communities.',
    factCategory: 'Education',
  ),
  ColoringPage(
    id: 'forest',
    title: 'Rainforest',
    countryId: 'ghana',
    emoji: '\u{1F333}', // 🌳
    outlineAsset: 'assets/coloring/ghana/ghana_04_forest.png',
    fact: 'Ghana has rich forests that are home to colorful birds, '
        'butterflies, and many native plant species.',
    factCategory: 'Nature',
  ),
  ColoringPage(
    id: 'river',
    title: 'River Journey',
    countryId: 'ghana',
    emoji: '\u{1F6F6}', // 🛶
    outlineAsset: 'assets/coloring/ghana/ghana_05_river.png',
    fact: 'Rivers support fishing, farming, and travel in many parts of Ghana.',
    factCategory: 'Nature',
  ),
  ColoringPage(
    id: 'beach',
    title: 'Beach',
    countryId: 'ghana',
    emoji: '\u{1F3D6}', // 🏖
    outlineAsset: 'assets/coloring/ghana/ghana_06_beach.png',
    fact: 'Ghana\'s Atlantic coastline has lively fishing towns and '
        'beautiful sandy beaches.',
    factCategory: 'Nature',
  ),
  ColoringPage(
    id: 'kente',
    title: 'Kente Cloth',
    countryId: 'ghana',
    emoji: '\u{1F9F5}', // 🧵
    outlineAsset: 'assets/coloring/ghana/ghana_07_kente.png',
    fact: 'Kente patterns and colors each carry meaning, often linked to '
        'values, history, and celebration.',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'festival',
    title: 'Festival',
    countryId: 'ghana',
    emoji: '\u{1F389}', // 🎉
    outlineAsset: 'assets/coloring/ghana/ghana_08_festival.png',
    fact: 'Traditional festivals include music, dance, drums, and colorful dress.',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'market',
    title: 'Market Day',
    countryId: 'ghana',
    emoji: '\u{1F6D2}', // 🛒
    outlineAsset: 'assets/coloring/ghana/ghana_09_market.png',
    fact: 'Open-air markets are important community places for food, fabrics, '
        'and crafts.',
    factCategory: 'Daily Life',
  ),
  ColoringPage(
    id: 'cooking',
    title: 'Family Cooking',
    countryId: 'ghana',
    emoji: '\u{1F373}', // 🍳
    outlineAsset: 'assets/coloring/ghana/ghana_10_cooking.png',
    fact: 'Cooking together is a joyful way families share recipes '
        'and traditions.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food',
    title: 'Ghana Foods',
    countryId: 'ghana',
    emoji: '\u{1F35B}', // 🍛
    outlineAsset: 'assets/coloring/ghana/ghana_11_food.png',
    fact: 'Popular dishes include jollof rice, banku, fried plantain, '
        'and fish stews.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'helping',
    title: 'Helping Hands',
    countryId: 'ghana',
    emoji: '\u{1F91D}', // 🤝
    outlineAsset: 'assets/coloring/ghana/ghana_12_helping.png',
    fact: 'Kids often help at home with watering plants, feeding animals, '
        'and simple chores.',
    factCategory: 'Daily Life',
  ),
  ColoringPage(
    id: 'football',
    title: 'Football',
    countryId: 'ghana',
    emoji: '\u{26BD}', // ⚽
    outlineAsset: 'assets/coloring/ghana/ghana_13_football.png',
    fact: 'Football is one of Ghana\'s most loved sports across schools '
        'and neighborhoods.',
    factCategory: 'Sports',
  ),
  ColoringPage(
    id: 'storytime',
    title: 'Storytime',
    countryId: 'ghana',
    emoji: '\u{1F4DA}', // 📚
    outlineAsset: 'assets/coloring/ghana/ghana_14_storytime.png',
    fact: 'Oral storytelling is a treasured tradition for sharing wisdom '
        'across generations.',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'dreams',
    title: 'Big Dreams',
    countryId: 'ghana',
    emoji: '\u{1F31F}', // 🌟
    outlineAsset: 'assets/coloring/ghana/ghana_15_dreams.png',
    fact: 'Ghanaian children dream big in science, sports, arts, teaching, '
        'and many other fields.',
    factCategory: 'Inspiration',
  ),
  // ── Ghana Food ──
  ColoringPage(
    id: 'food_jollof',
    title: 'Jollof',
    countryId: 'ghana',
    emoji: '\u{1F35B}', // 🍛
    outlineAsset: 'assets/coloring/ghana/food/ghana_food_01_jollof.png',
    fact: 'Jollof rice is one of Ghana\'s most popular dishes.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_plantain',
    title: 'Plantain',
    countryId: 'ghana',
    emoji: '\u{1F34C}', // 🍌
    outlineAsset: 'assets/coloring/ghana/food/ghana_food_02_plantain.png',
    fact: 'Fried plantain is sweet and loved by many families.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_banku',
    title: 'Banku',
    countryId: 'ghana',
    emoji: '\u{1F35C}', // 🍜
    outlineAsset: 'assets/coloring/ghana/food/ghana_food_03_banku.png',
    fact: 'Banku is often served with fish and pepper.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_fufu',
    title: 'Fufu',
    countryId: 'ghana',
    emoji: '\u{1F372}', // 🍲
    outlineAsset: 'assets/coloring/ghana/food/ghana_food_04_fufu.png',
    fact: 'Fufu is a famous Ghanaian meal served with soup.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_waakye',
    title: 'Waakye',
    countryId: 'ghana',
    emoji: '\u{1F35B}', // 🍛
    outlineAsset: 'assets/coloring/ghana/food/ghana_food_05_waakye.png',
    fact: 'Waakye combines rice and beans in one tasty dish.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_koko',
    title: 'Koko',
    countryId: 'ghana',
    emoji: '\u{2615}', // ☕
    outlineAsset: 'assets/coloring/ghana/food/ghana_food_06_koko.png',
    fact: 'Koko is a warm breakfast porridge.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_kelewele',
    title: 'Kelewele',
    countryId: 'ghana',
    emoji: '\u{1F958}', // 🥘
    outlineAsset: 'assets/coloring/ghana/food/ghana_food_07_kelewele.png',
    fact: 'Kelewele is spicy fried plantain with ginger and pepper.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_groundnut',
    title: 'Groundnut Soup',
    countryId: 'ghana',
    emoji: '\u{1F95C}', // 🥜
    outlineAsset: 'assets/coloring/ghana/food/ghana_food_08_groundnut.png',
    fact: 'Groundnut soup is made from peanuts and rich spices.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_tilapia',
    title: 'Tilapia',
    countryId: 'ghana',
    emoji: '\u{1F41F}', // 🐟
    outlineAsset: 'assets/coloring/ghana/food/ghana_food_09_tilapia.png',
    fact: 'Grilled tilapia is often served with pepper and onions.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_palmnut',
    title: 'Palm Nut Soup',
    countryId: 'ghana',
    emoji: '\u{1F372}', // 🍲
    outlineAsset: 'assets/coloring/ghana/food/ghana_food_10_palmnut.png',
    fact: 'Palm nut soup is a traditional dish in many Ghanaian homes.',
    factCategory: 'Food',
  ),
];

final _usaPages = [
  // ── Nature ──
  ColoringPage(
    id: 'map',
    title: 'US Map',
    countryId: 'usa',
    emoji: '\u{1F5FA}', // 🗺
    outlineAsset: 'assets/coloring/usa/nature/usa_01_map.png',
    maskAsset: 'assets/coloring/usa/masks/usa_01_map_mask.png',
    fact: 'The United States has 50 states, and the two newest — '
        'Alaska and Hawaii — joined in 1959!',
    factCategory: 'Geography',
  ),
  ColoringPage(
    id: 'mountains',
    title: 'Mountains',
    countryId: 'usa',
    emoji: '\u{1F3D4}', // 🏔
    outlineAsset: 'assets/coloring/usa/nature/usa_02_mountains.png',
    maskAsset: 'assets/coloring/usa/masks/usa_02_mountains_mask.png',
    fact: 'The Rocky Mountains stretch over 3,000 miles from Canada '
        'all the way down to New Mexico!',
    factCategory: 'Nature',
  ),
  ColoringPage(
    id: 'desert',
    title: 'Desert',
    countryId: 'usa',
    emoji: '\u{1F335}', // 🌵
    outlineAsset: 'assets/coloring/usa/nature/usa_03_desert.png',
    maskAsset: 'assets/coloring/usa/masks/usa_03_desert_mask.png',
    fact: 'The Saguaro cactus only grows in the Sonoran Desert and '
        'can live for over 150 years!',
    factCategory: 'Nature',
  ),

  // ── Cities ──
  ColoringPage(
    id: 'nyc',
    title: 'New York City',
    countryId: 'usa',
    emoji: '\u{1F5FD}', // 🗽
    outlineAsset: 'assets/coloring/usa/cities/usa_04_nyc.png',
    maskAsset: 'assets/coloring/usa/masks/usa_04_nyc_mask.png',
    fact: 'The Statue of Liberty was a gift from France in 1886! '
        'Her real name is "Liberty Enlightening the World."',
    factCategory: 'History',
  ),
  ColoringPage(
    id: 'dc',
    title: 'Washington D.C.',
    countryId: 'usa',
    emoji: '\u{1F3DB}', // 🏛
    outlineAsset: 'assets/coloring/usa/cities/usa_05_dc.png',
    maskAsset: 'assets/coloring/usa/masks/usa_05_dc_mask.png',
    fact: 'Washington D.C. is not a state — it\'s a special district! '
        'The White House has 132 rooms and 35 bathrooms.',
    factCategory: 'History',
  ),
  ColoringPage(
    id: 'sf',
    title: 'San Francisco',
    countryId: 'usa',
    emoji: '\u{1F309}', // 🌉
    outlineAsset: 'assets/coloring/usa/cities/usa_06_sf.png',
    maskAsset: 'assets/coloring/usa/masks/usa_06_sf_mask.png',
    fact: 'The Golden Gate Bridge is painted "International Orange" '
        'so it can be seen through San Francisco\'s famous fog!',
    factCategory: 'Fun Fact',
  ),
  ColoringPage(
    id: 'hollywood',
    title: 'Hollywood',
    countryId: 'usa',
    emoji: '\u{1F3AC}', // 🎬
    outlineAsset: 'assets/coloring/usa/cities/usa_07_hollywood.png',
    maskAsset: 'assets/coloring/usa/masks/usa_07_hollywood_mask.png',
    fact: 'The Hollywood Sign was originally "Hollywoodland" — an ad '
        'for a housing development in 1923!',
    factCategory: 'Fun Fact',
  ),
  ColoringPage(
    id: 'yellowstone',
    title: 'Yellowstone',
    countryId: 'usa',
    emoji: '\u{1F30B}', // 🌋
    outlineAsset: 'assets/coloring/usa/cities/usa_08_yellowstone.png',
    maskAsset: 'assets/coloring/usa/masks/usa_08_yellowstone_mask.png',
    fact: 'Yellowstone became the world\'s first national park in 1872! '
        'It sits on top of a giant underground volcano.',
    factCategory: 'Nature',
  ),
  ColoringPage(
    id: 'yosemite',
    title: 'Yosemite',
    countryId: 'usa',
    emoji: '\u{1FA78}', // 🪨 (fallback)
    outlineAsset: 'assets/coloring/usa/cities/usa_09_yosemite.png',
    maskAsset: 'assets/coloring/usa/masks/usa_09_yosemite_mask.png',
    fact: 'Yosemite Falls is one of the tallest waterfalls in North '
        'America — taller than the Empire State Building!',
    factCategory: 'Nature',
  ),
  ColoringPage(
    id: 'everglades',
    title: 'Everglades',
    countryId: 'usa',
    emoji: '\u{1F40A}', // 🐊
    outlineAsset: 'assets/coloring/usa/cities/usa_10_everglades.png',
    maskAsset: 'assets/coloring/usa/masks/usa_10_everglades_mask.png',
    fact: 'The Everglades is the only place on Earth where alligators '
        'and crocodiles live together in the wild!',
    factCategory: 'Nature',
  ),

  // ── Daily Life ──
  ColoringPage(
    id: 'school',
    title: 'School Day',
    countryId: 'usa',
    emoji: '\u{1F3EB}', // 🏫
    outlineAsset: 'assets/coloring/usa/daily life/usa_11_school.png',
    maskAsset: 'assets/coloring/usa/masks/usa_11_school_mask.png',
    fact: 'American kids ride about 480,000 yellow school buses '
        'every day — that\'s the largest transit system in the country!',
    factCategory: 'Fun Fact',
  ),
  ColoringPage(
    id: 'neighborhood',
    title: 'Neighborhood',
    countryId: 'usa',
    emoji: '\u{1F3E0}', // 🏠
    outlineAsset: 'assets/coloring/usa/daily life/usa_12_neighborhood.png',
    maskAsset: 'assets/coloring/usa/masks/usa_12_neighborhood_mask.png',
    fact: 'America is called a "melting pot" because people from '
        'all over the world live here together!',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'sports',
    title: 'Sports',
    countryId: 'usa',
    emoji: '\u{1F3C8}', // 🏈
    outlineAsset: 'assets/coloring/usa/daily life/usa_13_sports.png',
    maskAsset: 'assets/coloring/usa/masks/usa_13_sports_mask.png',
    fact: 'Basketball was invented by a gym teacher in 1891 using '
        'a peach basket as the first hoop!',
    factCategory: 'Sports',
  ),

  // ── Food ──
  ColoringPage(
    id: 'food_burger',
    title: 'Burger',
    countryId: 'usa',
    emoji: '\u{1F354}', // 🍔
    outlineAsset: 'assets/coloring/usa/food/usa_food_01_burger.png',
    fact: 'Hamburgers are one of America\'s favorite foods.',
    factCategory: 'Fun Fact',
  ),
  ColoringPage(
    id: 'food_pizza',
    title: 'Pizza',
    countryId: 'usa',
    emoji: '\u{1F355}', // 🍕
    outlineAsset: 'assets/coloring/usa/food/usa_food_02_pizza.png',
    fact: 'Pizza nights are a family favorite all across the USA.',
    factCategory: 'Fun Fact',
  ),
  ColoringPage(
    id: 'food_hotdog',
    title: 'Hotdog',
    countryId: 'usa',
    emoji: '\u{1F32D}', // 🌭
    outlineAsset: 'assets/coloring/usa/food/usa_food_03_hotdog.png',
    fact: 'Hotdogs are popular at baseball games and summer picnics.',
    factCategory: 'Fun Fact',
  ),
  ColoringPage(
    id: 'food_pancakes',
    title: 'Pancakes',
    countryId: 'usa',
    emoji: '\u{1F95E}', // 🥞
    outlineAsset: 'assets/coloring/usa/food/usa_food_04_pancakes.png',
    fact: 'Pancakes are a classic breakfast with syrup and butter.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_donut',
    title: 'Donut',
    countryId: 'usa',
    emoji: '\u{1F369}', // 🍩
    outlineAsset: 'assets/coloring/usa/food/usa_food_05_donut.png',
    fact: 'Donuts can be glazed, frosted, and covered in colorful sprinkles.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_icecream',
    title: 'Ice Cream',
    countryId: 'usa',
    emoji: '\u{1F368}', // 🍨
    outlineAsset: 'assets/coloring/usa/food/usa_food_06_icecream.png',
    fact: 'Ice cream cones are a favorite treat on warm days.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_friedchicken',
    title: 'Fried Chicken',
    countryId: 'usa',
    emoji: '\u{1F357}', // 🍗
    outlineAsset: 'assets/coloring/usa/food/usa_food_07_friedchicken.png',
    fact: 'Fried chicken is a popular comfort food in many states.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_applepie',
    title: 'Apple Pie',
    countryId: 'usa',
    emoji: '\u{1F967}', // 🥧
    outlineAsset: 'assets/coloring/usa/food/usa_food_08_applepie.png',
    fact: 'Apple pie is one of the most famous American desserts.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_sandwich',
    title: 'Sandwich',
    countryId: 'usa',
    emoji: '\u{1F96A}', // 🥪
    outlineAsset: 'assets/coloring/usa/food/usa_food_09_sandwich.png',
    fact: 'Sandwiches are a quick and easy lunch favorite.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_milkshake',
    title: 'Milkshake',
    countryId: 'usa',
    emoji: '\u{1F964}', // 🥤
    outlineAsset: 'assets/coloring/usa/food/usa_food_10_milkshake.png',
    fact: 'Milkshakes are creamy drinks often topped with whipped cream.',
    factCategory: 'Fun Fact',
  ),
];

final _nigeriaPages = [
  ColoringPage(
    id: 'city',
    title: 'Lagos City',
    countryId: 'nigeria',
    emoji: '\u{1F3D9}', // 🏙
    outlineAsset: 'assets/coloring/nigeria/nigeria_01_city.png',
    fact: 'Lagos is the largest city in Africa with over 20 million people!',
    factCategory: 'Geography',
  ),
  ColoringPage(
    id: 'home',
    title: 'Home',
    countryId: 'nigeria',
    emoji: '\u{1F3E0}', // 🏠
    outlineAsset: 'assets/coloring/nigeria/nigeria_02_home.png',
    fact: 'Nigerian homes are full of warmth, with families gathering to share meals and stories.',
    factCategory: 'Daily Life',
  ),
  ColoringPage(
    id: 'school',
    title: 'School Day',
    countryId: 'nigeria',
    emoji: '\u{1F3EB}', // 🏫
    outlineAsset: 'assets/coloring/nigeria/nigeria_03_school.png',
    fact: 'Nigerian students often wear colourful uniforms and learn in English.',
    factCategory: 'Education',
  ),
  ColoringPage(
    id: 'market',
    title: 'Market Day',
    countryId: 'nigeria',
    emoji: '\u{1F6D2}', // 🛒
    outlineAsset: 'assets/coloring/nigeria/nigeria_04_market.png',
    fact: 'Balogun Market in Lagos is one of the busiest markets in West Africa.',
    factCategory: 'Daily Life',
  ),
  ColoringPage(
    id: 'clothes',
    title: 'Ankara Clothes',
    countryId: 'nigeria',
    emoji: '\u{1F9F5}', // 🧵
    outlineAsset: 'assets/coloring/nigeria/nigeria_05_clothes.png',
    fact: 'Ankara fabric has bold, colourful patterns and is worn at celebrations.',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'music',
    title: 'Music & Drums',
    countryId: 'nigeria',
    emoji: '\u{1F3B5}', // 🎵
    outlineAsset: 'assets/coloring/nigeria/nigeria_06_music.png',
    fact: 'Afrobeats started in Nigeria and is now loved all around the world!',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'cooking',
    title: 'Family Cooking',
    countryId: 'nigeria',
    emoji: '\u{1F373}', // 🍳
    outlineAsset: 'assets/coloring/nigeria/nigeria_07_cooking.png',
    fact: 'Nigerian families love cooking together, especially for celebrations.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'football',
    title: 'Football',
    countryId: 'nigeria',
    emoji: '\u{26BD}', // ⚽
    outlineAsset: 'assets/coloring/nigeria/nigeria_08_football.png',
    fact: 'The Super Eagles are Nigeria\'s national football team, loved by millions!',
    factCategory: 'Sports',
  ),
  ColoringPage(
    id: 'olumo',
    title: 'Olumo Rock',
    countryId: 'nigeria',
    emoji: '\u{26F0}\u{FE0F}', // ⛰️
    outlineAsset: 'assets/coloring/nigeria/nigeria_10_olumo.png',
    fact: 'Olumo Rock in Abeokuta is a historic fortress where people once sheltered during wars.',
    factCategory: 'History',
  ),
  ColoringPage(
    id: 'beach',
    title: 'Beach',
    countryId: 'nigeria',
    emoji: '\u{1F3D6}', // 🏖
    outlineAsset: 'assets/coloring/nigeria/nigeria_11_beach.png',
    fact: 'Nigeria has beautiful beaches along the Atlantic coast, including Elegushi and Tarkwa Bay.',
    factCategory: 'Nature',
  ),
  ColoringPage(
    id: 'dreams',
    title: 'Big Dreams',
    countryId: 'nigeria',
    emoji: '\u{1F31F}', // 🌟
    outlineAsset: 'assets/coloring/nigeria/nigeria_12_dreams.png',
    fact: 'Nigerian children dream big in tech, music, sports, and science!',
    factCategory: 'Inspiration',
  ),
];

final _ukPages = [
  // ── Landmarks ──
  ColoringPage(
    id: 'bigben',
    title: 'Big Ben',
    countryId: 'uk',
    emoji: '\u{1F554}', // 🕔
    outlineAsset: 'assets/coloring/uk/uk_01_bigben.png',
    fact: 'Big Ben is the nickname of the Great Bell inside the Elizabeth Tower '
        'at the Palace of Westminster.',
    factCategory: 'History',
  ),
  ColoringPage(
    id: 'towerbridge',
    title: 'Tower Bridge',
    countryId: 'uk',
    emoji: '\u{1F309}', // 🌉
    outlineAsset: 'assets/coloring/uk/uk_02_towerbridge.png',
    fact: 'Tower Bridge can open in the middle to let tall ships pass through '
        'on the River Thames!',
    factCategory: 'History',
  ),
  ColoringPage(
    id: 'palace',
    title: 'Buckingham Palace',
    countryId: 'uk',
    emoji: '\u{1F3F0}', // 🏰
    outlineAsset: 'assets/coloring/uk/uk_03_palace.png',
    fact: 'Buckingham Palace has 775 rooms, including 78 bathrooms!',
    factCategory: 'History',
  ),
  ColoringPage(
    id: 'doubledecker',
    title: 'Double-Decker Bus',
    countryId: 'uk',
    emoji: '\u{1F68C}', // 🚌
    outlineAsset: 'assets/coloring/uk/uk_04_doubledecker.png',
    fact: 'London\'s famous red double-decker buses have been running since 1956!',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'phonebox',
    title: 'Red Phone Box',
    countryId: 'uk',
    emoji: '\u{260E}\u{FE0F}', // ☎️
    outlineAsset: 'assets/coloring/uk/uk_05_phonebox.png',
    fact: 'The red telephone box was designed in 1924 and became a symbol of Britain.',
    factCategory: 'Culture',
  ),
  ColoringPage(
    id: 'stonehenge',
    title: 'Stonehenge',
    countryId: 'uk',
    emoji: '\u{1FAA8}', // 🪨
    outlineAsset: 'assets/coloring/uk/uk_06_stonehenge.png',
    fact: 'Stonehenge is about 5,000 years old and nobody knows exactly '
        'how the giant stones were moved!',
    factCategory: 'Nature',
  ),
  ColoringPage(
    id: 'countryside',
    title: 'Countryside',
    countryId: 'uk',
    emoji: '\u{1F33F}', // 🌿
    outlineAsset: 'assets/coloring/uk/uk_07_countryside.png',
    fact: 'The British countryside has rolling green hills, stone walls, '
        'and fluffy sheep.',
    factCategory: 'Nature',
  ),
  // ── Food ──
  ColoringPage(
    id: 'food_fishandchips',
    title: 'Fish & Chips',
    countryId: 'uk',
    emoji: '\u{1F41F}', // 🐟
    outlineAsset: 'assets/coloring/uk/food/uk_food_01_fishandchips.png',
    fact: 'Fish and chips is the UK\'s most famous takeaway meal.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_scones',
    title: 'Scones',
    countryId: 'uk',
    emoji: '\u{1F9C1}', // 🧁
    outlineAsset: 'assets/coloring/uk/food/uk_food_02_scones.png',
    fact: 'Scones with clotted cream and jam are a classic afternoon tea treat.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_englishbreakfast',
    title: 'English Breakfast',
    countryId: 'uk',
    emoji: '\u{1F373}', // 🍳
    outlineAsset: 'assets/coloring/uk/food/uk_food_03_englishbreakfast.png',
    fact: 'A full English breakfast can have eggs, bacon, sausages, beans, and toast.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_crumpets',
    title: 'Crumpets',
    countryId: 'uk',
    emoji: '\u{1F95E}', // 🥞
    outlineAsset: 'assets/coloring/uk/food/uk_food_04_crumpets.png',
    fact: 'Crumpets are soft, spongy, and full of little holes for melted butter.',
    factCategory: 'Food',
  ),
  ColoringPage(
    id: 'food_trifle',
    title: 'Trifle',
    countryId: 'uk',
    emoji: '\u{1F370}', // 🍰
    outlineAsset: 'assets/coloring/uk/food/uk_food_05_trifle.png',
    fact: 'Trifle is a layered dessert with cake, fruit, custard, and cream.',
    factCategory: 'Food',
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
