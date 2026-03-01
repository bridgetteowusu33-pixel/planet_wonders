import '../models/cooking_step.dart';
import '../models/recipe.dart';

const ghanaJollofRecipe = Recipe(
  id: 'ghana_jollof',
  countryId: 'ghana',
  name: 'Jollof Rice',
  emoji: '\u{1F35B}', // 🍛
  ingredients: [
    Ingredient(id: 'rice', name: 'Rice', emoji: '\u{1F35A}'), // 🍚
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}'), // 🍅
    Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}'), // 🧅
    Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'), // 🌶
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag all ingredients into the pot.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir in circles until the ring is full.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Drag the spoon to serve onto the plate.',
    ),
  ],
  funFacts: [
    'Jollof is loved across West Africa.',
    'Families often cook jollof at celebrations.',
    'Recipes are unique in every home.',
  ],
);

const ghanaWaakyeRecipe = Recipe(
  id: 'ghana_waakye',
  countryId: 'ghana',
  name: 'Waakye',
  emoji: '\u{1F35B}', // 🍛
  ingredients: [
    Ingredient(id: 'rice', name: 'Rice', emoji: '\u{1F35A}'), // 🍚
    Ingredient(id: 'beans', name: 'Beans', emoji: '\u{1FAD8}'), // 🫘
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}'), // 🍅
    Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}'), // 🧅
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag rice, beans, veggies, and oil into the pot.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir in circles until the ring is full.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve waakye onto the plate.',
    ),
  ],
  funFacts: [
    'Waakye is a famous Ghanaian rice-and-beans meal.',
    'Many families enjoy waakye for breakfast or lunch.',
    'Every home has its own waakye style.',
  ],
);

const ghanaBankuRecipe = Recipe(
  id: 'ghana_banku',
  countryId: 'ghana',
  name: 'Banku & Tilapia',
  emoji: '\u{1F41F}', // 🐟
  ingredients: [
    Ingredient(id: 'corn_dough', name: 'Corn Dough', emoji: '\u{1F33D}'), // 🌽
    Ingredient(id: 'cassava', name: 'Cassava', emoji: '\u{1F954}'), // 🥔
    Ingredient(id: 'fish', name: 'Tilapia', emoji: '\u{1F41F}'), // 🐟
    Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'), // 🌶
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}'), // 🍅
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the corn dough and cassava into the pot.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the banku in circles until it is smooth.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the banku with grilled tilapia on the plate.',
    ),
  ],
  funFacts: [
    'Banku is made by mixing corn and cassava dough together!',
    'It is always eaten with your hands in Ghana.',
    'Grilled tilapia with hot pepper sauce is the perfect partner.',
  ],
);

const ghanaFufuRecipe = Recipe(
  id: 'ghana_fufu',
  countryId: 'ghana',
  name: 'Fufu',
  emoji: '\u{1F372}', // 🍲
  ingredients: [
    Ingredient(id: 'cassava', name: 'Cassava', emoji: '\u{1F954}'), // 🥔
    Ingredient(id: 'plantain', name: 'Plantain', emoji: '\u{1F34C}'), // 🍌
    Ingredient(id: 'soup', name: 'Soup', emoji: '\u{1F372}'), // 🍲
    Ingredient(id: 'meat', name: 'Meat', emoji: '\u{1F969}'), // 🥩
    Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'), // 🌶
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the cassava and plantain into the pot to boil.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Pound and stir the fufu until it is stretchy and smooth.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the fufu in a bowl with hot soup.',
    ),
  ],
  funFacts: [
    'Fufu is pounded until it is stretchy like soft dough!',
    'You swallow fufu without chewing \u{2014} it slides right down.',
    'Light soup or groundnut soup are the most popular to eat with fufu.',
  ],
);

const ghanaKokoRecipe = Recipe(
  id: 'ghana_koko',
  countryId: 'ghana',
  name: 'Koko',
  emoji: '\u{2615}', // ☕
  ingredients: [
    Ingredient(id: 'millet', name: 'Millet', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'water', name: 'Water', emoji: '\u{1F4A7}'), // 💧
    Ingredient(id: 'sugar', name: 'Sugar', emoji: '\u{1F36C}'), // 🍬
    Ingredient(id: 'ginger', name: 'Ginger', emoji: '\u{1FAD0}'), // 🫐→ginger
    Ingredient(id: 'bread', name: 'Bread', emoji: '\u{1F35E}'), // 🍞
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the millet and water into the pot.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the porridge in circles until it is thick and smooth.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Pour the koko into a bowl and serve with bread.',
    ),
  ],
  funFacts: [
    'Koko is a warm spiced porridge eaten for breakfast in Ghana!',
    'It is made from fermented millet or corn.',
    'Ghanaians love to eat koko with koose (bean cakes) or bread.',
  ],
);

