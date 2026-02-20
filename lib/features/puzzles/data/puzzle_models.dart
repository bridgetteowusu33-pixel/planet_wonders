import 'dart:convert';

enum PuzzleDifficulty { easy, medium, hard }

PuzzleDifficulty puzzleDifficultyFromJson(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'easy':
      return PuzzleDifficulty.easy;
    case 'hard':
      return PuzzleDifficulty.hard;
    case 'medium':
    default:
      return PuzzleDifficulty.medium;
  }
}

String puzzleDifficultyToJson(PuzzleDifficulty difficulty) {
  switch (difficulty) {
    case PuzzleDifficulty.easy:
      return 'easy';
    case PuzzleDifficulty.medium:
      return 'medium';
    case PuzzleDifficulty.hard:
      return 'hard';
  }
}

class PuzzleItem {
  const PuzzleItem({
    required this.id,
    required this.packId,
    required this.title,
    required this.imagePath,
    required this.thumbnailPath,
    required this.rows,
    required this.cols,
    required this.difficulty,
    required this.targetTimeSec,
    required this.unlockedByDefault,
  });

  final String id;
  final String packId;
  final String title;
  final String imagePath;
  final String thumbnailPath;
  final int rows;
  final int cols;
  final PuzzleDifficulty difficulty;
  final int targetTimeSec;
  final bool unlockedByDefault;

  int get pieceCount => rows * cols;

  factory PuzzleItem.fromJson(
    Map<String, dynamic> json, {
    required String packId,
  }) {
    return PuzzleItem(
      id: (json['id'] as String? ?? '').trim(),
      packId: packId,
      title: (json['title'] as String? ?? '').trim(),
      imagePath: (json['image'] as String? ?? '').trim(),
      thumbnailPath: (json['thumbnail'] as String? ?? '').trim(),
      rows: (json['rows'] as num?)?.toInt() ?? 3,
      cols: (json['cols'] as num?)?.toInt() ?? 3,
      difficulty: puzzleDifficultyFromJson(
        (json['difficulty'] as String? ?? 'easy'),
      ),
      targetTimeSec: (json['targetTimeSec'] as num?)?.toInt() ?? 120,
      unlockedByDefault: json['unlockedByDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': imagePath,
      'thumbnail': thumbnailPath,
      'rows': rows,
      'cols': cols,
      'difficulty': puzzleDifficultyToJson(difficulty),
      'targetTimeSec': targetTimeSec,
      'unlockedByDefault': unlockedByDefault,
    };
  }
}

class PuzzlePack {
  const PuzzlePack({
    required this.id,
    required this.title,
    required this.countryCode,
    required this.thumbnailPath,
    required this.difficultyTiers,
    required this.puzzles,
  });

  final String id;
  final String title;
  final String countryCode;
  final String thumbnailPath;
  final List<PuzzleDifficulty> difficultyTiers;
  final List<PuzzleItem> puzzles;

  factory PuzzlePack.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String? ?? '').trim();
    final puzzleEntries =
        (json['puzzles'] as List?)?.whereType<Map>() ?? const [];

    final puzzles = puzzleEntries
        .map(
          (entry) =>
              PuzzleItem.fromJson(entry.cast<String, dynamic>(), packId: id),
        )
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false);

    final tiers =
        (json['difficultyTiers'] as List?)
            ?.whereType<String>()
            .map(puzzleDifficultyFromJson)
            .toList(growable: false) ??
        const [
          PuzzleDifficulty.easy,
          PuzzleDifficulty.medium,
          PuzzleDifficulty.hard,
        ];

    return PuzzlePack(
      id: id,
      title: (json['title'] as String? ?? '').trim(),
      countryCode: (json['countryCode'] as String? ?? '').trim(),
      thumbnailPath: (json['thumbnail'] as String? ?? '').trim(),
      difficultyTiers: tiers,
      puzzles: puzzles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'countryCode': countryCode,
      'thumbnail': thumbnailPath,
      'difficultyTiers': difficultyTiers
          .map(puzzleDifficultyToJson)
          .toList(growable: false),
      'puzzles': puzzles.map((e) => e.toJson()).toList(growable: false),
    };
  }
}

class PuzzleProgress {
  const PuzzleProgress({
    required this.puzzleId,
    this.completed = false,
    this.bestTimeMs,
    this.bestMoves,
    this.stars = 0,
    this.lastPlayedAt,
  });

