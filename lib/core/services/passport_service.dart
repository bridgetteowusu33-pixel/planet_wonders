import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod provider for passport badges — invalidate after unlocking a badge
/// so watchers (e.g. PassportScreen) refresh automatically.
final passportBadgesProvider = FutureProvider<Set<String>>((ref) async {
  return PassportService.unlockedBadges();
});

class PassportService {
  static const String _kUnlockedBadges = 'passport_unlocked_badges';

  static Future<void> unlockBadge(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final badges = (prefs.getStringList(_kUnlockedBadges) ?? const <String>[])
        .toSet();
    badges.add(badgeId);
    await prefs.setStringList(_kUnlockedBadges, badges.toList(growable: false));
  }

  static Future<Set<String>> unlockedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kUnlockedBadges) ?? const <String>[]).toSet();
  }
}
