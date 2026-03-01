import '../models/food_dish.dart';

const _usaFoodPack = FoodPack(
  countryId: 'usa',
  bannerEmoji: '\u{1F374}', // 🍴
  dishes: [
    FoodDish(
      id: 'burger',
      name: 'Burger',
      emoji: '\u{1F354}', // 🍔
      previewAsset: 'assets/coloring/usa/food/usa_food_01_burger.png',
      coloringPageId: 'food_burger',
      funFact: 'Hamburgers are one of America\'s favorite foods.',
      didYouKnow: [
        'Some burgers are bigger than a book.',
        'Americans eat millions of burgers every day.',
      ],
    ),
    FoodDish(
      id: 'pizza',
      name: 'Pizza',
      emoji: '\u{1F355}', // 🍕
      previewAsset: 'assets/coloring/usa/food/usa_food_02_pizza.png',
      coloringPageId: 'food_pizza',
      funFact: 'Pizza nights are a big favorite for many families.',
      didYouKnow: [
        'The largest pizza ever made was over 13,000 square feet.',
        'Pepperoni is one of the most popular pizza toppings in the USA.',
      ],
    ),
    FoodDish(
      id: 'hotdog',
      name: 'Hotdog',
      emoji: '\u{1F32D}', // 🌭
      previewAsset: 'assets/coloring/usa/food/usa_food_03_hotdog.png',
      coloringPageId: 'food_hotdog',
      funFact: 'Hotdogs are popular at baseball games and picnics.',
      didYouKnow: [
        'Some stadiums sell thousands of hotdogs in one game day.',
        'Kids often add ketchup, mustard, or relish on top.',
      ],
    ),
    FoodDish(
      id: 'pancakes',
      name: 'Pancakes',
      emoji: '\u{1F95E}', // 🥞
      previewAsset: 'assets/coloring/usa/food/usa_food_04_pancakes.png',
      coloringPageId: 'food_pancakes',
      funFact: 'Pancakes are a classic breakfast treat.',
      didYouKnow: [
        'Pancake stacks can be as tall as a toy tower.',
        'Maple syrup is a favorite topping in many homes.',
      ],
    ),
    FoodDish(
      id: 'donut',
      name: 'Donut',
      emoji: '\u{1F369}', // 🍩
      previewAsset: 'assets/coloring/usa/food/usa_food_05_donut.png',
      coloringPageId: 'food_donut',
      funFact: 'Donuts come in many fun shapes and flavors.',
      didYouKnow: [
        'Some bakeries make giant party-size donuts.',
        'Sprinkles can have many colors in one donut.',
      ],
    ),
    FoodDish(
      id: 'icecream',
      name: 'Ice Cream',
      emoji: '\u{1F368}', // 🍨
      previewAsset: 'assets/coloring/usa/food/usa_food_06_icecream.png',
      coloringPageId: 'food_icecream',
      funFact: 'Ice cream is a favorite summer dessert.',
      didYouKnow: [
        'Some shops offer dozens of flavors at once.',
        'Waffle cones are made warm and crispy.',
      ],
    ),
    FoodDish(
      id: 'friedchicken',
      name: 'Fried Chicken',
      emoji: '\u{1F357}', // 🍗
      previewAsset: 'assets/coloring/usa/food/usa_food_07_friedchicken.png',
      coloringPageId: 'food_friedchicken',
      funFact: 'Fried chicken meals are popular comfort food.',
      didYouKnow: [
        'Some family recipes are passed down for generations.',
        'Crunchy coating is often made with seasoned flour.',
      ],
    ),
    FoodDish(
      id: 'applepie',
      name: 'Apple Pie',
      emoji: '\u{1F967}', // 🥧
      previewAsset: 'assets/coloring/usa/food/usa_food_08_applepie.png',
      coloringPageId: 'food_applepie',
      funFact: 'Apple pie is one of America\'s classic desserts.',
      didYouKnow: [
        'The phrase “as American as apple pie” is very famous.',
        'Pie crusts can have decorative patterns on top.',
      ],
    ),
    FoodDish(
      id: 'sandwich',
      name: 'Sandwich',
      emoji: '\u{1F96A}', // 🥪
      previewAsset: 'assets/coloring/usa/food/usa_food_09_sandwich.png',
      coloringPageId: 'food_sandwich',
      funFact: 'Sandwiches are quick and easy lunch favorites.',
      didYouKnow: [
        'A sandwich can have many layers and colors.',
        'Some kids create their own sandwich recipes at home.',
      ],
    ),
    FoodDish(
      id: 'milkshake',
      name: 'Milkshake',
      emoji: '\u{1F964}', // 🥤
      previewAsset: 'assets/coloring/usa/food/usa_food_10_milkshake.png',
      coloringPageId: 'food_milkshake',
      funFact: 'Milkshakes are creamy drinks often topped with whipped cream.',
      didYouKnow: [
        'Some milkshakes are topped with cherries and sprinkles.',
        'Classic flavors include vanilla, chocolate, and strawberry.',
      ],
    ),
  ],
);

