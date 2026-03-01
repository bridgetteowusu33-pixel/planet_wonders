import '../models/step_type.dart';
import '../models/v2_recipe.dart';
import '../models/v2_recipe_step.dart';

// ---------------------------------------------------------------------------
// Ghana — showcase recipes with varied V2 step types
// ---------------------------------------------------------------------------

const _i = 'assets/cooking/v2/ghana/ingredients';

const ghanaJollofV2 = V2Recipe(
  id: 'ghana_jollof_v2',
  countryId: 'ghana',
  name: 'Jollof Rice',
  emoji: '\u{1F35B}', // 🍛
  dishImagePath: 'assets/food/ghana/ghana_jollof_chef.webp',
  characterName: 'Afia',
  difficulty: V2Difficulty.medium,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'rice', name: 'Rice', emoji: '\u{1F35A}', assetPath: '$_i/rice.webp'),
    V2Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}', assetPath: '$_i/tomato.webp'),
    V2Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}', assetPath: '$_i/onion.webp'),
    V2Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}', assetPath: '$_i/pepper.webp'),
    V2Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}', assetPath: '$_i/oil.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag all the ingredients into the pot!',
      chefLine: 'Afia says: Let\u{2019}s get cooking!',
      factText: 'Jollof rice is loved across West Africa.',
    ),
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to chop the tomatoes and onions!',
      chefLine: 'Afia says: Chop chop chop! Nice work!',
      targetCount: 6,
      ingredientIds: <String>['tomato', 'onion'],
      factText: 'Fresh tomatoes give jollof its rich red colour.',
    ),
    V2RecipeStep(
      type: V2StepType.fry,
      instruction: 'Hold to fry the oil \u{2014} don\u{2019}t let it burn!',
      chefLine: 'Afia says: Careful! Hot oil is important.',
      durationMs: 3000,
      ingredientIds: <String>['oil'],
      factText: 'Heating the oil first helps the spices release flavour.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Stir in circles until everything is mixed!',
      chefLine: 'Afia says: Round and round we go!',
      factText: 'Stirring keeps the rice from sticking to the pot.',
    ),
    V2RecipeStep(
      type: V2StepType.season,
      instruction: 'Shake or tap to add the perfect amount of spice!',
      chefLine: 'Ooh, spicy! Afia loves it!',
      targetCount: 3,
      ingredientIds: <String>['pepper'],
      factText: 'Every family has their own secret spice mix.',
    ),
    V2RecipeStep(
      type: V2StepType.simmer,
      instruction: 'Watch the pot and tap the bubbles!',
      chefLine: 'Afia says: Let it cook low and slow!',
      durationMs: 5000,
      factText: 'Simmering is the secret to perfect party jollof.',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Scoop the jollof onto the plate!',
      chefLine: 'Afia says: Beautiful plating, little chef!',
      targetCount: 3,
      factText: 'Families often cook jollof at celebrations.',
    ),
  ],
  funFacts: <String>[
    'Jollof rice is loved across West Africa.',
    'Families often cook jollof at celebrations.',
    'Recipes are unique in every home.',
    'The debate over who makes the best jollof is a friendly rivalry!',
  ],
);