const ghanaKeleweleRecipe = Recipe(
  id: 'ghana_kelewele',
  countryId: 'ghana',
  name: 'Kelewele',
  emoji: '\u{1F34C}', // 🍌
  ingredients: [
    Ingredient(id: 'plantain', name: 'Plantain', emoji: '\u{1F34C}'), // 🍌
    Ingredient(id: 'ginger', name: 'Ginger', emoji: '\u{1FAD0}'), // 🫐→ginger
    Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'), // 🌶
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
    Ingredient(id: 'salt', name: 'Salt', emoji: '\u{1F9C2}'), // 🧂
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the plantain and spices into the bowl to mix.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the spiced plantain pieces until coated.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the crispy kelewele on the plate.',
    ),
  ],
  funFacts: [
    'Kelewele is spiced fried plantain \u{2014} a popular street snack!',
    'The ginger and chilli make it sweet and spicy at the same time.',
    'It is often sold at night markets all over Ghana.',
  ],
);

const ghanaPeanutButterSoupRecipe = Recipe(
  id: 'ghana_peanut_butter_soup',
  countryId: 'ghana',
  name: 'Peanut Butter Soup',
  emoji: '\u{1F95C}', // 🥜
  ingredients: [
    Ingredient(id: 'peanut', name: 'Peanut Butter', emoji: '\u{1F95C}'), // 🥜
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}'), // 🍅
    Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}'), // 🧅
    Ingredient(id: 'chicken', name: 'Chicken', emoji: '\u{1F357}'), // 🍗
    Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'), // 🌶
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the peanut butter, tomato, and chicken into the pot.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the soup in circles until it is thick and rich.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the peanut butter soup in a bowl with fufu.',
    ),
  ],
  funFacts: [
    'Peanut butter soup is made from crushed peanuts \u{2014} so creamy!',
    'It is one of the most popular soups in Ghana.',
    'Ghanaians love to eat it with fufu or rice balls.',
  ],
);

const ghanaPalmnutRecipe = Recipe(
  id: 'ghana_palmnut',
  countryId: 'ghana',
  name: 'Palm Nut Soup',
  emoji: '\u{1F372}', // 🍲
  ingredients: [
    Ingredient(id: 'palm_fruit', name: 'Palm Fruit', emoji: '\u{1F334}'), // 🌴
    Ingredient(id: 'meat', name: 'Meat', emoji: '\u{1F969}'), // 🥩
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}'), // 🍅
    Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}'), // 🧅
    Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'), // 🌶
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the palm fruit, meat, and vegetables into the pot.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the soup until the palm oil mixes in beautifully.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the palm nut soup with fufu or rice.',
    ),
  ],
  funFacts: [
    'Palm nut soup gets its orange colour from the oil of palm fruits!',
    'It is one of the oldest traditional soups in Ghana.',
    'The palm fruits are boiled and pounded to extract the rich cream.',
  ],
);

const ghanaFriedRiceRecipe = Recipe(
  id: 'ghana_fried_rice',
  countryId: 'ghana',
  name: 'Fried Rice',
  emoji: '\u{1F35A}', // 🍚
  ingredients: [
    Ingredient(id: 'rice', name: 'Rice', emoji: '\u{1F35A}'), // 🍚
    Ingredient(id: 'egg', name: 'Egg', emoji: '\u{1F95A}'), // 🥚
    Ingredient(id: 'carrot', name: 'Carrot', emoji: '\u{1F955}'), // 🥕
    Ingredient(id: 'peas', name: 'Peas', emoji: '\u{1F966}'), // 🥦
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the rice, eggs, and vegetables into the pan.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir and toss the rice until everything is mixed.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the colourful fried rice on the plate.',
    ),
  ],
  funFacts: [
    'Ghanaian fried rice is a party favourite \u{2014} colourful and tasty!',
    'It is often served at celebrations with grilled chicken.',
    'The vegetables give it a rainbow of colours.',
  ],
);

// ---------------------------------------------------------------------------
// Nigeria
// ---------------------------------------------------------------------------

const nigeriaJollofRecipe = Recipe(
  id: 'nigeria_jollof',
  countryId: 'nigeria',
  name: 'Jollof Rice',
  emoji: '\u{1F35B}', // 🍛
  ingredients: [
    Ingredient(id: 'rice', name: 'Rice', emoji: '\u{1F35A}'), // 🍚
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}'), // 🍅
    Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}'), // 🧅
    Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'), // 🌶
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag all ingredients into the pot.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir in circles until the ring is full.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Drag the spoon to serve jollof onto the plate.',
    ),
  ],
  funFacts: [
    'Nigerian jollof is famous across Africa!',
    'Smoky party jollof is the most loved style.',
    'Every cook has a secret jollof recipe.',
  ],
);

