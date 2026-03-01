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
      text: 'Fish and chips is the UK\u{2019}s most famous takeaway meal!',
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
    id: 'uk_fish_chips_chef',
    title: 'Fish & Chips Chef',
    country: 'UK',
    iconAsset: 'assets/cooking/effects/badge_uk_chef.png',
  ),
);

const Recipe ukSconesRecipe = Recipe(
  id: 'uk_scones',
  name: 'Scones',
  country: 'UK',
  potAsset: 'assets/cooking/pots/classic_pot.png',
  chefAsset: 'assets/cooking/chefs/chef_ava.png',
  requiredStirTurns: 5,
  requiredSpiceShakes: 0,
  requiredServeScoops: 3,
  ingredients: <Ingredient>[
    Ingredient(
      id: 'flour',
      name: 'Flour',
      assetPath: 'assets/cooking/ingredients/flour.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'butter',
      name: 'Butter',
      assetPath: 'assets/cooking/ingredients/butter.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'milk',
      name: 'Milk',
      assetPath: 'assets/cooking/ingredients/milk.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'sugar',
      name: 'Sugar',
      assetPath: 'assets/cooking/ingredients/sugar.png',
      country: 'UK',
    ),
  ],
  facts: <CookingFact>[
    CookingFact(
      country: 'UK',
      text: 'Scones are a must-have for afternoon tea!',
    ),
    CookingFact(
      country: 'UK',
      text: 'People debate whether to put cream or jam on first.',
    ),
    CookingFact(
      country: 'UK',
      text: 'Scones have been baked in Britain for hundreds of years.',
    ),
  ],
  badge: CookingBadge(
    id: 'uk_scones_chef',
    title: 'Scones Baker',
    country: 'UK',
    iconAsset: 'assets/cooking/effects/badge_uk_chef.png',
  ),
);

const Recipe ukFullBreakfastRecipe = Recipe(
  id: 'uk_full_breakfast',
  name: 'Full Breakfast',
  country: 'UK',
  potAsset: 'assets/cooking/pots/classic_pot.png',
  chefAsset: 'assets/cooking/chefs/chef_ava.png',
  requiredStirTurns: 5,
  requiredSpiceShakes: 0,
  requiredServeScoops: 4,
  ingredients: <Ingredient>[
    Ingredient(
      id: 'egg',
      name: 'Egg',
      assetPath: 'assets/cooking/ingredients/egg.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'bacon',
      name: 'Bacon',
      assetPath: 'assets/cooking/ingredients/bacon.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'tomato',
      name: 'Tomato',
      assetPath: 'assets/cooking/ingredients/tomato_mix.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'toast',
      name: 'Toast',
      assetPath: 'assets/cooking/ingredients/toast.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'beans',
      name: 'Beans',
      assetPath: 'assets/cooking/ingredients/beans.png',
      country: 'UK',
    ),
  ],
  facts: <CookingFact>[
    CookingFact(
      country: 'UK',
      text: 'A Full English breakfast is also called a \u{201C}fry-up\u{201D}!',
    ),
    CookingFact(
      country: 'UK',
      text: 'It has been a British tradition since Victorian times.',
    ),
    CookingFact(
      country: 'UK',
      text: 'Every region in the UK has its own breakfast version.',
    ),
  ],
  badge: CookingBadge(
    id: 'uk_breakfast_chef',
    title: 'Breakfast Chef',
    country: 'UK',
    iconAsset: 'assets/cooking/effects/badge_uk_chef.png',
  ),
);

const Recipe ukShepherdsPieRecipe = Recipe(
  id: 'uk_shepherds_pie',
  name: 'Shepherd\u{2019}s Pie',
  country: 'UK',
  potAsset: 'assets/cooking/pots/classic_pot.png',
  chefAsset: 'assets/cooking/chefs/chef_ava.png',
  requiredStirTurns: 6,
  requiredSpiceShakes: 2,
  requiredServeScoops: 3,
  ingredients: <Ingredient>[
    Ingredient(
      id: 'lamb',
      name: 'Lamb',
      assetPath: 'assets/cooking/ingredients/lamb.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'potato',
      name: 'Potato',
      assetPath: 'assets/cooking/ingredients/potato.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'carrot',
      name: 'Carrot',
      assetPath: 'assets/cooking/ingredients/carrot.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'onion',
      name: 'Onion',
      assetPath: 'assets/cooking/ingredients/onion.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'butter',
      name: 'Butter',
      assetPath: 'assets/cooking/ingredients/butter.png',
      country: 'UK',
    ),
  ],
  facts: <CookingFact>[
    CookingFact(
      country: 'UK',
      text: 'Shepherd\u{2019}s pie uses lamb \u{2014} cottage pie uses beef!',
    ),
    CookingFact(
      country: 'UK',
      text: 'It was invented as a way to use leftover roast meat.',
    ),
    CookingFact(
      country: 'UK',
      text: 'The mashed potato topping gets crispy and golden in the oven.',
    ),
  ],
  badge: CookingBadge(
    id: 'uk_shepherds_pie_chef',
    title: 'Pie Master',
    country: 'UK',
    iconAsset: 'assets/cooking/effects/badge_uk_chef.png',
  ),
);

