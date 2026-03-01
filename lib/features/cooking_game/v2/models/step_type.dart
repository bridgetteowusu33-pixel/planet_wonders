/// The types of interactive mini-game steps available in V2 cooking.
enum V2StepType {
  /// Drag ingredients into the pot.
  addIngredients,

  /// Tap to chop items on a cutting board.
  chop,

  /// Circular finger gesture to stir the pot.
  stir,

  /// Press & hold to heat — release in the green zone (generic).
  heat,

  /// Press & hold to boil — release in the green zone.
  boil,

  /// Press & hold to fry — release in the green zone.
  fry,

  /// Press & hold to bake — release in the green zone.
  bake,

  /// Shake or tap the spice shaker.
  season,

  /// Watch bubbles rise and tap at the right time.
  simmer,

  /// Drag scoops onto the plate to serve.
  plate;

  /// Whether this is any kind of heat step (heat, boil, fry, bake).
  bool get isHeat =>
      this == heat || this == boil || this == fry || this == bake;

  /// Display label for heat variants.
  String get heatLabel => switch (this) {
        boil => 'boil',
        fry => 'fry',
        bake => 'bake',
        _ => 'heat',
      };

  /// Emoji for heat variants.
  String get heatEmoji => switch (this) {
        boil => '\u{1F4A7}', // 💧
        fry => '\u{1F373}', // 🍳
        bake => '\u{1F9C1}', // 🧁
        _ => '\u{1F525}', // 🔥
      };
}
