import 'package:flutter/services.dart';

/// Light haptic feedback cues keyed by recipe-step metadata.
class RecipeStoryFeedback {
  static Future<void> playCue(String? cue) async {
    final normalized = cue?.trim().toLowerCase();
    try {
      switch (normalized) {
        case 'tap':
        case 'drop':
          await HapticFeedback.selectionClick();
          return;
        case 'stir':
        case 'hold':
          await HapticFeedback.lightImpact();
          return;
        case 'complete':
        case 'celebrate':
          await HapticFeedback.mediumImpact();
          return;
        default:
          await HapticFeedback.selectionClick();
      }
    } catch (_) {
      // Optional feedback only.
    }
  }
}
