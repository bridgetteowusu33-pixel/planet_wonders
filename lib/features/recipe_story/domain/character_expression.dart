/// Represents Afia's emotional state during recipe steps.
///
/// Each step maps to an expression that determines:
/// 1. Which emoji face to show
/// 2. What encouragement text to display
/// 3. The speech bubble color accent
enum CharacterMood { excited, encouraging, focused, proud, celebrating }

/// Character state for the Story Hero Header.
class CharacterExpression {
  const CharacterExpression({
    required this.mood,
    required this.message,
    this.characterEmoji,
  });

  final CharacterMood mood;

  /// Speech bubble text shown above the character.
  final String message;

  /// Override character emoji (defaults to country-specific character).
  final String? characterEmoji;

  /// The emoji face expression for this mood.
  String get moodEmoji => switch (mood) {
    CharacterMood.excited => '\u{1F929}', // 🤩
    CharacterMood.encouraging => '\u{1F60A}', // 😊
    CharacterMood.focused => '\u{1F9D0}', // 🧐
    CharacterMood.proud => '\u{1F60E}', // 😎
    CharacterMood.celebrating => '\u{1F389}', // 🎉
  };
}

/// Maps action keys to character expressions for Afia.
///
/// The character reacts contextually to what the player is doing,
/// making the experience feel guided and personal.
CharacterExpression expressionForAction(String actionKey) {
  return switch (actionKey) {
    'tap_bowl' => const CharacterExpression(
      mood: CharacterMood.excited,
      message: "Let's wash the rice together!",
    ),
    'tap_chop' => const CharacterExpression(
      mood: CharacterMood.focused,
      message: 'Chop chop! Nice and small!',
    ),
    'tap_spice_shaker' => const CharacterExpression(
      mood: CharacterMood.encouraging,
      message: 'A little sprinkle goes a long way!',
    ),
    'tap' => const CharacterExpression(
      mood: CharacterMood.encouraging,
      message: 'Tap tap! You got this!',
    ),
    'drag_oil_to_pot' => const CharacterExpression(
      mood: CharacterMood.encouraging,
      message: 'Careful! Pour it slowly.',
    ),
    'drag_tomato_mix' => const CharacterExpression(
      mood: CharacterMood.excited,
      message: 'Mmm, tomatoes make it yummy!',
    ),
    'drag_rice_to_pot' => const CharacterExpression(
      mood: CharacterMood.excited,
      message: 'In goes the rice! Almost there!',
    ),
    'drag' => const CharacterExpression(
      mood: CharacterMood.encouraging,
      message: 'Drag it right into the pot!',
    ),
    'stir_circle' || 'stir' => const CharacterExpression(
      mood: CharacterMood.focused,
      message: 'Stir in circles! Faster = more stars!',
    ),
    'hold_to_cook' || 'hold' || 'hold_cook' => const CharacterExpression(
      mood: CharacterMood.focused,
      message: 'Shhh... let it cook quietly.',
    ),
    'shake' => const CharacterExpression(
      mood: CharacterMood.excited,
      message: 'Shake shake shake!',
    ),
    _ => const CharacterExpression(
      mood: CharacterMood.encouraging,
      message: "You're doing great!",
    ),
  };
}

/// The character emoji for each supported country.
String characterForCountry(String countryId) {
  return switch (countryId) {
    'ghana' => '\u{1F469}\u{1F3FE}', // 👩🏾 (Afia)
    'usa' => '\u{1F469}', // 👩 (Ava)
    'nigeria' => '\u{1F467}\u{1F3FE}', // 👧🏾 (Adetutu)
    'uk' => '\u{1F467}\u{1F3FD}', // 👧🏽 (Heze & Aza)
    _ => '\u{1F9D1}\u{200D}\u{1F373}', // 🧑‍🍳
  };
}

/// The character name for each supported country.
String characterNameForCountry(String countryId) {
  return switch (countryId) {
    'ghana' => 'Afia',
    'usa' => 'Ava',
    'nigeria' => 'Adetutu',
    'uk' => 'Heze & Aza',
    _ => 'Chef',
  };
}

/// The flag emoji for each supported country.
String flagForCountry(String countryId) {
  return switch (countryId) {
    'ghana' => '\u{1F1EC}\u{1F1ED}', // 🇬🇭
    'usa' => '\u{1F1FA}\u{1F1F8}', // 🇺🇸
    'nigeria' => '\u{1F1F3}\u{1F1EC}', // 🇳🇬
    'uk' => '\u{1F1EC}\u{1F1E7}', // 🇬🇧
    _ => '\u{1F30D}', // 🌍
  };
}