const Recipe ukTrifleRecipe = Recipe(
  id: 'uk_trifle',
  name: 'Trifle',
  country: 'UK',
  potAsset: 'assets/cooking/pots/classic_pot.png',
  chefAsset: 'assets/cooking/chefs/chef_ava.png',
  requiredStirTurns: 4,
  requiredSpiceShakes: 0,
  requiredServeScoops: 3,
  ingredients: <Ingredient>[
    Ingredient(
      id: 'sponge',
      name: 'Sponge Cake',
      assetPath: 'assets/cooking/ingredients/sponge.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'custard',
      name: 'Custard',
      assetPath: 'assets/cooking/ingredients/custard.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'fruit',
      name: 'Fruit',
      assetPath: 'assets/cooking/ingredients/fruit.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'cream',
      name: 'Cream',
      assetPath: 'assets/cooking/ingredients/cream.png',
      country: 'UK',
    ),
  ],
  facts: <CookingFact>[
    CookingFact(
      country: 'UK',
      text: 'Trifle has been a British dessert for over 400 years!',
    ),
    CookingFact(
      country: 'UK',
      text: 'The word \u{201C}trifle\u{201D} means something small and fun.',
    ),
    CookingFact(
      country: 'UK',
      text: 'Every family layers their trifle a little differently.',
    ),
  ],
  badge: CookingBadge(
    id: 'uk_trifle_chef',
    title: 'Dessert Star',
    country: 'UK',
    iconAsset: 'assets/cooking/effects/badge_uk_chef.png',
  ),
);

const Recipe ukCrumpetsRecipe = Recipe(
  id: 'uk_crumpets',
  name: 'Crumpets',
  country: 'UK',
  potAsset: 'assets/cooking/pots/classic_pot.png',
  chefAsset: 'assets/cooking/chefs/chef_ava.png',
  requiredStirTurns: 3,
  requiredSpiceShakes: 0,
  requiredServeScoops: 2,
  ingredients: <Ingredient>[
    Ingredient(
      id: 'crumpet',
      name: 'Crumpet',
      assetPath: 'assets/cooking/ingredients/crumpet.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'butter',
      name: 'Butter',
      assetPath: 'assets/cooking/ingredients/butter.png',
      country: 'UK',
    ),
    Ingredient(
      id: 'honey',
      name: 'Honey',
      assetPath: 'assets/cooking/ingredients/honey.png',
      country: 'UK',
    ),
  ],
  facts: <CookingFact>[
    CookingFact(
      country: 'UK',
      text: 'Crumpets have been eaten in Britain since the 1600s!',
    ),
    CookingFact(
      country: 'UK',
      text: 'The little holes in crumpets soak up melted butter perfectly.',
    ),
    CookingFact(
      country: 'UK',
      text: 'British people eat over 80 million crumpets each year.',
    ),
  ],
  badge: CookingBadge(
    id: 'uk_crumpets_chef',
    title: 'Crumpet King',
    country: 'UK',
    iconAsset: 'assets/cooking/effects/badge_uk_chef.png',
  ),
);

const List<Recipe> ukRecipes = <Recipe>[
  ukFishAndChipsRecipe,
  ukSconesRecipe,
  ukFullBreakfastRecipe,
  ukShepherdsPieRecipe,
  ukTrifleRecipe,
  ukCrumpetsRecipe,
];

/// Look up a premium UK recipe by its simple-model ID.
Recipe? findPremiumUkRecipe(String id) {
  for (final recipe in ukRecipes) {
    if (recipe.id == id) return recipe;
  }
  return null;
}
