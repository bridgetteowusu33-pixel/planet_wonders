import 'dart:convert';

import 'package:flutter/services.dart';

import 'quiz_models.dart';

/// Loads quiz items from the JSON catalog asset.
class QuizCatalog {
  static const String catalogAssetPath = 'assets/quiz/quiz_catalog.json';

  /// For testing — inject a custom loader.
  final Future<String> Function(String) _loader;

  QuizCatalog({Future<String> Function(String)? loader})
      : _loader = loader ?? rootBundle.loadString;

  Future<List<QuizItem>> loadQuizzes() async {
    try {
      final raw = await _loader(catalogAssetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final entries =
          (decoded['quizzes'] as List?)?.whereType<Map>() ?? const [];

      final items = entries
          .map((e) => QuizItem.fromJson(e.cast<String, dynamic>()))
          .where((q) => q.id.isNotEmpty && q.question.isNotEmpty)
          .toList(growable: false);

      return items.isEmpty ? _fallbackQuizzes : items;
    } catch (_) {
      return _fallbackQuizzes;
    }
  }
}

/// Hardcoded fallback if JSON fails to load.
const _fallbackQuizzes = [
  QuizItem(
    id: 'cape_coast',
    countryId: 'ghana',
    question: 'Which big white castle is over 370 years old?',
    answer: 'Cape Coast Castle',
    funFact:
        'Did you know? This castle is so important that the whole world helps protect it!',
    image: 'assets/sliding_puzzles/ghana/ghana_01_capecoast_castle.jpg',
  ),
];