const _ghanaFoodPack = FoodPack(
  countryId: 'ghana',
  bannerEmoji: '\u{1F374}', // 🍴
  dishes: [
    FoodDish(
      id: 'jollof',
      name: 'Jollof',
      emoji: '\u{1F35B}', // 🍛
      previewAsset: 'assets/food/ghana/ghana_jollof_chef.webp',
      coloringPageId: 'food_jollof',
      funFact: 'Jollof rice is one of Ghana\'s most loved dishes.',
      didYouKnow: [
        'Families often add their own special spices to jollof.',
        'Jollof is popular at celebrations and parties.',
      ],
    ),
    FoodDish(
      id: 'banku',
      name: 'Banku',
      emoji: '\u{1F35C}', // 🍜
      previewAsset: 'assets/food/ghana/ghana_banku_chef.webp',
      coloringPageId: 'food_banku',
      funFact: 'Banku is often eaten with fish and pepper sauce.',
      didYouKnow: [
        'Banku is made from fermented corn and cassava dough.',
        'Many families enjoy banku for lunch or dinner.',
      ],
    ),
    FoodDish(
      id: 'fufu',
      name: 'Fufu',
      emoji: '\u{1F372}', // 🍲
      previewAsset: 'assets/food/ghana/ghana_fufu_chef.webp',
      coloringPageId: 'food_fufu',
      funFact: 'Fufu is a famous Ghanaian dish served with soup.',
      didYouKnow: [
        'Fufu is traditionally pounded in a mortar with a pestle.',
        'Different regions use different ingredients for fufu.',
      ],
    ),
    FoodDish(
      id: 'waakye',
      name: 'Waakye',
      emoji: '\u{1F35B}', // 🍛
      previewAsset: 'assets/food/ghana/ghana_waakye_chef.webp',
      coloringPageId: 'food_waakye',
      funFact: 'Waakye mixes rice and beans in one delicious meal.',
      didYouKnow: [
        'Waakye is often served with fish, egg, or spaghetti.',
        'It is a popular breakfast and lunch dish.',
      ],
    ),
    FoodDish(
      id: 'koko',
      name: 'Koko',
      emoji: '\u{2615}', // ☕
      previewAsset: 'assets/food/ghana/ghana_koko_chef.webp',
      coloringPageId: 'food_koko',
      funFact: 'Koko is a warm porridge enjoyed in the morning.',
      didYouKnow: [
        'Koko is often eaten with bread balls called koose or bofrot.',
        'It is usually served hot for breakfast.',
      ],
    ),
    FoodDish(
      id: 'kelewele',
      name: 'Kelewele',
      emoji: '\u{1F958}', // 🥘
      previewAsset: 'assets/food/ghana/ghana_kelewele_chef.webp',
      coloringPageId: 'food_kelewele',
      funFact: 'Kelewele is spicy fried plantain with ginger and pepper.',
      didYouKnow: [
        'Kelewele is a popular evening snack in Ghana.',
        'Some people like it extra spicy.',
      ],
    ),
    FoodDish(
      id: 'peanut_butter_soup',
      name: 'Peanut Butter Soup',
      emoji: '\u{1F95C}', // 🥜
      previewAsset: 'assets/food/ghana/ghana_groundnut_soup_chef.png',
      coloringPageId: 'food_peanut_butter_soup',
      funFact: 'Peanut butter soup is creamy, rich, and full of flavour.',
      didYouKnow: [
        'Peanut butter soup is also called groundnut soup in Ghana.',
        'It is often cooked with chicken or goat meat.',
      ],
    ),
    FoodDish(
      id: 'palmnut',
      name: 'Palm Nut Soup',
      emoji: '\u{1F372}', // 🍲
      previewAsset: 'assets/food/ghana/ghana_palmnut_soup_chef.webp',
      coloringPageId: 'food_palmnut',
      funFact: 'Palm nut soup is a rich and flavorful traditional dish.',
      didYouKnow: [
        'Palm fruits give the soup its deep color and taste.',
        'Palm nut soup can be served with fufu.',
      ],
    ),
    FoodDish(
      id: 'fried_rice',
      name: 'Fried Rice',
      emoji: '\u{1F35A}', // 🍚
      previewAsset: 'assets/food/ghana/ghana_fried_rice_chef.webp',
      coloringPageId: 'food_fried_rice',
      funFact: 'Ghana fried rice is packed with vegetables and seasoning.',
      didYouKnow: [
        'Ghanaian fried rice often includes carrots, peas, and shredded chicken.',
        'It is a popular party and celebration dish.',
      ],
    ),
  ],
);

