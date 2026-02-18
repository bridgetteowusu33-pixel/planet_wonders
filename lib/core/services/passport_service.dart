import 'package:shared_preferences/shared_preferences.dart';

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
