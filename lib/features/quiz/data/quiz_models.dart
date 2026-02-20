/// A single quiz question with image and fun fact.
class QuizItem {
  const QuizItem({
    required this.id,
    required this.countryId,
    required this.question,
    required this.answer,
    required this.funFact,
    required this.image,
  });

  final String id;
  final String countryId;
  final String question;
  final String answer;
  final String funFact;
  final String image;

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    return QuizItem(
      id: (json['id'] as String? ?? '').trim(),
      countryId: (json['countryId'] as String? ?? '').trim(),
      question: (json['question'] as String? ?? '').trim(),
      answer: (json['answer'] as String? ?? '').trim(),
      funFact: (json['funFact'] as String? ?? '').trim(),
      image: (json['image'] as String? ?? '').trim(),
    );
  }
}

/// Persisted progress for a single quiz.
class QuizProgress {
  const QuizProgress({
    required this.quizId,
    this.countryId = '',
    this.completed = false,
    this.completedAt,
  });

  final String quizId;
  final String countryId;
  final bool completed;
  final DateTime? completedAt;

  factory QuizProgress.fromJson(Map<String, dynamic> json) {
    return QuizProgress(
      quizId: (json['quizId'] as String? ?? '').trim(),
      countryId: (json['countryId'] as String? ?? '').trim(),
      completed: json['completed'] as bool? ?? false,
      completedAt: _parseDate(json['completedAt'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'countryId': countryId,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

/// Persisted state for the daily quiz rotation.
class QuizDailyState {
  const QuizDailyState({
    this.lastSeenDay = 0,
    this.featuredQuizId = '',
  });

  final int lastSeenDay;
  final String featuredQuizId;

  factory QuizDailyState.fromJson(Map<String, dynamic> json) {
    return QuizDailyState(
      lastSeenDay: (json['lastSeenDay'] as num?)?.toInt() ?? 0,
      featuredQuizId: (json['featuredQuizId'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastSeenDay': lastSeenDay,
      'featuredQuizId': featuredQuizId,
    };
  }

  QuizDailyState copyWith({
    int? lastSeenDay,
    String? featuredQuizId,
  }) {
    return QuizDailyState(
      lastSeenDay: lastSeenDay ?? this.lastSeenDay,
      featuredQuizId: featuredQuizId ?? this.featuredQuizId,
    );
  }
}
