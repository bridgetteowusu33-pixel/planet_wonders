# Cooking Mini-Game (v1)

This feature provides a quick 2-3 minute cooking interaction flow for kids:

1. Add ingredients (drag/drop)
2. Stir (circular swipe)
3. Plate/serve (drag spoon)
4. Celebrate (badge/confetti)

## Files

- `cooking_entry.dart`: launch API + reusable entry button
- `cooking_game_screen.dart`: main game flow UI
- `cooking_controller.dart`: state machine/progress logic
- `models/recipe.dart`: `Recipe` + `Ingredient`
- `models/cooking_step.dart`: `CookingStep` + `CookingState`
- `data/recipes_ghana.dart`: Ghana recipe data (Jollof)
- `ui/*`: modular widgets for each game section
- `utils/gesture_smoothing.dart`: circular swipe smoothing
- `utils/sfx.dart`: haptic/sfx hooks

## Add a New Recipe

1. Add recipe data in a country data file (or shared recipe registry):

- Create `Recipe(id: 'usa_burger', ...)`
- Add ingredients and steps for `addIngredients`, `stir`, `plate`
- Add 2-3 short fun facts

2. Register the recipe in `cookingRecipeRegistry`.

3. Launch from Food UI with:

```dart
CookingEntryButton(
  recipeId: 'usa_burger',
  countryId: 'usa',
  source: 'food',
)
```

or

```dart
await openCookingGame(
  context,
  source: 'games',
  countryId: 'usa',
  recipeId: 'usa_burger',
);
```

Canonical route:

```dart
context.push('/cooking?source=games&countryId=ghana&recipeId=ghana_jollof');
```

## Integration Note

Use `CookingEntryButton` in Food Detail pages next to "Color This Food".
No changes are required to the core coloring engine.
