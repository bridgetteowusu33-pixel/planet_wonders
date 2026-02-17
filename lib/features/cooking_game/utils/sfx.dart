import 'package:flutter/services.dart';

/// Placeholder hooks for SFX/haptics.
///
/// Replace with real sound playback later if needed.
class Sfx {
  static Future<void> plop() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static Future<void> stirTick() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static Future<void> celebrate() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
