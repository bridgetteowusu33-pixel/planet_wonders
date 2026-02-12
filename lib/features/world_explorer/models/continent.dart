import 'country.dart';

/// A continent grouping countries for the World Explorer map.
class Continent {
  final String id;
  final String name;
  final String emoji;
  final List<Country> countries;

  const Continent({
    required this.id,
    required this.name,
    required this.emoji,
    required this.countries,
  });

  /// How many countries the kid has unlocked in this continent.
  int get unlockedCount => countries.where((c) => c.isUnlocked).length;
}