const nigeriaSuyaRecipe = Recipe(
  id: 'nigeria_suya',
  countryId: 'nigeria',
  name: 'Suya',
  emoji: '\u{1F356}', // 🍖
  ingredients: [
    Ingredient(id: 'meat', name: 'Meat', emoji: '\u{1F969}'), // 🥩
    Ingredient(id: 'spice', name: 'Suya Spice', emoji: '\u{1F336}'), // 🌶
    Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}'), // 🧅
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}'), // 🍅
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the meat and spices into the pot.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir in circles until the ring is full.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the suya onto the plate with onions.',
    ),
  ],
  funFacts: [
    'Suya is a popular street food sold in the evening.',
    'The special spice mix is called yaji.',
    'Suya sellers wrap it in newspaper or brown paper.',
  ],
);

const nigeriaPoundedYamRecipe = Recipe(
  id: 'nigeria_pounded_yam',
  countryId: 'nigeria',
  name: 'Pounded Yam',
  emoji: '\u{1F372}', // 🍲
  difficulty: RecipeDifficulty.medium,
  ingredients: [
    Ingredient(id: 'yam', name: 'Yam', emoji: '\u{1F954}'), // 🥔
    Ingredient(id: 'water', name: 'Water', emoji: '\u{1F4A7}'), // 💧
    Ingredient(id: 'soup', name: 'Egusi Soup', emoji: '\u{1F958}'), // 🥘
    Ingredient(id: 'meat', name: 'Meat', emoji: '\u{1F969}'), // 🥩
    Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'), // 🌶
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the yam pieces into the pot to boil.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Pound and stir the yam until it is smooth and stretchy.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the pounded yam with a bowl of soup.',
    ),
  ],
  funFacts: [
    'Pounded yam is smooth and stretchy like soft dough!',
    'It is pounded with a big wooden mortar and pestle.',
    'In Nigeria, it is eaten with egusi, ogbono, or vegetable soup.',
  ],
);

const nigeriaEgusiRecipe = Recipe(
  id: 'nigeria_egusi',
  countryId: 'nigeria',
  name: 'Egusi Soup',
  emoji: '\u{1F958}', // 🥘
  difficulty: RecipeDifficulty.medium,
  ingredients: [
    Ingredient(id: 'melon_seed', name: 'Melon Seeds', emoji: '\u{1F348}'), // 🍈
    Ingredient(id: 'spinach', name: 'Spinach', emoji: '\u{1F96C}'), // 🥬
    Ingredient(id: 'palm_oil', name: 'Palm Oil', emoji: '\u{1FAD9}'), // 🫙
    Ingredient(id: 'meat', name: 'Meat', emoji: '\u{1F969}'), // 🥩
    Ingredient(id: 'pepper', name: 'Pepper', emoji: '\u{1F336}'), // 🌶
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the melon seeds, spinach, and meat into the pot.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the thick soup until the melon seeds thicken it.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the egusi soup with pounded yam or fufu.',
    ),
  ],
  funFacts: [
    'Egusi is made from ground melon seeds \u{2014} not the fruit!',
    'It is one of the most popular soups in Nigeria.',
    'The leafy greens stirred in at the end make it extra nutritious.',
  ],
);

const nigeriaChinChinRecipe = Recipe(
  id: 'nigeria_chin_chin',
  countryId: 'nigeria',
  name: 'Chin Chin',
  emoji: '\u{1F36A}', // 🍪
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'sugar', name: 'Sugar', emoji: '\u{1F36C}'), // 🍬
    Ingredient(id: 'butter', name: 'Butter', emoji: '\u{1F9C8}'), // 🧈
    Ingredient(id: 'milk', name: 'Milk', emoji: '\u{1F95B}'), // 🥛
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the flour, sugar, and butter into the bowl.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir and knead the dough until it is smooth.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the crispy golden chin chin on the plate.',
    ),
  ],
  funFacts: [
    'Chin chin is a crunchy fried dough snack loved by everyone!',
    'It is a must-have at Nigerian parties and celebrations.',
    'Every family has their own special chin chin recipe.',
  ],
);

// ---------------------------------------------------------------------------
// UK
// ---------------------------------------------------------------------------

const ukFishAndChipsRecipe = Recipe(
  id: 'uk_fish_and_chips',
  countryId: 'uk',
  name: 'Fish & Chips',
  emoji: '\u{1F41F}', // 🐟
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'fish', name: 'Fish', emoji: '\u{1F41F}'), // 🐟
    Ingredient(id: 'potato', name: 'Potato', emoji: '\u{1F954}'), // 🥔
    Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
    Ingredient(id: 'salt', name: 'Salt', emoji: '\u{1F9C2}'), // 🧂
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the fish, potatoes, and batter into the pot.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir in circles until the ring is full.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the fish and chips onto the plate.',
    ),
  ],
  funFacts: [
    'Fish and chips is the UK\'s favourite takeaway!',
    'The first chip shop opened in the 1860s.',
    'British people add vinegar and mushy peas on the side.',
  ],
);

