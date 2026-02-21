import '../models/badge.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

const Recipe ukFishAndChipsRecipe = Recipe(
  id: 'uk_fish_and_chips',
  name: 'Fish & Chips',
  country: 'UK',
  potAsset: 'assets/cooking/pots/classic_pot.png',
  chefAsset: 'assets/cooking/chefs/chef_ava.png',
  requiredStirTurns: 4,
  requiredSpiceShakes: 2,
  requiredServeScoops: 3,
  ingredients: <Ingredient>[
    Ingredient(
      id: 'fish',
      name: 'Fish',
      assetPath: 'assets/cooking/ingredients/fish.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'potato',
      name: 'Potato',
      assetPath: 'assets/cooking/ingredients/potato.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'flour',
      name: 'Flour',
      assetPath: 'assets/cooking/ingredients/flour.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'salt',
      name: 'Salt',
      assetPath: 'assets/cooking/ingredients/salt.png',
      country: 'UK',
      isSpice: true,
    ),
  ],
  facts: <CookingFact>[
    CookingFact(
      country: 'UK',
      text: 'Fish and chips is the UK\'s most famous takeaway meal!',
    ),
    CookingFact(
      country: 'UK',
      text: 'The first fish and chip shop opened in the 1860s.',
    ),
    CookingFact(
      country: 'UK',
      text: 'British people often add vinegar and mushy peas on the side.',
    ),
  ],
  badge: CookingBadge(
    id: 'uk_chef',
    title: 'UK Fish & Chips Chef',
    country: 'UK',
    iconAsset: 'assets/cooking/effects/badge_uk_chef.png',
  ),
);

const List<Recipe> ukRecipes = <Recipe>[ukFishAndChipsRecipe];
