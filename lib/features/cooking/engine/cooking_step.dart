enum CookingStep { addIngredients, stir, spice, serve, complete }

extension CookingStepLabel on CookingStep {
  String get title {
    switch (this) {
      case CookingStep.addIngredients:
        return 'Add Ingredients';
      case CookingStep.stir:
        return 'Stir the Pot';
      case CookingStep.spice:
        return 'Add Spice';
      case CookingStep.serve:
        return 'Serve';
      case CookingStep.complete:
        return 'Complete';
    }
  }
}