const ghanaFufuV2 = V2Recipe(
  id: 'ghana_fufu_v2',
  countryId: 'ghana',
  name: 'Fufu',
  emoji: '\u{1F372}', // 🍲
  dishImagePath: 'assets/food/ghana/ghana_fufu_chef.webp',
  characterName: 'Afia',
  difficulty: V2Difficulty.medium,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'cassava', name: 'Cassava', emoji: '\u{1F954}', assetPath: '$_i/cassava.webp'),
    V2Ingredient(id: 'plantain', name: 'Plantain', emoji: '\u{1F34C}', assetPath: '$_i/plantain.webp'),
    V2Ingredient(id: 'soup', name: 'Soup', emoji: '\u{1F372}', assetPath: '$_i/soup.webp'),
    V2Ingredient(id: 'meat', name: 'Meat', emoji: '\u{1F969}', assetPath: '$_i/meat.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the cassava and plantain into the pot!',
      chefLine: 'Afia says: First, we boil these!',
      factText: 'Fufu is made from starchy root vegetables.',
    ),
    V2RecipeStep(
      type: V2StepType.boil,
      instruction: 'Hold to boil the cassava until soft!',
      chefLine: 'Afia says: Keep it going \u{2014} almost there!',
      durationMs: 3000,
      ingredientIds: <String>['cassava', 'plantain'],
      factText: 'Boiling softens the cassava for pounding.',
    ),
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to pound the fufu!',
      chefLine: 'Afia says: Pound it smooth and stretchy!',
      targetCount: 8,
      ingredientIds: <String>['cassava', 'plantain'],
      factText: 'Traditional fufu is pounded with a big wooden mortar.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Stir in circles until the fufu is smooth!',
      chefLine: 'Afia says: So smooth and stretchy!',
      factText: 'You swallow fufu without chewing!',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Serve the fufu in a bowl with hot soup!',
      chefLine: 'Afia says: Perfect! Time to eat!',
      targetCount: 2,
      factText: 'Light soup or groundnut soup are the most popular.',
    ),
  ],
  funFacts: <String>[
    'Fufu is pounded until it is stretchy like soft dough!',
    'You swallow fufu without chewing \u{2014} it slides right down.',
    'Light soup or groundnut soup are the most popular to eat with fufu.',
  ],
);

const ghanaKeleweleV2 = V2Recipe(
  id: 'ghana_kelewele_v2',
  countryId: 'ghana',
  name: 'Kelewele',
  emoji: '\u{1F34C}', // 🍌
  dishImagePath: 'assets/food/ghana/ghana_kelewele_chef.webp',
  characterName: 'Afia',
  difficulty: V2Difficulty.easy,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'plantain', name: 'Plantain', emoji: '\u{1F34C}', assetPath: '$_i/plantain.webp'),
    V2Ingredient(id: 'ginger', name: 'Ginger', emoji: '\u{1FAD0}', assetPath: '$_i/ginger.webp'),
    V2Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}', assetPath: '$_i/pepper.webp'),
    V2Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}', assetPath: '$_i/oil.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to slice the plantains!',
      chefLine: 'Afia says: Slice them into chunks!',
      targetCount: 5,
      ingredientIds: <String>['plantain'],
      factText: 'Kelewele uses ripe, sweet plantains.',
    ),
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the spices onto the plantain pieces!',
      chefLine: 'Afia says: Ginger and pepper make it special!',
      factText: 'The ginger and chilli make it sweet and spicy.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Mix the spiced plantain pieces!',
      chefLine: 'Afia says: Coat every piece!',
      factText: 'Mixing ensures every piece is full of flavour.',
    ),
    V2RecipeStep(
      type: V2StepType.fry,
      instruction: 'Hold to fry the kelewele until golden!',
      chefLine: 'Afia says: Listen to it sizzle!',
      durationMs: 3500,
      ingredientIds: <String>['oil'],
      factText: 'Deep frying makes kelewele crispy on the outside.',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Serve the crispy kelewele!',
      chefLine: 'Afia says: Crunchy and delicious!',
      targetCount: 2,
      factText: 'It is often sold at night markets all over Ghana.',
    ),
  ],
  funFacts: <String>[
    'Kelewele is spiced fried plantain \u{2014} a popular street snack!',
    'The ginger and chilli make it sweet and spicy at the same time.',
    'It is often sold at night markets all over Ghana.',
  ],
);