const _nigeriaFoodPack = FoodPack(
  countryId: 'nigeria',
  bannerEmoji: '\u{1F374}', // 🍴
  dishes: [
    FoodDish(
      id: 'jollof',
      name: 'Jollof Rice',
      emoji: '\u{1F35B}', // 🍛
      previewAsset: 'assets/food/nigeria/ng_jollof_chef.webp',
      coloringPageId: 'jollof',
      funFact: 'Nigerian jollof rice is famous for its smoky flavour.',
      didYouKnow: [
        'Party jollof cooked over firewood is the most popular.',
        'There is a fun rivalry between Nigerian and Ghanaian jollof!',
      ],
    ),
    FoodDish(
      id: 'suya',
      name: 'Suya',
      emoji: '\u{1F356}', // 🍖
      previewAsset: 'assets/food/nigeria/ng_suya_chef.webp',
      coloringPageId: 'suya',
      funFact: 'Suya is spicy grilled meat sold on the streets.',
      didYouKnow: [
        'Suya sellers come out in the evening with their grills.',
        'The special spice mix is called yaji and uses groundnuts.',
      ],
    ),
    FoodDish(
      id: 'pounded_yam',
      name: 'Pounded Yam',
      emoji: '\u{1F372}', // 🍲
      previewAsset: 'assets/food/nigeria/ng_pounded_yam_chef.webp',
      coloringPageId: 'cooking',
      funFact: 'Pounded yam is soft and stretchy, served with soup.',
      didYouKnow: [
        'Yam is so important in Nigeria there is a New Yam Festival!',
        'Pounded yam is made by pounding boiled yam until smooth.',
      ],
    ),
    FoodDish(
      id: 'egusi',
      name: 'Egusi Soup',
      emoji: '\u{1F958}', // 🥘
      previewAsset: 'assets/food/nigeria/ng_egusi_chef.webp',
      coloringPageId: 'cooking',
      funFact: 'Egusi soup is made from ground melon seeds.',
      didYouKnow: [
        'Egusi soup is one of the most popular soups in Nigeria.',
        'It is often eaten with pounded yam or fufu.',
      ],
    ),
    FoodDish(
      id: 'chin_chin',
      name: 'Chin Chin',
      emoji: '\u{1F36A}', // 🍪
      previewAsset: 'assets/food/nigeria/ng_chin_chin_chef.webp',
      coloringPageId: 'cooking',
      funFact: 'Chin chin is a crunchy fried snack loved by kids.',
      didYouKnow: [
        'Chin chin is especially popular during celebrations.',
        'It comes in many shapes and can be sweet or spicy.',
      ],
    ),
  ],
);

