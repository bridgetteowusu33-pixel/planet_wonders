import '../models/step_type.dart';
import '../models/v2_recipe.dart';
import '../models/v2_recipe_step.dart';

// ---------------------------------------------------------------------------
// Nigeria — showcase recipes with varied V2 step types
// ---------------------------------------------------------------------------

const _i = 'assets/cooking/v2/nigeria/ingredients';

const nigeriaJollofV2 = V2Recipe(
  id: 'nigeria_jollof_v2',
  countryId: 'nigeria',
  name: 'Jollof Rice',
  emoji: '\u{1F35B}', // 🍛
  dishImagePath: 'assets/food/nigeria/ng_jollof_chef.webp',
  characterName: 'Adetutu',
  difficulty: V2Difficulty.medium,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'rice', name: 'Rice', emoji: '\u{1F35A}', assetPath: '$_i/rice.webp'),
    V2Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}', assetPath: '$_i/tomato.webp'),
    V2Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}', assetPath: '$_i/onion.webp'),
    V2Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'),
    V2Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}', assetPath: '$_i/oil.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to blend the tomatoes and peppers!',
      chefLine: 'Adetutu says: We blend it fresh!',
      targetCount: 6,
      ingredientIds: <String>['tomato', 'pepper'],
      factText: 'Nigerian jollof starts with a fresh tomato and pepper blend.',
    ),
    V2RecipeStep(
      type: V2StepType.fry,
      instruction: 'Hold to fry the oil until it shimmers!',
      chefLine: 'Hot hot! Careful! The oil is the secret!',
      durationMs: 3000,
      ingredientIds: <String>['oil'],
      factText: 'Heating the oil first gives jollof its smoky base.',
    ),
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the blended tomatoes and rice into the pot!',
      chefLine: 'Adetutu says: In they go!',
      factText: 'The tomato sauce coats every grain of rice.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Stir carefully \u{2014} don\u{2019}t break the rice!',
      chefLine: 'Nice mixing! Gentle stirring is the key!',
      factText: 'Stirring too hard will make the rice mushy.',
    ),
    V2RecipeStep(
      type: V2StepType.season,
      instruction: 'Shake to add seasoning cubes and spices!',
      chefLine: 'Adetutu says: The seasoning makes it special!',
      targetCount: 3,
      ingredientIds: <String>['pepper'],
      factText: 'Every Nigerian cook has their own secret spice mix.',
    ),
    V2RecipeStep(
      type: V2StepType.simmer,
      instruction: 'Let it cook low and slow \u{2014} tap the bubbles!',
      chefLine: 'Adetutu says: Patience makes party jollof!',
      durationMs: 5000,
      factText: 'The smoky bottom layer is called "the party" \u{2014} it\u{2019}s the best part!',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Scoop the jollof onto the plate!',
      chefLine: 'Nailed it, Chef! Beautiful! Who wants some?',
      targetCount: 3,
      factText: 'Nigerian jollof is always the star of every party.',
    ),
  ],
  funFacts: <String>[
    'Nigerian jollof is famous across Africa!',
    'Smoky party jollof is the most loved style.',
    'Every cook has a secret jollof recipe.',
    'The Ghana vs Nigeria jollof debate is a fun and friendly rivalry!',
  ],
);

const nigeriaSuyaV2 = V2Recipe(
  id: 'nigeria_suya_v2',
  countryId: 'nigeria',
  name: 'Suya',
  emoji: '\u{1F356}', // 🍖
  dishImagePath: 'assets/food/nigeria/ng_suya_chef.webp',
  characterName: 'Adetutu',
  difficulty: V2Difficulty.easy,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'meat', name: 'Beef', emoji: '\u{1F969}', assetPath: '$_i/meat.webp'),
    V2Ingredient(id: 'spice', name: 'Yaji Spice', emoji: '\u{1F336}'),
    V2Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}', assetPath: '$_i/onion.webp'),
    V2Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}', assetPath: '$_i/oil.webp'),
    V2Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}', assetPath: '$_i/tomato.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to slice the beef into thin strips!',
      chefLine: 'Adetutu says: Thin slices cook best!',
      targetCount: 5,
      ingredientIds: <String>['meat'],
      factText: 'Suya is made with thinly sliced beef on wooden skewers.',
    ),
    V2RecipeStep(
      type: V2StepType.season,
      instruction: 'Shake the yaji spice onto the meat!',
      chefLine: 'Adetutu says: More spice, more flavour!',
      targetCount: 4,
      ingredientIds: <String>['spice'],
      factText: 'The special spice mix is called yaji \u{2014} made from ground peanuts and chilli.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Rub the spice into every piece of meat!',
      chefLine: 'Nice mixing! Coat it all!',
      factText: 'Rubbing the spice in makes the flavour go deep into the meat.',
    ),
    V2RecipeStep(
      type: V2StepType.fry,
      instruction: 'Hold to grill the suya over the fire!',
      chefLine: 'Hot hot! Careful! The grill makes it smoky and delicious!',
      durationMs: 3500,
      ingredientIds: <String>['meat'],
      factText: 'Suya sellers grill over charcoal for a smoky taste.',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Serve the suya with sliced onions and tomatoes!',
      chefLine: 'Nailed it, Chef! Suya night is the best night!',
      targetCount: 2,
      factText: 'Suya is wrapped in newspaper or brown paper \u{2014} it\u{2019}s street food!',
    ),
  ],
  funFacts: <String>[
    'Suya is a popular street food sold in the evening.',
    'The special spice mix is called yaji.',
    'Suya sellers wrap it in newspaper or brown paper.',
    'Suya stands light up Nigerian streets at night!',
  ],
);