const ghanaWaakyeV2 = V2Recipe(
  id: 'ghana_waakye_v2',
  countryId: 'ghana',
  name: 'Waakye',
  emoji: '\u{1F35B}', // 🍛
  dishImagePath: 'assets/food/ghana/ghana_waakye_chef.webp',
  characterName: 'Afia',
  difficulty: V2Difficulty.easy,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'rice', name: 'Rice', emoji: '\u{1F35A}', assetPath: '$_i/rice.webp'),
    V2Ingredient(id: 'beans', name: 'Beans', emoji: '\u{1FAD8}', assetPath: '$_i/beans.webp'),
    V2Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}', assetPath: '$_i/tomato.webp'),
    V2Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}', assetPath: '$_i/onion.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the rice and beans into the pot!',
      chefLine: 'Afia says: Rice and beans together!',
      factText: 'Waakye is a famous Ghanaian rice-and-beans meal.',
    ),
    V2RecipeStep(
      type: V2StepType.boil,
      instruction: 'Hold to boil until the water turns red!',
      chefLine: 'Afia says: The millet leaves turn it red!',
      durationMs: 3000,
      factText: 'Dried millet leaves give waakye its special red colour.',
    ),
    V2RecipeStep(
      type: V2StepType.simmer,
      instruction: 'Watch the pot and tap the bubbles!',
      chefLine: 'Afia says: Low and slow makes it perfect!',
      durationMs: 4000,
      factText: 'Many families enjoy waakye for breakfast or lunch.',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Serve the waakye with stew on top!',
      chefLine: 'Afia says: Breakfast is served!',
      targetCount: 2,
      factText: 'Every home has its own waakye style.',
    ),
  ],
  funFacts: <String>[
    'Waakye is a famous Ghanaian rice-and-beans meal.',
    'Many families enjoy waakye for breakfast or lunch.',
    'Every home has its own waakye style.',
  ],
);

const ghanaBankuV2 = V2Recipe(
  id: 'ghana_banku_v2',
  countryId: 'ghana',
  name: 'Banku & Tilapia',
  emoji: '\u{1F41F}', // 🐟
  dishImagePath: 'assets/food/ghana/ghana_banku_chef.webp',
  characterName: 'Afia',
  difficulty: V2Difficulty.medium,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'corn_dough', name: 'Corn Dough', emoji: '\u{1F33D}', assetPath: '$_i/corn_dough.webp'),
    V2Ingredient(id: 'cassava', name: 'Cassava', emoji: '\u{1F954}', assetPath: '$_i/cassava.webp'),
    V2Ingredient(id: 'fish', name: 'Tilapia', emoji: '\u{1F41F}', assetPath: '$_i/fish.webp'),
    V2Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}', assetPath: '$_i/pepper.webp'),
    V2Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}', assetPath: '$_i/tomato.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the corn dough and cassava into the pot!',
      chefLine: 'Afia says: Let\u{2019}s make smooth banku!',
      factText: 'Banku is made from fermented corn and cassava dough.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Stir the banku in circles until it is smooth!',
      chefLine: 'Afia says: Keep stirring \u{2014} nice and smooth!',
      factText: 'Gentle stirring keeps the texture perfect.',
    ),
    V2RecipeStep(
      type: V2StepType.fry,
      instruction: 'Hold to grill the tilapia until crispy!',
      chefLine: 'Afia says: Listen to the fish sizzle!',
      durationMs: 3000,
      ingredientIds: <String>['fish'],
      factText: 'Tilapia is often grilled over charcoal for a smoky flavour.',
    ),
    V2RecipeStep(
      type: V2StepType.season,
      instruction: 'Shake to add pepper and spices to the fish!',
      chefLine: 'Afia says: A little pepper makes it special!',
      targetCount: 3,
      ingredientIds: <String>['pepper'],
      factText: 'The hot pepper sauce is called shito.',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Serve the banku with grilled tilapia!',
      chefLine: 'Afia says: What a beautiful plate!',
      targetCount: 2,
      factText: 'Banku and tilapia is eaten with your hands in Ghana.',
    ),
  ],
  funFacts: <String>[
    'Banku is made by mixing corn and cassava dough together!',
    'It is always eaten with your hands in Ghana.',
    'Grilled tilapia with hot pepper sauce is the perfect partner.',
  ],
);

