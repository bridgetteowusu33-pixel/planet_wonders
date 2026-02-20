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
      previewAsset: 'assets/food/ghana/ghana_jollof_chef.png',
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
      previewAsset: 'assets/food/ghana/ghana_banku_chef.png',
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
      previewAsset: 'assets/food/ghana/ghana_fufu_chef.png',
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
      previewAsset: 'assets/food/ghana/ghana_waakye_chef.png',
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
      previewAsset: 'assets/food/ghana/ghana_koko_chef.png',
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
      previewAsset: 'assets/food/ghana/ghana_kelewele_chef.png',
      coloringPageId: 'food_kelewele',
      funFact: 'Kelewele is spicy fried plantain with ginger and pepper.',
      didYouKnow: [
        'Kelewele is a popular evening snack in Ghana.',
        'Some people like it extra spicy.',
      ],
    ),
    FoodDish(
      id: 'groundnut',
      name: 'Groundnut Soup',
      emoji: '\u{1F95C}', // 🥜
      previewAsset: 'assets/food/ghana/ghana_groundnut_soup_chef.png',
      coloringPageId: 'food_groundnut',
      funFact: 'Groundnut soup is creamy and rich.',
      didYouKnow: [
        'Groundnut means peanut in many parts of West Africa.',
        'It is often cooked with meat or fish.',
      ],
    ),
    FoodDish(
      id: 'tilapia',
      name: 'Tilapia',
      emoji: '\u{1F41F}', // 🐟
      previewAsset: 'assets/food/ghana/ghana_tilapia_chef.png',
      coloringPageId: 'food_tilapia',
      funFact: 'Grilled tilapia is a favorite street and home meal.',
      didYouKnow: [
        'Tilapia is often served with pepper and onions.',
        'Many lakes in Ghana are known for fish farming.',
      ],
    ),
    FoodDish(
      id: 'palmnut',
      name: 'Palm Nut Soup',
      emoji: '\u{1F372}', // 🍲
      previewAsset: 'assets/food/ghana/ghana_palmnut_soup_chef.png',
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
      previewAsset: 'assets/food/ghana/ghana_fried_rice_chef.png',
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
      previewAsset: 'assets/food/nigeria/nigeria_jollof_chef.png',
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
      previewAsset: 'assets/food/nigeria/nigeria_suya_chef.png',
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
      previewAsset: 'assets/food/nigeria/nigeria_pounded_yam_chef.png',
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
      previewAsset: 'assets/food/nigeria/nigeria_egusi_chef.png',
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
      previewAsset: 'assets/food/nigeria/nigeria_chin_chin_chef.png',
      coloringPageId: 'cooking',
      funFact: 'Chin chin is a crunchy fried snack loved by kids.',
      didYouKnow: [
        'Chin chin is especially popular during celebrations.',
        'It comes in many shapes and can be sweet or spicy.',
      ],
    ),
  ],
);

/// Country → Food pack registry.
final Map<String, FoodPack> foodRegistry = {
  'ghana': _ghanaFoodPack,
  'usa': _usaFoodPack,
  'nigeria': _nigeriaFoodPack,
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