const nigeriaPoundedYamV2 = V2Recipe(
  id: 'nigeria_pounded_yam_v2',
  countryId: 'nigeria',
  name: 'Pounded Yam',
  emoji: '\u{1F372}', // 🍲
  dishImagePath: 'assets/food/nigeria/ng_pounded_yam_chef.webp',
  characterName: 'Adetutu',
  difficulty: V2Difficulty.medium,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'yam', name: 'Yam', emoji: '\u{1F954}'),
    V2Ingredient(id: 'water', name: 'Water', emoji: '\u{1F4A7}'),
    V2Ingredient(id: 'soup', name: 'Egusi Soup', emoji: '\u{1F958}', assetPath: '$_i/soup.webp'),
    V2Ingredient(id: 'meat', name: 'Meat', emoji: '\u{1F969}', assetPath: '$_i/meat.webp'),
    V2Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to peel and cut the yam into pieces!',
      chefLine: 'Adetutu says: Peel it clean!',
      targetCount: 5,
      ingredientIds: <String>['yam'],
      factText: 'Yam is a large root vegetable grown all over Nigeria.',
    ),
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the yam pieces and water into the pot!',
      chefLine: 'Adetutu says: Let\u{2019}s boil it soft!',
      factText: 'The yam must be boiled until it is very soft before pounding.',
    ),
    V2RecipeStep(
      type: V2StepType.boil,
      instruction: 'Hold to boil the yam until tender!',
      chefLine: 'Hot hot! Careful! Almost soft enough!',
      durationMs: 3500,
      ingredientIds: <String>['yam'],
      factText: 'Boiling softens the yam so it can be pounded smooth.',
    ),
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to pound the yam smooth and stretchy!',
      chefLine: 'Adetutu says: Pound it! Pound it! So smooth!',
      targetCount: 8,
      ingredientIds: <String>['yam'],
      factText: 'Pounded yam is made with a big wooden mortar and pestle.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Turn and fold the yam until perfectly stretchy!',
      chefLine: 'Nice mixing! Look how stretchy it is!',
      factText: 'Good pounded yam is smooth and stretchy like soft dough.',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Serve the pounded yam with egusi soup!',
      chefLine: 'Nailed it, Chef! A true Nigerian feast!',
      targetCount: 2,
      factText: 'In Nigeria, pounded yam is eaten with egusi, ogbono, or vegetable soup.',
    ),
  ],
  funFacts: <String>[
    'Pounded yam is smooth and stretchy like soft dough!',
    'It is pounded with a big wooden mortar and pestle.',
    'In Nigeria, it is eaten with egusi, ogbono, or vegetable soup.',
    'The sound of pounding yam is a familiar rhythm in Nigerian homes!',
  ],
);

const nigeriaEgusiV2 = V2Recipe(
  id: 'nigeria_egusi_v2',
  countryId: 'nigeria',
  name: 'Egusi Soup',
  emoji: '\u{1F958}', // 🥘
  dishImagePath: 'assets/food/nigeria/ng_egusi_chef.webp',
  characterName: 'Adetutu',
  difficulty: V2Difficulty.medium,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'melon_seed', name: 'Melon Seeds', emoji: '\u{1F348}'),
    V2Ingredient(id: 'spinach', name: 'Spinach', emoji: '\u{1F96C}'),
    V2Ingredient(id: 'palm_oil', name: 'Palm Oil', emoji: '\u{1FAD9}', assetPath: '$_i/oil.webp'),
    V2Ingredient(id: 'meat', name: 'Meat', emoji: '\u{1F969}', assetPath: '$_i/meat.webp'),
    V2Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to grind the melon seeds into powder!',
      chefLine: 'Adetutu says: Grind them fine!',
      targetCount: 6,
      ingredientIds: <String>['melon_seed'],
      factText: 'Egusi is made from ground melon seeds \u{2014} not the fruit!',
    ),
    V2RecipeStep(
      type: V2StepType.fry,
      instruction: 'Hold to fry the palm oil until it melts!',
      chefLine: 'Hot hot! Careful! Palm oil gives it the orange colour!',
      durationMs: 2500,
      ingredientIds: <String>['palm_oil'],
      factText: 'Palm oil is a traditional cooking oil used all over West Africa.',
    ),
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the ground egusi and meat into the pot!',
      chefLine: 'Adetutu says: In they go!',
      factText: 'The ground melon seeds thicken the soup as they cook.',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Stir the thick soup until everything is mixed!',
      chefLine: 'Nice mixing! It\u{2019}s getting thick!',
      factText: 'Egusi soup gets thicker the more you stir it.',
    ),
    V2RecipeStep(
      type: V2StepType.season,
      instruction: 'Shake to add pepper and crayfish seasoning!',
      chefLine: 'Adetutu says: The crayfish makes it amazing!',
      targetCount: 3,
      ingredientIds: <String>['pepper'],
      factText: 'Dried crayfish is a secret seasoning in many Nigerian soups.',
    ),
    V2RecipeStep(
      type: V2StepType.simmer,
      instruction: 'Add the spinach and let it simmer!',
      chefLine: 'Adetutu says: The greens go in last!',
      durationMs: 4000,
      factText: 'The leafy greens stirred in at the end make it extra nutritious.',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Serve the egusi soup in a big bowl!',
      chefLine: 'Nailed it, Chef! Egusi is ready! Dig in!',
      targetCount: 2,
      factText: 'Egusi soup is one of the most popular soups in Nigeria.',
    ),
  ],
  funFacts: <String>[
    'Egusi is made from ground melon seeds \u{2014} not the fruit!',
    'It is one of the most popular soups in Nigeria.',
    'The leafy greens stirred in at the end make it extra nutritious.',
    'Egusi soup is best enjoyed with pounded yam or fufu!',
  ],
);