const ghanaFriedRiceV2 = V2Recipe(
  id: 'ghana_fried_rice_v2',
  countryId: 'ghana',
  name: 'Fried Rice',
  emoji: '\u{1F35A}', // 🍚
  dishImagePath: 'assets/food/ghana/ghana_fried_rice_chef.webp',
  characterName: 'Afia',
  difficulty: V2Difficulty.easy,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'rice', name: 'Rice', emoji: '\u{1F35A}', assetPath: '$_i/rice.webp'),
    V2Ingredient(id: 'egg', name: 'Egg', emoji: '\u{1F95A}', assetPath: '$_i/egg.webp'),
    V2Ingredient(id: 'carrot', name: 'Carrot', emoji: '\u{1F955}', assetPath: '$_i/carrot.webp'),
    V2Ingredient(id: 'peas', name: 'Peas', emoji: '\u{1F966}', assetPath: '$_i/peas.webp'),
    V2Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}', assetPath: '$_i/oil.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to chop the vegetables!',
      chefLine: 'Afia says: Chop the carrots small!',
      targetCount: 5,
      ingredientIds: <String>['carrot', 'peas'],
      factText: 'Colourful vegetables make fried rice beautiful.',
    ),
    V2RecipeStep(
      type: V2StepType.fry,
      instruction: 'Hold to fry the oil in the wok!',
      chefLine: 'Afia says: Hot oil makes things sizzle!',
      durationMs: 2500,
      ingredientIds: <String>['oil'],
      factText: 'A very hot wok is the secret to great fried rice.',
    ),
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the rice and veggies into the wok!',
      chefLine: 'Afia says: In they go!',
      factText: 'Ghanaian fried rice often includes shredded chicken too.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Stir quickly so nothing sticks!',
      chefLine: 'Afia says: Toss and stir!',
      factText: 'Quick stirring keeps the rice from getting mushy.',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Serve the colourful fried rice!',
      chefLine: 'Afia says: A rainbow on a plate!',
      targetCount: 2,
      factText: 'Fried rice is a popular party and celebration dish.',
    ),
  ],
  funFacts: <String>[
    'Ghanaian fried rice is a party favourite \u{2014} colourful and tasty!',
    'It is often served at celebrations with grilled chicken.',
    'The vegetables give it a rainbow of colours.',
  ],
);

const ghanaKokoV2 = V2Recipe(
  id: 'ghana_koko_v2',
  countryId: 'ghana',
  name: 'Koko',
  emoji: '\u{2615}', // ☕
  dishImagePath: 'assets/food/ghana/ghana_koko_chef.webp',
  characterName: 'Afia',
  difficulty: V2Difficulty.easy,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'millet', name: 'Millet', emoji: '\u{1F33E}', assetPath: '$_i/millet.webp'),
    V2Ingredient(id: 'water', name: 'Water', emoji: '\u{1F4A7}', assetPath: '$_i/water.webp'),
    V2Ingredient(id: 'sugar', name: 'Sugar', emoji: '\u{1F36C}', assetPath: '$_i/sugar.webp'),
    V2Ingredient(id: 'ginger', name: 'Ginger', emoji: '\u{1FAD0}', assetPath: '$_i/ginger.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the millet and water into the pot!',
      chefLine: 'Afia says: Good morning! Let\u{2019}s make koko!',
      factText: 'Koko is made from fermented millet or corn.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Stir the porridge until thick and smooth!',
      chefLine: 'Afia says: Keep stirring \u{2014} no lumps!',
      factText: 'You need to stir constantly so it doesn\u{2019}t get lumpy.',
    ),
    V2RecipeStep(
      type: V2StepType.season,
      instruction: 'Tap to add sugar and ginger!',
      chefLine: 'Afia says: A little sweetness and spice!',
      targetCount: 3,
      ingredientIds: <String>['sugar', 'ginger'],
      factText: 'Ginger makes koko warm and spicy \u{2014} perfect for chilly mornings.',
    ),
    V2RecipeStep(
      type: V2StepType.simmer,
      instruction: 'Watch the koko simmer and tap the bubbles!',
      chefLine: 'Afia says: Almost ready \u{2014} it smells amazing!',
      durationMs: 4000,
      factText: 'Koko is often sold by women carrying big pots at the market.',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Pour the warm koko into a bowl!',
      chefLine: 'Afia says: Breakfast is served!',
      targetCount: 2,
      factText: 'Ghanaians love to eat koko with koose (bean cakes) or bread.',
    ),
  ],
  funFacts: <String>[
    'Koko is a warm spiced porridge eaten for breakfast in Ghana!',
    'It is made from fermented millet or corn.',
    'Ghanaians love to eat koko with koose (bean cakes) or bread.',
  ],
);

