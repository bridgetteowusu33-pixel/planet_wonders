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

// ---------------------------------------------------------------------------
// UK
// ---------------------------------------------------------------------------

const ukFishAndChipsRecipe = Recipe(
  id: 'uk_fish_and_chips',
  countryId: 'uk',
  name: 'Fish & Chips',
  emoji: '\u{1F41F}', // 🐟
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

final Map<String, Recipe> cookingRecipeRegistry = {
  ghanaJollofRecipe.id: ghanaJollofRecipe,
  ghanaWaakyeRecipe.id: ghanaWaakyeRecipe,
  nigeriaJollofRecipe.id: nigeriaJollofRecipe,
  nigeriaSuyaRecipe.id: nigeriaSuyaRecipe,
  ukFishAndChipsRecipe.id: ukFishAndChipsRecipe,
  ukSconeRecipe.id: ukSconeRecipe,
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