const ukSconeRecipe = Recipe(
  id: 'uk_scones',
  countryId: 'uk',
  name: 'Scones',
  emoji: '\u{1F9C1}', // 🧁
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'butter', name: 'Butter', emoji: '\u{1F9C8}'), // 🧈
    Ingredient(id: 'milk', name: 'Milk', emoji: '\u{1F95B}'), // 🥛
    Ingredient(id: 'sugar', name: 'Sugar', emoji: '\u{1F36C}'), // 🍬
    Ingredient(id: 'jam', name: 'Jam', emoji: '\u{1F353}'), // 🍓
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the flour, butter, milk, and sugar into the bowl.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir in circles to mix the dough.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the scones with jam and cream.',
    ),
  ],
  funFacts: [
    'Scones are a must-have for afternoon tea!',
    'People debate whether to put cream or jam on first.',
    'Scones have been baked in Britain for hundreds of years.',
  ],
);

const ukFullBreakfastRecipe = Recipe(
  id: 'uk_full_breakfast',
  countryId: 'uk',
  name: 'Full Breakfast',
  emoji: '\u{1F373}', // 🍳
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'egg', name: 'Egg', emoji: '\u{1F95A}'), // 🥚
    Ingredient(id: 'bacon', name: 'Bacon', emoji: '\u{1F953}'), // 🥓
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}'), // 🍅
    Ingredient(id: 'toast', name: 'Toast', emoji: '\u{1F35E}'), // 🍞
    Ingredient(id: 'beans', name: 'Beans', emoji: '\u{1FAD8}'), // 🫘
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the eggs, bacon, and veggies into the pan.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir to fry everything evenly.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Arrange the full breakfast on the plate.',
    ),
  ],
  funFacts: [
    'A Full English breakfast is also called a "fry-up"!',
    'It has been a British tradition since Victorian times.',
    'Every region in the UK has its own breakfast version.',
  ],
);

const ukShepherdsPieRecipe = Recipe(
  id: 'uk_shepherds_pie',
  countryId: 'uk',
  name: 'Shepherd\u{2019}s Pie',
  emoji: '\u{1F967}', // 🥧
  difficulty: RecipeDifficulty.medium,
  ingredients: [
    Ingredient(id: 'lamb', name: 'Lamb', emoji: '\u{1F969}'), // 🥩
    Ingredient(id: 'potato', name: 'Potato', emoji: '\u{1F954}'), // 🥔
    Ingredient(id: 'carrot', name: 'Carrot', emoji: '\u{1F955}'), // 🥕
    Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}'), // 🧅
    Ingredient(id: 'butter', name: 'Butter', emoji: '\u{1F9C8}'), // 🧈
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Layer the lamb, veggies, and mashed potato in the dish.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the filling until it is mixed well.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve a big scoop of pie onto the plate.',
    ),
  ],
  funFacts: [
    'Shepherd\u{2019}s pie uses lamb \u{2014} cottage pie uses beef!',
    'It was invented as a way to use leftover roast meat.',
    'The mashed potato topping gets crispy and golden in the oven.',
  ],
);

const ukTrifleRecipe = Recipe(
  id: 'uk_trifle',
  countryId: 'uk',
  name: 'Trifle',
  emoji: '\u{1F370}', // 🍰
  difficulty: RecipeDifficulty.medium,
  ingredients: [
    Ingredient(id: 'sponge', name: 'Sponge Cake', emoji: '\u{1F370}'), // 🍰
    Ingredient(id: 'custard', name: 'Custard', emoji: '\u{1F95B}'), // 🥛
    Ingredient(id: 'fruit', name: 'Fruit', emoji: '\u{1F353}'), // 🍓
    Ingredient(id: 'cream', name: 'Cream', emoji: '\u{1F95B}'), // 🥛
    Ingredient(id: 'sprinkles', name: 'Sprinkles', emoji: '\u{2728}'), // ✨
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Layer the sponge, custard, and fruit into the glass.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Gently stir the custard layer smooth.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Top with cream and sprinkles to decorate!',
    ),
  ],
  funFacts: [
    'Trifle has been a British dessert for over 400 years!',
    'The word "trifle" means something small and fun.',
    'Every family layers their trifle a little differently.',
  ],
);