const ghanaPeanutButterSoupV2 = V2Recipe(
  id: 'ghana_peanut_butter_soup_v2',
  countryId: 'ghana',
  name: 'Peanut Butter Soup',
  emoji: '\u{1F95C}', // 🥜
  dishImagePath: 'assets/food/ghana/ghana_peanut_butter_soup_chef.webp',
  characterName: 'Afia',
  difficulty: V2Difficulty.medium,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'peanut', name: 'Peanut Butter', emoji: '\u{1F95C}', assetPath: '$_i/peanut.webp'),
    V2Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}', assetPath: '$_i/tomato.webp'),
    V2Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}', assetPath: '$_i/onion.webp'),
    V2Ingredient(id: 'chicken', name: 'Chicken', emoji: '\u{1F357}', assetPath: '$_i/chicken.webp'),
    V2Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}', assetPath: '$_i/pepper.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to crush the peanuts into a smooth paste!',
      chefLine: 'Afia says: Crush them well!',
      targetCount: 6,
      ingredientIds: <String>['peanut'],
      factText: 'Grinding peanuts into paste is what makes the soup so creamy.',
    ),
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the tomatoes, onion, and chicken into the pot!',
      chefLine: 'Afia says: In they go!',
      factText: 'Tomatoes and onions build the rich base of the soup.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Stir the peanut paste into the soup!',
      chefLine: 'Afia says: Watch it turn thick and orange!',
      factText: 'The paste slowly dissolves and makes the soup thick and creamy.',
    ),
    V2RecipeStep(
      type: V2StepType.season,
      instruction: 'Shake to add pepper and spices!',
      chefLine: 'Afia says: Just a little heat!',
      targetCount: 3,
      ingredientIds: <String>['pepper'],
      factText: 'Every family has their own secret spice blend.',
    ),
    V2RecipeStep(
      type: V2StepType.simmer,
      instruction: 'Let the soup simmer low and slow!',
      chefLine: 'Afia says: Patience makes it perfect!',
      durationMs: 5000,
      factText: 'Peanut butter soup is best eaten with fufu or rice balls.',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Serve the creamy soup with fufu!',
      chefLine: 'Afia says: The whole family will love this!',
      targetCount: 2,
      factText: 'Peanut butter soup is one of the most popular soups in Ghana.',
    ),
  ],
  funFacts: <String>[
    'Peanut butter soup is made from crushed peanuts \u{2014} so creamy!',
    'It is one of the most popular soups in Ghana.',
    'Ghanaians love to eat it with fufu or rice balls.',
  ],
);

// ---------------------------------------------------------------------------
// Registry
// ---------------------------------------------------------------------------

final List<V2Recipe> ghanaV2Recipes = <V2Recipe>[
  ghanaJollofV2,
  ghanaFufuV2,
  ghanaKeleweleV2,
  ghanaWaakyeV2,
  ghanaBankuV2,
  ghanaFriedRiceV2,
  ghanaKokoV2,
  ghanaPeanutButterSoupV2,
];
