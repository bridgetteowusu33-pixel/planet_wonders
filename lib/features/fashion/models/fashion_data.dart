import 'dart:ui';

/// All data for a single country's fashion feature.
class FashionData {
  const FashionData({
    required this.countryId,
    required this.characterName,
    required this.characterEmoji,
    required this.categories,
    this.bodyAsset,
    this.bodyShiftY = 0.0,
    this.bodyScale = 1.0,
    this.facts = const [],
  });

  final String countryId;
  final String characterName;
  final String characterEmoji;

  /// Path to the character body PNG (e.g. 'assets/characters/Ava/ava.png').
  /// When non-null, the fashion screen renders layered PNGs instead of emojis.
  final String? bodyAsset;

  /// Vertical shift for the body as a fraction of body height.
  final double bodyShiftY;

  /// Scale factor for the body (1.0 = fill container).
  final double bodyScale;

  final List<OutfitCategory> categories;
  final List<FashionFact> facts;

  /// Whether this country has real image assets.
  bool get hasAssets => bodyAsset != null;
}

/// A clothing category (e.g. Tops, Bottoms, Dress, Hats).
class OutfitCategory {
  const OutfitCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.items,
  });

  final String id;
  final String label;
  final String emoji;
  final List<OutfitItem> items;
}

/// A single clothing/accessory item within a category.
class OutfitItem {
  const OutfitItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.assetPath,
    this.shiftY = 0.0,
    this.scale = 1.0,
  });

  final String id;
  final String name;
  final String emoji;
  final Color color;

  /// Path to the clothing layer PNG. Null for emoji-only items.
  final String? assetPath;

  /// Vertical shift as a fraction of body height (positive = down).
  final double shiftY;

  /// Scale factor relative to body size (1.0 = same size).
  final double scale;
}

/// Tracks which outfit pieces are currently selected.
class OutfitState {
  OutfitState({
    this.dress,
    this.top,
    this.bottom,
    this.hat,
  });

  OutfitItem? dress;
  OutfitItem? top;
  OutfitItem? bottom;
  OutfitItem? hat;

  /// Select an item in the given category.
  /// If a dress is selected, top and bottom are cleared.
  void select(String categoryId, OutfitItem item) {
    switch (categoryId) {
      case 'dress':
        // Toggle: tap same item to deselect.
        if (dress?.id == item.id) {
          dress = null;
        } else {
          dress = item;
          top = null;
          bottom = null;
        }
      case 'tops':
        if (top?.id == item.id) {
          top = null;
        } else {
          top = item;
          dress = null;
        }
      case 'bottoms':
        if (bottom?.id == item.id) {
          bottom = null;
        } else {
          bottom = item;
          dress = null;
        }
      case 'hats':
        if (hat?.id == item.id) {
          hat = null;
        } else {
          hat = item;
        }
    }
  }

  /// Returns the selected item for a given category, if any.
  OutfitItem? selectedFor(String categoryId) {
    return switch (categoryId) {
      'dress' => dress,
      'tops' => top,
      'bottoms' => bottom,
      'hats' => hat,
      _ => null,
    };
  }

  /// Ordered list of asset paths to layer on top of the body.
  List<String> get layerPaths {
    final paths = <String>[];
    // Dress replaces top+bottom
    if (dress?.assetPath != null) {
      paths.add(dress!.assetPath!);
    } else {
      if (bottom?.assetPath != null) paths.add(bottom!.assetPath!);
      if (top?.assetPath != null) paths.add(top!.assetPath!);
    }
    if (hat?.assetPath != null) paths.add(hat!.assetPath!);
    return paths;
  }
}

/// A cultural fact shown after selecting an outfit.
class FashionFact {
  const FashionFact({
    required this.text,
    this.category = 'Culture',
  });

  final String text;
  final String category;
}