const ukCrumpetsRecipe = Recipe(
  id: 'uk_crumpets',
  countryId: 'uk',
  name: 'Crumpets',
  emoji: '\u{1F95E}', // 🥞
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'crumpet', name: 'Crumpet', emoji: '\u{1F95E}'), // 🥞
    Ingredient(id: 'butter', name: 'Butter', emoji: '\u{1F9C8}'), // 🧈
    Ingredient(id: 'honey', name: 'Honey', emoji: '\u{1F36F}'), // 🍯
    Ingredient(id: 'jam', name: 'Jam', emoji: '\u{1F353}'), // 🍓
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Put the crumpets in the toaster.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the butter until it melts on the warm crumpet.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Spread honey and jam, then serve!',
    ),
  ],
  funFacts: [
    'Crumpets have been eaten in Britain since the 1600s!',
    'The little holes in crumpets soak up melted butter perfectly.',
    'British people eat over 80 million crumpets each year.',
  ],
);

const ukBangersAndMashRecipe = Recipe(
  id: 'uk_bangers_and_mash',
  countryId: 'uk',
  name: 'Bangers & Mash',
  emoji: '\u{1F356}', // 🍖
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'sausage', name: 'Sausage', emoji: '\u{1F32D}'), // 🌭
    Ingredient(id: 'potato', name: 'Potato', emoji: '\u{1F954}'), // 🥔
    Ingredient(id: 'butter', name: 'Butter', emoji: '\u{1F9C8}'), // 🧈
    Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}'), // 🧅
    Ingredient(id: 'gravy', name: 'Gravy', emoji: '\u{1F372}'), // 🍲
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the sausages and potatoes into the pan.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the gravy and onions together.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the bangers and mash with gravy on top.',
    ),
  ],
  funFacts: [
    'Sausages are called "bangers" because they used to pop in the pan!',
    'Bangers and mash has been a British favourite for over 100 years.',
    'Onion gravy is the most popular topping for this dish.',
  ],
);

const ukYorkshirePuddingRecipe = Recipe(
  id: 'uk_yorkshire_pudding',
  countryId: 'uk',
  name: 'Yorkshire Pudding',
  emoji: '\u{1F35E}', // 🍞
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'egg', name: 'Egg', emoji: '\u{1F95A}'), // 🥚
    Ingredient(id: 'milk', name: 'Milk', emoji: '\u{1F95B}'), // 🥛
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
    Ingredient(id: 'salt', name: 'Salt', emoji: '\u{1F9C2}'), // 🧂
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the eggs, flour, and milk into the bowl.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the batter until it is smooth and runny.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the puffy golden puddings on the plate.',
    ),
  ],
  funFacts: [
    'Yorkshire pudding puffs up big in a very hot oven!',
    'It was first served as a cheap starter to fill people up before the meat.',
    'Every Sunday roast in Britain has Yorkshire pudding on the side.',
  ],
);

const ukCornishPastyRecipe = Recipe(
  id: 'uk_cornish_pasty',
  countryId: 'uk',
  name: 'Cornish Pasty',
  emoji: '\u{1F950}', // 🥐
  difficulty: RecipeDifficulty.medium,
  ingredients: [
    Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'butter', name: 'Butter', emoji: '\u{1F9C8}'), // 🧈
    Ingredient(id: 'beef', name: 'Beef', emoji: '\u{1F969}'), // 🥩
    Ingredient(id: 'potato', name: 'Potato', emoji: '\u{1F954}'), // 🥔
    Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}'), // 🧅
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the beef, potato, and onion onto the pastry.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Fold and crimp the edges of the pastry.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the golden baked pasty on the plate.',
    ),
  ],
  funFacts: [
    'Cornish pasties were made for tin miners in Cornwall to eat underground!',
    'The thick crimped edge was a handle — miners threw it away because their hands were dirty.',
    'A real Cornish pasty must be made in Cornwall to have the official name.',
  ],
);

const ukStickyToffeeRecipe = Recipe(
  id: 'uk_sticky_toffee',
  countryId: 'uk',
  name: 'Sticky Toffee Pudding',
  emoji: '\u{1F36E}', // 🍮
  difficulty: RecipeDifficulty.medium,
  ingredients: [
    Ingredient(id: 'dates', name: 'Dates', emoji: '\u{1F334}'), // 🌴
    Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'butter', name: 'Butter', emoji: '\u{1F9C8}'), // 🧈
    Ingredient(id: 'sugar', name: 'Sugar', emoji: '\u{1F36C}'), // 🍬
    Ingredient(id: 'cream', name: 'Cream', emoji: '\u{1F95B}'), // 🥛
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the dates, flour, and butter into the bowl.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the toffee sauce until it is thick and glossy.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Pour toffee sauce over the warm pudding and serve.',
    ),
  ],
  funFacts: [
    'Sticky toffee pudding was invented in the Lake District in England!',
    'The secret ingredient is chopped dates — they make the sponge super moist.',
    'It is one of the most popular desserts in British pubs and restaurants.',
  ],
);

