# Cooking Mini-Game Engine

## Overview
This module provides a step-based cooking engine for Planet Wonders with a child-friendly UI and reusable animations.

## Architecture
- `engine/`
  - `CookingController`: Orchestrates input, steps, scoring, and completion events.
  - `CookingState`: `ChangeNotifier` state model (`currentStep`, `progress`, `stars`, `isComplete`).
  - `CookingEngine`: Gesture math and score computation (heavy score work runs in an isolate).
  - `CookingConfig`: Tunable weights and thresholds.
- `ui/`
  - `CookingScreen`: Full responsive game screen.
  - `PotWidget`, `IngredientWidget`, `StirWidget`, `ServeWidget`, `ChefWidget`.
- `animations/`
  - Bubble, swirl, steam, confetti effects (all wrapped in `RepaintBoundary`).
- `models/`
  - `Recipe`, `Ingredient`, `CookingBadge`, `CookingFact`.
- `data/`
  - `ghana_recipes.dart`, `usa_recipes.dart`.

## Runtime Flow
1. Add ingredients (`addIngredients`)
2. Stir by circular gesture (`stir`)
3. Spice with shake-style gesture (`spice`)
4. Serve by scoop-drop (`serve`)
5. Completion (`complete`) with badge unlock and confetti

## Performance Notes
- No `setState` loops for gameplay state.
- `ValueNotifier` / `ChangeNotifier` drive updates.
- Heavy visuals are isolated with `RepaintBoundary`.
- Score computation uses `Isolate.run`.
- Asset preloading checks bundle existence before decode.
- Stir velocity sample list is bounded to avoid long-session growth.

## Passport Integration
On completion, badge unlock is saved locally via:
- `PassportService.unlockBadge(recipe.badge.id)`

## Run Tests
- `flutter test test/features/cooking`