const nigeriaChinChinV2 = V2Recipe(
  id: 'nigeria_chin_chin_v2',
  countryId: 'nigeria',
  name: 'Chin Chin',
  emoji: '\u{1F36A}', // 🍪
  dishImagePath: 'assets/food/nigeria/ng_chin_chin_chef.webp',
  characterName: 'Adetutu',
  difficulty: V2Difficulty.easy,
  ingredients: <V2Ingredient>[
    V2Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'),
    V2Ingredient(id: 'sugar', name: 'Sugar', emoji: '\u{1F36C}'),
    V2Ingredient(id: 'butter', name: 'Butter', emoji: '\u{1F9C8}'),
    V2Ingredient(id: 'milk', name: 'Milk', emoji: '\u{1F95B}'),
    V2Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}', assetPath: '$_i/oil.webp'),
  ],
  steps: <V2RecipeStep>[
    V2RecipeStep(
      type: V2StepType.addIngredients,
      instruction: 'Drag the flour, sugar, and butter into the bowl!',
      chefLine: 'Adetutu says: Let\u{2019}s make chin chin!',
      factText: 'Chin chin is a crunchy fried dough snack loved by everyone!',
    ),
    V2RecipeStep(
      type: V2StepType.stir,
      instruction: 'Stir and knead the dough until smooth!',
      chefLine: 'Nice mixing! Mix it all together!',
      factText: 'Kneading makes the dough stretchy and smooth.',
    ),
    V2RecipeStep(
      type: V2StepType.chop,
      instruction: 'Tap to cut the dough into tiny squares!',
      chefLine: 'Adetutu says: Small pieces fry best!',
      targetCount: 6,
      ingredientIds: <String>['flour'],
      factText: 'Each family cuts their chin chin in different shapes and sizes.',
    ),
    V2RecipeStep(
      type: V2StepType.fry,
      instruction: 'Hold to fry the oil for deep frying!',
      chefLine: 'Hot hot! Careful! Get that oil nice and hot!',
      durationMs: 3000,
      ingredientIds: <String>['oil'],
      factText: 'The oil must be very hot so the chin chin fries golden and crunchy.',
    ),
    V2RecipeStep(
      type: V2StepType.simmer,
      instruction: 'Watch the chin chin fry \u{2014} tap when golden!',
      chefLine: 'Adetutu says: Don\u{2019}t let them burn!',
      durationMs: 4000,
      factText: 'Golden brown chin chin is the crunchiest!',
    ),
    V2RecipeStep(
      type: V2StepType.plate,
      instruction: 'Scoop out the crunchy chin chin!',
      chefLine: 'Nailed it, Chef! Try not to eat them all!',
      targetCount: 3,
      factText: 'Chin chin is a must-have at Nigerian parties and celebrations.',
    ),
  ],
  funFacts: <String>[
    'Chin chin is a crunchy fried dough snack loved by everyone!',
    'It is a must-have at Nigerian parties and celebrations.',
    'Every family has their own special chin chin recipe.',
    'Some people add nutmeg or vanilla for extra flavour!',
  ],
);

// ---------------------------------------------------------------------------
// Registry
// ---------------------------------------------------------------------------

final List<V2Recipe> nigeriaV2Recipes = <V2Recipe>[
  nigeriaJollofV2,
  nigeriaSuyaV2,
  nigeriaPoundedYamV2,
  nigeriaEgusiV2,
  nigeriaChinChinV2,
];
