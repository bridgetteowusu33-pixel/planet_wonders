import '../models/badge.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

const Recipe ghanaJollofRecipe = Recipe(
  id: 'ghana_jollof',
  name: 'Ghana Jollof',
  country: 'Ghana',
  potAsset: 'assets/cooking/pots/classic_pot.png',
  chefAsset: 'assets/cooking/chefs/chef_ava.png',
  requiredStirTurns: 6,
  requiredSpiceShakes: 3,
  requiredServeScoops: 4,
  ingredients: <Ingredient>[
    Ingredient(
      id: 'rice',
      name: 'Rice',
      assetPath: 'assets/cooking/ingredients/rice_bowl.png',
      country: 'Ghana',
    ),
    Ingredient(
      id: 'tomato',
      name: 'Tomato',
      assetPath: 'assets/cooking/ingredients/tomato_mix.png',
      country: 'Ghana',
    ),
    Ingredient(
      id: 'onion',
      name: 'Onion',
      assetPath: 'assets/cooking/ingredients/onion.png',
      country: 'Ghana',
    ),
    Ingredient(
      id: 'pepper',
      name: 'Pepper',
      assetPath: 'assets/cooking/ingredients/pepper.png',
      country: 'Ghana',
      isSpice: true,
    ),
  ],
  facts: <CookingFact>[
    CookingFact(
      country: 'Ghana',
      text: 'Jollof rice is a favorite celebration meal in Ghana.',
    ),
    CookingFact(
      country: 'Ghana',
      text: 'Many families add their own spice blend to make jollof unique.',
    ),
    CookingFact(
      country: 'Ghana',
      text: 'Jollof is often shared at parties and family gatherings.',
    ),
  ],
  badge: CookingBadge(
    id: 'ghana_chef',
    title: 'Ghana Jollof Chef',
    country: 'Ghana',
    iconAsset: 'assets/cooking/effects/badge_ghana_chef.png',
  ),
);

const List<Recipe> ghanaRecipes = <Recipe>[ghanaJollofRecipe];
