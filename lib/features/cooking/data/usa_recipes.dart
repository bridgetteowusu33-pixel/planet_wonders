import '../models/badge.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

const Recipe usaVeggieSkilletRecipe = Recipe(
  id: 'usa_veggie_skillet',
  name: 'Veggie Skillet',
  country: 'USA',
  potAsset: 'assets/cooking/pots/classic_pot.png',
  chefAsset: 'assets/cooking/chefs/chef_ava.png',
  requiredStirTurns: 5,
  requiredSpiceShakes: 2,
  requiredServeScoops: 3,
  ingredients: <Ingredient>[
    Ingredient(
      id: 'corn',
      name: 'Corn',
      assetPath: 'assets/cooking/ingredients/corn.png',
      country: 'USA',
    ),
    Ingredient(
      id: 'beans',
      name: 'Beans',
      assetPath: 'assets/cooking/ingredients/beans.png',
      country: 'USA',
    ),
    Ingredient(
      id: 'carrot',
      name: 'Carrot',
      assetPath: 'assets/cooking/ingredients/carrot.png',
      country: 'USA',
    ),
  ],
  facts: <CookingFact>[
    CookingFact(
      country: 'USA',
      text: 'Skillet meals are popular because they are quick to cook.',
    ),
    CookingFact(
      country: 'USA',
      text: 'Many kitchens in the USA use local seasonal vegetables.',
    ),
  ],
  badge: CookingBadge(
    id: 'usa_chef',
    title: 'USA Skillet Chef',
    country: 'USA',
    iconAsset: 'assets/cooking/effects/badge_usa_chef.png',
  ),
);

const List<Recipe> usaRecipes = <Recipe>[usaVeggieSkilletRecipe];
