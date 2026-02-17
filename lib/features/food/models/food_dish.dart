/// A single dish shown in Food Mode.
class FoodDish {
  const FoodDish({
    required this.id,
    required this.name,
    required this.emoji,
    required this.previewAsset,
    required this.funFact,
    required this.didYouKnow,
    required this.coloringPageId,
  });

  final String id;
  final String name;
  final String emoji;
  final String previewAsset;
  final String funFact;
  final List<String> didYouKnow;
  final String coloringPageId;
}

/// All food content for one country.
class FoodPack {
  const FoodPack({
    required this.countryId,
    required this.bannerEmoji,
    required this.dishes,
  });

  final String countryId;
  final String bannerEmoji;
  final List<FoodDish> dishes;
}
