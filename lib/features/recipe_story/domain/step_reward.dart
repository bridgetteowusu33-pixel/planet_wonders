/// A small micro-reward earned per cooking step.
///
/// Rewards are cosmetic badges shown in a popup after each step
/// and aggregated in the Recipe Album on completion.
class StepReward {
  const StepReward({
    required this.id,
    required this.title,
    required this.emoji,
  });

  /// Unique identifier, e.g. 'wash_pro', 'chop_champ'.
  final String id;

  /// Display title, e.g. "Chop Champ".
  final String title;

  /// Emoji badge, e.g. "🔪".
  final String emoji;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepReward && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Maps action keys to their micro-rewards.
///
/// When a step is completed, the engine looks up the action key here
/// to determine which badge the player earns.
const Map<String, StepReward> stepRewardCatalog = {
  'tap_bowl': StepReward(
    id: 'wash_pro',
    title: 'Clean Rice Star',
    emoji: '\u{1F4A6}', // 💦
  ),
  'tap_chop': StepReward(
    id: 'chop_champ',
    title: 'Chop Champ',
    emoji: '\u{1F52A}', // 🔪
  ),
  'tap_spice_shaker': StepReward(
    id: 'spice_star',
    title: 'Spice Star',
    emoji: '\u{1F9C2}', // 🧂
  ),
  'tap': StepReward(
    id: 'prep_hero',
    title: 'Prep Hero',
    emoji: '\u{1F44F}', // 👏
  ),
  'drag_oil_to_pot': StepReward(
    id: 'oil_master',
    title: 'Oil Master',
    emoji: '\u{1FAD9}', // 🫙
  ),
  'drag_tomato_mix': StepReward(
    id: 'tomato_artist',
    title: 'Tomato Artist',
    emoji: '\u{1F345}', // 🍅
  ),
  'drag_rice_to_pot': StepReward(
    id: 'rice_dropper',
    title: 'Rice Dropper',
    emoji: '\u{1F35A}', // 🍚
  ),
  'drag': StepReward(
    id: 'ingredient_ace',
    title: 'Ingredient Ace',
    emoji: '\u{1F963}', // 🥣
  ),
  'stir_circle': StepReward(
    id: 'stir_wizard',
    title: 'Stir Wizard',
    emoji: '\u{1F944}', // 🥄
  ),
  'stir': StepReward(
    id: 'stir_wizard',
    title: 'Stir Wizard',
    emoji: '\u{1F944}', // 🥄
  ),
  'hold_to_cook': StepReward(
    id: 'patience_chef',
    title: 'Master Chef',
    emoji: '\u{2668}\u{FE0F}', // ♨️
  ),
  'hold': StepReward(
    id: 'patience_chef',
    title: 'Master Chef',
    emoji: '\u{2668}\u{FE0F}', // ♨️
  ),
  'hold_cook': StepReward(
    id: 'patience_chef',
    title: 'Master Chef',
    emoji: '\u{2668}\u{FE0F}', // ♨️
  ),
  'shake': StepReward(
    id: 'shake_master',
    title: 'Shake Master',
    emoji: '\u{1F4AB}', // 💫
  ),
};

/// Returns the reward for a given action key, or a generic fallback.
StepReward rewardForAction(String actionKey) {
  return stepRewardCatalog[actionKey] ??
      const StepReward(
        id: 'cooking_star',
        title: 'Cooking Star',
        emoji: '\u{2B50}', // ⭐
      );
}