// ---------------------------------------------------------------------------
// USA
// ---------------------------------------------------------------------------

const usaBurgerRecipe = Recipe(
  id: 'usa_burger',
  countryId: 'usa',
  name: 'Burger',
  emoji: '\u{1F354}', // 🍔
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'bun', name: 'Bun', emoji: '\u{1F35E}'), // 🍞
    Ingredient(id: 'beef', name: 'Beef Patty', emoji: '\u{1F969}'), // 🥩
    Ingredient(id: 'lettuce', name: 'Lettuce', emoji: '\u{1F96C}'), // 🥬
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}'), // 🍅
    Ingredient(id: 'cheese', name: 'Cheese', emoji: '\u{1F9C0}'), // 🧀
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the patty, cheese, and veggies onto the bun.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Flip the patty on the grill until it sizzles.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Stack the burger and serve it on the plate.',
    ),
  ],
  funFacts: [
    'Americans eat about 50 billion burgers every year!',
    'The hamburger was popularised at the 1904 World\u{2019}s Fair.',
    'Cheeseburgers were invented by adding a slice of cheese on top.',
  ],
);

const usaPizzaRecipe = Recipe(
  id: 'usa_pizza',
  countryId: 'usa',
  name: 'Pizza',
  emoji: '\u{1F355}', // 🍕
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'dough', name: 'Dough', emoji: '\u{1F35E}'), // 🍞
    Ingredient(id: 'sauce', name: 'Tomato Sauce', emoji: '\u{1F345}'), // 🍅
    Ingredient(id: 'cheese', name: 'Cheese', emoji: '\u{1F9C0}'), // 🧀
    Ingredient(id: 'pepperoni', name: 'Pepperoni', emoji: '\u{1F356}'), // 🍖
    Ingredient(id: 'pepper', name: 'Bell Pepper', emoji: '\u{1FAD1}'), // 🫑
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the sauce, cheese, and toppings onto the dough.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Spread the sauce in circles over the dough.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Slice the pizza and serve a hot piece on the plate.',
    ),
  ],
  funFacts: [
    'Pizza became hugely popular in America after World War II!',
    'New York style has thin, foldable slices; Chicago style is deep-dish.',
    'Pepperoni is the most popular pizza topping in the USA.',
  ],
);

const usaHotdogRecipe = Recipe(
  id: 'usa_hotdog',
  countryId: 'usa',
  name: 'Hotdog',
  emoji: '\u{1F32D}', // 🌭
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'sausage', name: 'Sausage', emoji: '\u{1F32D}'), // 🌭
    Ingredient(id: 'bun', name: 'Bun', emoji: '\u{1F35E}'), // 🍞
    Ingredient(id: 'mustard', name: 'Mustard', emoji: '\u{1F7E1}'), // 🟡
    Ingredient(id: 'ketchup', name: 'Ketchup', emoji: '\u{1F534}'), // 🔴
    Ingredient(id: 'onion', name: 'Onion', emoji: '\u{1F9C5}'), // 🧅
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the sausage into the bun.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Grill the hot dog until it sizzles.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Add mustard and ketchup, then serve!',
    ),
  ],
  funFacts: [
    'Americans eat about 20 billion hot dogs every year!',
    'Hot dogs are a must-have at baseball games.',
    'The famous Nathan\u{2019}s hot dog eating contest happens every July 4th.',
  ],
);

const usaPancakesRecipe = Recipe(
  id: 'usa_pancakes',
  countryId: 'usa',
  name: 'Pancakes',
  emoji: '\u{1F95E}', // 🥞
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'egg', name: 'Egg', emoji: '\u{1F95A}'), // 🥚
    Ingredient(id: 'milk', name: 'Milk', emoji: '\u{1F95B}'), // 🥛
    Ingredient(id: 'syrup', name: 'Maple Syrup', emoji: '\u{1F36F}'), // 🍯
    Ingredient(id: 'butter', name: 'Butter', emoji: '\u{1F9C8}'), // 🧈
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the flour, egg, and milk into the bowl to mix.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the batter until it is smooth.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Stack the pancakes and pour maple syrup on top.',
    ),
  ],
  funFacts: [
    'Pancakes have been eaten in America since colonial times!',
    'Maple syrup comes from the sap of maple trees.',
    'Some people add blueberries or chocolate chips to the batter.',
  ],
);

