/// A single country inside a continent.
///
/// All country-specific content (stories, coloring pages, food, etc.) hangs
/// off the [id] so content can be loaded data-driven without hardcoding.
class Country {
  final String id;
  final String name;
  final String flagEmoji;
  final String continentId;
  final bool isUnlocked;
  final String greeting; // e.g. "Welcome to Ghana!"

  const Country({
    required this.id,
    required this.name,
    required this.flagEmoji,
    required this.continentId,
    this.isUnlocked = false,
    required this.greeting,
  });
}