  final String puzzleId;
  final bool completed;
  final int? bestTimeMs;
  final int? bestMoves;
  final int stars;
  final DateTime? lastPlayedAt;

  PuzzleProgress copyWith({
    bool? completed,
    int? bestTimeMs,
    int? bestMoves,
    int? stars,
    DateTime? lastPlayedAt,
  }) {
    return PuzzleProgress(
      puzzleId: puzzleId,
      completed: completed ?? this.completed,
      bestTimeMs: bestTimeMs ?? this.bestTimeMs,
      bestMoves: bestMoves ?? this.bestMoves,
      stars: stars ?? this.stars,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  factory PuzzleProgress.fromJson(Map<String, dynamic> json) {
    return PuzzleProgress(
      puzzleId: (json['puzzleId'] as String? ?? '').trim(),
      completed: json['completed'] as bool? ?? false,
      bestTimeMs: (json['bestTimeMs'] as num?)?.toInt(),
      bestMoves: (json['bestMoves'] as num?)?.toInt(),
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      lastPlayedAt: _parseDate(json['lastPlayedAt'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'puzzleId': puzzleId,
      'completed': completed,
      'bestTimeMs': bestTimeMs,
      'bestMoves': bestMoves,
      'stars': stars,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    };
  }
}

class PuzzleResumeState {
  const PuzzleResumeState({
    required this.puzzleId,
    required this.seed,
    required this.placedPieceIds,
    required this.moves,
    required this.elapsedMs,
    required this.hintsUsed,
    required this.lastSavedAt,
  });

  final String puzzleId;
  final int seed;
  final Set<String> placedPieceIds;
  final int moves;
  final int elapsedMs;
  final int hintsUsed;
  final DateTime lastSavedAt;

  factory PuzzleResumeState.fromJson(Map<String, dynamic> json) {
    final ids =
        (json['placedPieceIds'] as List?)
            ?.whereType<String>()
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty)
            .toSet() ??
        <String>{};

    // Backwards-compatible: read old bool or new int
    final rawHint = json['hintsUsed'] ?? json['hintUsed'];
    final hintsUsed = switch (rawHint) {
      final int v => v,
      true => 5,
      _ => 0,
    };

    return PuzzleResumeState(
      puzzleId: (json['puzzleId'] as String? ?? '').trim(),
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      placedPieceIds: ids,
      moves: (json['moves'] as num?)?.toInt() ?? 0,
      elapsedMs: (json['elapsedMs'] as num?)?.toInt() ?? 0,
      hintsUsed: hintsUsed,
      lastSavedAt: _parseDate(json['lastSavedAt'] as String?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'puzzleId': puzzleId,
      'seed': seed,
      'placedPieceIds': placedPieceIds.toList(growable: false),
      'moves': moves,
      'elapsedMs': elapsedMs,
      'hintsUsed': hintsUsed,
      'lastSavedAt': lastSavedAt.toIso8601String(),
    };
  }
}

class PackProgressSummary {
  const PackProgressSummary({
    required this.packId,
    required this.completedCount,
    required this.totalCount,
    required this.totalStars,
  });

  final String packId;
  final int completedCount;
  final int totalCount;
  final int totalStars;

  double get completionRatio {
    if (totalCount == 0) return 0;
    return completedCount / totalCount;
  }
}

int calculatePuzzleStars({
  required int elapsedMs,
  required int targetTimeSec,
  required int hintsUsed,
}) {
  final targetMs = targetTimeSec * 1000;
  // Using all 5 hints caps stars at 2; time still matters
  final maxStars = hintsUsed >= 5 ? 2 : 3;
  if (elapsedMs <= targetMs) return maxStars;
  if (elapsedMs <= (targetMs * 1.5).round()) return maxStars.clamp(1, 2);
  return 1;
}

String encodeProgressMap(Map<String, PuzzleProgress> input) {
  final payload = input.map((key, value) => MapEntry(key, value.toJson()));
  return jsonEncode(payload);
}

Map<String, PuzzleProgress> decodeProgressMap(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) return const {};
  final out = <String, PuzzleProgress>{};
  decoded.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      final progress = PuzzleProgress.fromJson(value);
      if (progress.puzzleId.isNotEmpty) {
        out[key] = progress;
      }
    }
  });
  return out;
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