const usaDonutRecipe = Recipe(
  id: 'usa_donut',
  countryId: 'usa',
  name: 'Donut',
  emoji: '\u{1F369}', // 🍩
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'sugar', name: 'Sugar', emoji: '\u{1F36C}'), // 🍬
    Ingredient(id: 'egg', name: 'Egg', emoji: '\u{1F95A}'), // 🥚
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
    Ingredient(id: 'sprinkles', name: 'Sprinkles', emoji: '\u{2728}'), // ✨
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the flour, sugar, and egg into the bowl.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir the dough and shape it into a ring.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Add icing and sprinkles, then serve!',
    ),
  ],
  funFacts: [
    'The donut hole was invented so the middle would cook evenly!',
    'Americans eat over 10 billion donuts every year.',
    'National Donut Day is the first Friday in June.',
  ],
);

const usaIceCreamRecipe = Recipe(
  id: 'usa_icecream',
  countryId: 'usa',
  name: 'Ice Cream',
  emoji: '\u{1F368}', // 🍨
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'cream', name: 'Cream', emoji: '\u{1F95B}'), // 🥛
    Ingredient(id: 'sugar', name: 'Sugar', emoji: '\u{1F36C}'), // 🍬
    Ingredient(id: 'vanilla', name: 'Vanilla', emoji: '\u{1F33F}'), // 🌿
    Ingredient(id: 'fruit', name: 'Fruit', emoji: '\u{1F353}'), // 🍓
    Ingredient(id: 'cone', name: 'Cone', emoji: '\u{1F366}'), // 🍦
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the cream, sugar, and vanilla into the mixer.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Stir and churn the ice cream until it is thick.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Scoop the ice cream into a cone and serve!',
    ),
  ],
  funFacts: [
    'Vanilla is the most popular ice cream flavour in America!',
    'The ice cream cone was invented at the 1904 World\u{2019}s Fair.',
    'Americans eat about 1.5 billion gallons of ice cream each year.',
  ],
);

const usaFriedChickenRecipe = Recipe(
  id: 'usa_friedchicken',
  countryId: 'usa',
  name: 'Fried Chicken',
  emoji: '\u{1F357}', // 🍗
  difficulty: RecipeDifficulty.medium,
  ingredients: [
    Ingredient(id: 'chicken', name: 'Chicken', emoji: '\u{1F357}'), // 🍗
    Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'egg', name: 'Egg', emoji: '\u{1F95A}'), // 🥚
    Ingredient(id: 'spice', name: 'Spices', emoji: '\u{1F336}'), // 🌶
    Ingredient(id: 'oil', name: 'Oil', emoji: '\u{1FAD9}'), // 🫙
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the chicken into the spiced flour to coat it.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Fry the chicken in the pot until golden and crispy.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve the crispy fried chicken on the plate.',
    ),
  ],
  funFacts: [
    'Southern fried chicken is one of America\u{2019}s most famous dishes!',
    'The secret is a crispy coating made from seasoned flour.',
    'Fried chicken is a favourite food for picnics and family gatherings.',
  ],
);

const usaApplePieRecipe = Recipe(
  id: 'usa_applepie',
  countryId: 'usa',
  name: 'Apple Pie',
  emoji: '\u{1F967}', // 🥧
  difficulty: RecipeDifficulty.medium,
  ingredients: [
    Ingredient(id: 'apple', name: 'Apple', emoji: '\u{1F34E}'), // 🍎
    Ingredient(id: 'flour', name: 'Flour', emoji: '\u{1F33E}'), // 🌾
    Ingredient(id: 'butter', name: 'Butter', emoji: '\u{1F9C8}'), // 🧈
    Ingredient(id: 'sugar', name: 'Sugar', emoji: '\u{1F36C}'), // 🍬
    Ingredient(id: 'cinnamon', name: 'Cinnamon', emoji: '\u{1F33F}'), // 🌿
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the apples, sugar, and cinnamon into the pie crust.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Mix the apple filling until the spices are blended.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Serve a slice of golden apple pie on the plate.',
    ),
  ],
  funFacts: [
    'The saying "as American as apple pie" shows how loved it is!',
    'Apple pie has been eaten in America since the 1600s.',
    'Many people serve it warm with a scoop of vanilla ice cream.',
  ],
);

const usaSandwichRecipe = Recipe(
  id: 'usa_sandwich',
  countryId: 'usa',
  name: 'Sandwich',
  emoji: '\u{1F96A}', // 🥪
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'bread', name: 'Bread', emoji: '\u{1F35E}'), // 🍞
    Ingredient(id: 'meat', name: 'Turkey', emoji: '\u{1F969}'), // 🥩
    Ingredient(id: 'cheese', name: 'Cheese', emoji: '\u{1F9C0}'), // 🧀
    Ingredient(id: 'lettuce', name: 'Lettuce', emoji: '\u{1F96C}'), // 🥬
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '\u{1F345}'), // 🍅
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the meat, cheese, and veggies onto the bread.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Spread the sauce evenly on the bread.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Close the sandwich, cut it in half, and serve!',
    ),
  ],
  funFacts: [
    'The sandwich is named after the Earl of Sandwich from England!',
    'Americans invented many famous sandwiches like the club and the Reuben.',
    'Peanut butter and jelly is the most popular kids\u{2019} sandwich.',
  ],
);

