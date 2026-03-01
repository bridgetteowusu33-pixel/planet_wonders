import 'package:flutter/widgets.dart';

import '../models/pot_face_state.dart';
import '../models/v2_recipe.dart';
import '../widgets/chef_avatar.dart';

/// Precaches illustrated cooking assets during the intro screen
/// to prevent pop-in during gameplay.
class V2AssetPreloader {
  V2AssetPreloader._();

  static Future<void> preload(BuildContext context, V2Recipe recipe) async {
    final countryId = recipe.countryId;

    final futures = <Future<void>>[];

    // Kitchen background
    futures.add(_tryPrecache(
      context,
      'assets/cooking/v2/$countryId/kitchen_bg.webp',
    ));

    // All pot face states
    for (final face in PotFaceState.values) {
      futures.add(_tryPrecache(context, face.assetPath(countryId)));
    }

    // Chef character moods
    final charName = _characterNameFor(countryId);
    for (final mood in ChefAvatarMood.values) {
      futures.add(_tryPrecache(
        context,
        'assets/cooking/v2/$countryId/$charName/${charName}_${mood.name}.webp',
      ));
    }

    // Ingredient images
    for (final ingredient in recipe.ingredients) {
      if (ingredient.assetPath != null) {
        futures.add(_tryPrecache(context, ingredient.assetPath!));
      }
    }

    await Future.wait(futures);
  }

  /// Precaches an image, silently ignoring missing assets.
  static Future<void> _tryPrecache(BuildContext context, String path) async {
    try {
      await precacheImage(
        AssetImage(path),
        context,
        onError: (_, _) {
          // Asset not yet generated — emoji fallback will be used.
        },
      );
    } catch (_) {
      // Belt-and-suspenders: catch anything else.
    }
  }

  static String _characterNameFor(String countryId) {
    return switch (countryId.trim().toLowerCase()) {
      'ghana' => 'afia',
      'nigeria' => 'adetutu',
      'uk' || 'united_kingdom' => 'heze',
      'usa' || 'united_states' => 'ava',
      _ => 'chef',
    };
  }
}
