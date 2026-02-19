import 'dart:convert';

class CategoryMinutes {
  const CategoryMinutes({
    this.stories = 0,
    this.coloring = 0,
    this.cooking = 0,
    this.fashion = 0,
    this.worldExplorer = 0,
    this.other = 0,
  });

  final int stories;
  final int coloring;
  final int cooking;
  final int fashion;
  final int worldExplorer;
  final int other;

  int get total =>
      stories + coloring + cooking + fashion + worldExplorer + other;

  CategoryMinutes addSeconds(String category, int seconds) {
    return CategoryMinutes(
      stories: stories + (category == 'stories' ? seconds : 0),
      coloring: coloring + (category == 'coloring' ? seconds : 0),
      cooking: cooking + (category == 'cooking' ? seconds : 0),
      fashion: fashion + (category == 'fashion' ? seconds : 0),
      worldExplorer:
          worldExplorer + (category == 'worldExplorer' ? seconds : 0),
      other: other + (category == 'other' ? seconds : 0),
    );
  }

  /// Total minutes (rounded down from seconds stored internally).
  int get totalMinutes => total ~/ 60;

  int minutesFor(String category) => secondsFor(category) ~/ 60;

  int secondsFor(String category) => switch (category) {
        'stories' => stories,
        'coloring' => coloring,
        'cooking' => cooking,
        'fashion' => fashion,
        'worldExplorer' => worldExplorer,
        'other' => other,
        _ => 0,
      };

  Map<String, int> toJson() => {
        'stories': stories,
        'coloring': coloring,
        'cooking': cooking,
        'fashion': fashion,
        'worldExplorer': worldExplorer,
        'other': other,
      };

  factory CategoryMinutes.fromJson(Map<String, dynamic> json) {
    return CategoryMinutes(
      stories: json['stories'] as int? ?? 0,
      coloring: json['coloring'] as int? ?? 0,
      cooking: json['cooking'] as int? ?? 0,
      fashion: json['fashion'] as int? ?? 0,
      worldExplorer: json['worldExplorer'] as int? ?? 0,
      other: json['other'] as int? ?? 0,
    );
  }
}

class DailyUsageRecord {
  const DailyUsageRecord({
    required this.dateKey,
    this.seconds = const CategoryMinutes(),
  });

  /// Date in 'yyyy-MM-dd' format.
  final String dateKey;

  /// Seconds spent per category (stored as seconds for precision).
  final CategoryMinutes seconds;

  int get totalMinutes => seconds.totalMinutes;

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'seconds': seconds.toJson(),
      };

  factory DailyUsageRecord.fromJson(Map<String, dynamic> json) {
    return DailyUsageRecord(
      dateKey: json['dateKey'] as String,
      seconds: json['seconds'] is Map<String, dynamic>
          ? CategoryMinutes.fromJson(json['seconds'] as Map<String, dynamic>)
          : const CategoryMinutes(),
    );
  }

  static String encodeList(List<DailyUsageRecord> records) {
    return jsonEncode(records.map((r) => r.toJson()).toList());
  }

  static List<DailyUsageRecord> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(DailyUsageRecord.fromJson)
        .toList(growable: false);
  }

  /// Today's date key.
  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