const _ukFoodPack = FoodPack(
  countryId: 'uk',
  bannerEmoji: '\u{1F374}', // 🍴
  dishes: [
    FoodDish(
      id: 'fishandchips',
      name: 'Fish & Chips',
      emoji: '\u{1F41F}', // 🐟
      previewAsset: 'assets/food/uk/fish_and_chips.webp',
      coloringPageId: 'food_fishandchips',
      funFact: 'Fish and chips is the UK\'s most famous takeaway meal.',
      didYouKnow: [
        'The first fish and chip shop opened in the 1860s.',
        'British people eat about 382 million portions a year!',
      ],
    ),
    FoodDish(
      id: 'shepherdspie',
      name: 'Shepherd\'s Pie',
      emoji: '\u{1F967}', // 🥧
      previewAsset: 'assets/food/uk/Shepherds_pie.webp',
      coloringPageId: 'food_shepherdspie',
      funFact: 'Shepherd\'s pie has mashed potato on top and tasty meat inside.',
      didYouKnow: [
        'It is called shepherd\'s pie when made with lamb.',
        'Cottage pie is the same dish but made with beef!',
      ],
    ),
    FoodDish(
      id: 'scones',
      name: 'Scones',
      emoji: '\u{1F9C1}', // 🧁
      previewAsset: 'assets/food/uk/Scones.webp',
      coloringPageId: 'food_scones',
      funFact: 'Scones are a favourite treat for afternoon tea.',
      didYouKnow: [
        'Scones are served with clotted cream and strawberry jam.',
        'People debate whether to put cream or jam on first!',
      ],
    ),
    FoodDish(
      id: 'englishbreakfast',
      name: 'English Breakfast',
      emoji: '\u{1F373}', // 🍳
      previewAsset: 'assets/food/uk/English_breakfast.webp',
      coloringPageId: 'food_englishbreakfast',
      funFact: 'A full English breakfast is a big, hearty meal to start the day.',
      didYouKnow: [
        'It often includes eggs, bacon, sausages, beans, and toast.',
        'Some people call it a "fry-up" because much of it is fried!',
      ],
    ),
    FoodDish(
      id: 'bangersandmash',
      name: 'Bangers & Mash',
      emoji: '\u{1F356}', // 🍖
      previewAsset: 'assets/food/uk/Bangers_and_mash.webp',
      coloringPageId: 'food_bangersandmash',
      funFact: 'Bangers and mash is sausages with creamy mashed potatoes.',
      didYouKnow: [
        'Sausages are called "bangers" because they used to pop in the pan!',
        'Onion gravy is a favourite topping.',
      ],
    ),
    FoodDish(
      id: 'crumpets',
      name: 'Crumpets',
      emoji: '\u{1F95E}', // 🥞
      previewAsset: 'assets/food/uk/Crumpets.webp',
      coloringPageId: 'food_crumpets',
      funFact: 'Crumpets are soft, spongy, and full of little holes for butter.',
      didYouKnow: [
        'Crumpets are toasted and served warm with melted butter.',
        'British people eat about 80 million crumpets every year!',
      ],
    ),
    FoodDish(
      id: 'trifle',
      name: 'Trifle',
      emoji: '\u{1F370}', // 🍰
      previewAsset: 'assets/food/uk/Trifle.webp',
      coloringPageId: 'food_trifle',
      funFact: 'Trifle is a layered dessert with cake, fruit, custard, and cream.',
      didYouKnow: [
        'Trifle has been enjoyed in Britain for over 400 years!',
        'Every layer adds a different flavour and texture.',
      ],
    ),
    FoodDish(
      id: 'yorkshirepudding',
      name: 'Yorkshire Pudding',
      emoji: '\u{1F35E}', // 🍞
      previewAsset: 'assets/food/uk/Yorkshire_pudding.webp',
      coloringPageId: 'food_yorkshirepudding',
      funFact: 'Yorkshire pudding is puffy and golden, served with a roast dinner.',
      didYouKnow: [
        'It is made from batter — eggs, flour, and milk.',
        'Some people fill giant Yorkshire puddings with gravy and meat!',
      ],
    ),
    FoodDish(
      id: 'cornishpasty',
      name: 'Cornish Pasty',
      emoji: '\u{1F950}', // 🥐
      previewAsset: 'assets/food/uk/Cornish_pasty.webp',
      coloringPageId: 'food_cornishpasty',
      funFact: 'Cornish pasties are handheld pies filled with meat and vegetables.',
      didYouKnow: [
        'Tin miners in Cornwall used to carry pasties for lunch.',
        'The crimped edge was a handle so miners didn\'t dirty the filling!',
      ],
    ),
    FoodDish(
      id: 'stickytoffee',
      name: 'Sticky Toffee Pudding',
      emoji: '\u{1F36E}', // 🍮
      previewAsset: 'assets/food/uk/sticky_toffee_pudding.webp',
      coloringPageId: 'food_stickytoffee',
      funFact: 'Sticky toffee pudding is a warm, sweet cake with toffee sauce.',
      didYouKnow: [
        'It is made with dates, which give it a rich flavour.',
        'It is often served with vanilla ice cream or custard.',
      ],
    ),
  ],
);

/// Country → Food pack registry.
final Map<String, FoodPack> foodRegistry = {
  'ghana': _ghanaFoodPack,
  'usa': _usaFoodPack,
  'nigeria': _nigeriaFoodPack,
  'uk': _ukFoodPack,
};

FoodPack? findFoodPack(String countryId) => foodRegistry[countryId];

FoodDish? findFoodDish(String countryId, String dishId) {
  final pack = findFoodPack(countryId);
  if (pack == null) return null;
  for (final dish in pack.dishes) {
    if (dish.id == dishId) return dish;
  }
  return null;
}
