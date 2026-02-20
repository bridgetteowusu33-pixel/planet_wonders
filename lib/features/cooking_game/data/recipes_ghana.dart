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

final Map<String, Recipe> cookingRecipeRegistry = {
  ghanaJollofRecipe.id: ghanaJollofRecipe,
  ghanaWaakyeRecipe.id: ghanaWaakyeRecipe,
  nigeriaJollofRecipe.id: nigeriaJollofRecipe,
  nigeriaSuyaRecipe.id: nigeriaSuyaRecipe,
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
