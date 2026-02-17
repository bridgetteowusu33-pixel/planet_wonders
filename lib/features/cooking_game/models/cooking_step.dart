enum CookingState {
  intro,
  addIngredients,
  stir,
  plate,
  complete,
}

class CookingStep {
  const CookingStep({
    required this.state,
    required this.instruction,
  });

  final CookingState state;
  final String instruction;
}