const usaMilkshakeRecipe = Recipe(
  id: 'usa_milkshake',
  countryId: 'usa',
  name: 'Milkshake',
  emoji: '\u{1F964}', // 🥤
  difficulty: RecipeDifficulty.easy,
  ingredients: [
    Ingredient(id: 'milk', name: 'Milk', emoji: '\u{1F95B}'), // 🥛
    Ingredient(id: 'icecream', name: 'Ice Cream', emoji: '\u{1F366}'), // 🍦
    Ingredient(id: 'strawberry', name: 'Strawberry', emoji: '\u{1F353}'), // 🍓
    Ingredient(id: 'sugar', name: 'Sugar', emoji: '\u{1F36C}'), // 🍬
    Ingredient(id: 'cream', name: 'Whipped Cream', emoji: '\u{1F95B}'), // 🥛
  ],
  steps: [
    CookingStep(
      state: CookingState.addIngredients,
      instruction: 'Drag the milk, ice cream, and fruit into the blender.',
    ),
    CookingStep(
      state: CookingState.stir,
      instruction: 'Blend everything until it is thick and smooth.',
    ),
    CookingStep(
      state: CookingState.plate,
      instruction: 'Pour into a tall glass and top with whipped cream!',
    ),
  ],
  funFacts: [
    'Milkshakes became popular in American diners in the 1950s!',
    'The electric blender made milkshakes thick and creamy.',
    'Chocolate, vanilla, and strawberry are the classic flavours.',
  ],
);

final Map<String, Recipe> cookingRecipeRegistry = {
  ghanaJollofRecipe.id: ghanaJollofRecipe,
  ghanaWaakyeRecipe.id: ghanaWaakyeRecipe,
  ghanaBankuRecipe.id: ghanaBankuRecipe,
  ghanaFufuRecipe.id: ghanaFufuRecipe,
  ghanaKokoRecipe.id: ghanaKokoRecipe,
  ghanaKeleweleRecipe.id: ghanaKeleweleRecipe,
  ghanaPeanutButterSoupRecipe.id: ghanaPeanutButterSoupRecipe,
  ghanaPalmnutRecipe.id: ghanaPalmnutRecipe,
  ghanaFriedRiceRecipe.id: ghanaFriedRiceRecipe,
  nigeriaJollofRecipe.id: nigeriaJollofRecipe,
  nigeriaSuyaRecipe.id: nigeriaSuyaRecipe,
  nigeriaPoundedYamRecipe.id: nigeriaPoundedYamRecipe,
  nigeriaEgusiRecipe.id: nigeriaEgusiRecipe,
  nigeriaChinChinRecipe.id: nigeriaChinChinRecipe,
  ukFishAndChipsRecipe.id: ukFishAndChipsRecipe,
  ukSconeRecipe.id: ukSconeRecipe,
  ukFullBreakfastRecipe.id: ukFullBreakfastRecipe,
  ukShepherdsPieRecipe.id: ukShepherdsPieRecipe,
  ukTrifleRecipe.id: ukTrifleRecipe,
  ukCrumpetsRecipe.id: ukCrumpetsRecipe,
  ukBangersAndMashRecipe.id: ukBangersAndMashRecipe,
  ukYorkshirePuddingRecipe.id: ukYorkshirePuddingRecipe,
  ukCornishPastyRecipe.id: ukCornishPastyRecipe,
  ukStickyToffeeRecipe.id: ukStickyToffeeRecipe,
  usaBurgerRecipe.id: usaBurgerRecipe,
  usaPizzaRecipe.id: usaPizzaRecipe,
  usaHotdogRecipe.id: usaHotdogRecipe,
  usaPancakesRecipe.id: usaPancakesRecipe,
  usaDonutRecipe.id: usaDonutRecipe,
  usaIceCreamRecipe.id: usaIceCreamRecipe,
  usaFriedChickenRecipe.id: usaFriedChickenRecipe,
  usaApplePieRecipe.id: usaApplePieRecipe,
  usaSandwichRecipe.id: usaSandwichRecipe,
  usaMilkshakeRecipe.id: usaMilkshakeRecipe,
};

Recipe? findCookingRecipe(String recipeId) => cookingRecipeRegistry[recipeId];

List<Recipe> cookingRecipesForCountry(String countryId) {
  return cookingRecipeRegistry.values
      .where((recipe) => recipe.countryId == countryId)
      .toList(growable: false);
}

Recipe? defaultCookingRecipeForCountry(String countryId) {
  final recipes = cookingRecipesForCountry(countryId);
  if (recipes.isEmpty) return null;
  return recipes.first;
}
