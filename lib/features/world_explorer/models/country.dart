/// A single country inside a continent.
///
/// All country-specific content (stories, coloring pages, food, etc.) hangs
/// off the [id] so content can be loaded data-driven without hardcoding.
class Country {
  final String id;
  final String name;
  final String flagEmoji;
  final String? flagAsset; // e.g. 'assets/flags/ghana.webp'
  final String continentId;
  final bool isUnlocked;
  final String greeting; // e.g. "Welcome to Ghana!"
  final String? localGreeting; // e.g. "AKWAABA!" — native-language greeting

  const Country({
    required this.id,
    required this.name,
    required this.flagEmoji,
    this.flagAsset,
    required this.continentId,
    this.isUnlocked = false,
    required this.greeting,
    this.localGreeting,
  });
}
