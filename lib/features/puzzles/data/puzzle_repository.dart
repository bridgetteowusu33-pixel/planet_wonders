import 'package:flutter/foundation.dart';

import 'puzzle_catalog.dart';
import 'puzzle_models.dart';
import 'puzzle_storage.dart';

class PuzzleRepository {
  PuzzleRepository({PuzzleCatalog? catalog, PuzzleStorage? storage})
    : _catalog = catalog ?? PuzzleCatalog(),
      _storage = storage ?? PuzzleStorage();

  final PuzzleCatalog _catalog;
  final PuzzleStorage _storage;

  List<PuzzlePack>? _cachedPacks;
  Map<String, PuzzleItem>? _cachedPuzzleById;
  Map<String, PuzzleProgress>? _cachedProgress;

  Future<List<PuzzlePack>> getPacks({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPacks != null) {
      return _cachedPacks!;
    }

    final packs = await _catalog.loadPacks();
    _cachedPacks = packs;
    _cachedPuzzleById = {
      for (final puzzle in packs.expand((pack) => pack.puzzles))
        puzzle.id: puzzle,
    };
    return packs;
  }

  Future<PuzzlePack?> getPackById(String packId) async {
    final packs = await getPacks();
    for (final pack in packs) {
      if (pack.id == packId) return pack;
    }
    return null;
  }

  Future<PuzzleItem?> getPuzzleById(String puzzleId) async {
    final map = _cachedPuzzleById;
    if (map != null) return map[puzzleId];
    await getPacks();
    return _cachedPuzzleById?[puzzleId];
  }

  Future<Map<String, PuzzleProgress>> getProgressMap({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedProgress != null) {
      return _cachedProgress!;
    }
    _cachedProgress = Map<String, PuzzleProgress>.of(
      await _storage.loadProgressMap(),
    );
    return _cachedProgress!;
  }

  Future<PuzzleProgress> getProgressForPuzzle(String puzzleId) async {
    final map = await getProgressMap();
    return map[puzzleId] ?? PuzzleProgress(puzzleId: puzzleId);
  }

  Future<PackProgressSummary> getPackSummary(String packId) async {
    final pack = await getPackById(packId);
    if (pack == null) {
      return const PackProgressSummary(
        packId: '',
        completedCount: 0,
        totalCount: 0,
        totalStars: 0,
      );
    }

    final progress = await getProgressMap();
    var completed = 0;
    var stars = 0;

    for (final puzzle in pack.puzzles) {
      final p = progress[puzzle.id];
      if (p == null) continue;
      if (p.completed) completed++;
      stars += p.stars;
    }

    return PackProgressSummary(
      packId: pack.id,
      completedCount: completed,
      totalCount: pack.puzzles.length,
      totalStars: stars,
    );
  }

  Future<Set<String>> unlockedPuzzleIds(String packId) async {
    final pack = await getPackById(packId);
    if (pack == null) return const <String>{};

    final progress = await getProgressMap();
    final unlocked = <String>{};

    for (var i = 0; i < pack.puzzles.length; i++) {
      final puzzle = pack.puzzles[i];
      if (puzzle.unlockedByDefault) {
        unlocked.add(puzzle.id);
        continue;
      }

      if (i == 0) {
        unlocked.add(puzzle.id);
        continue;
      }

      final previous = pack.puzzles[i - 1];
      final previousProgress = progress[previous.id];
      if (previousProgress?.completed ?? false) {
        unlocked.add(puzzle.id);
      }
    }

    return unlocked;
  }

  Future<void> touchPuzzle(String puzzleId) async {
    final current = await getProgressForPuzzle(puzzleId);
    final updated = current.copyWith(lastPlayedAt: DateTime.now());
    await _storage.saveProgress(updated);
    _cachedProgress ??= {};
    _cachedProgress![puzzleId] = updated;
    await _storage.setLastOpenedPuzzle(puzzleId);
  }

  Future<void> saveResume({
    required PuzzleItem puzzle,
    required int seed,
    required Set<String> placedPieceIds,
    required int moves,
    required int elapsedMs,
    required int hintsUsed,
  }) async {
    await _storage.saveResumeState(
      PuzzleResumeState(
        puzzleId: puzzle.id,
        seed: seed,
        placedPieceIds: placedPieceIds,
        moves: moves,
        elapsedMs: elapsedMs,
        hintsUsed: hintsUsed,
        lastSavedAt: DateTime.now(),
      ),
    );

    await touchPuzzle(puzzle.id);
  }

  Future<PuzzleResumeState?> loadResume(String puzzleId) {
    return _storage.loadResumeState(puzzleId);
  }

  Future<void> clearResume(String puzzleId) {
    return _storage.clearResumeState(puzzleId);
  }

  Future<PuzzleProgress> completePuzzle({
    required PuzzleItem puzzle,
    required int elapsedMs,
    required int moves,
    required int hintsUsed,
  }) async {
    final previous = await getProgressForPuzzle(puzzle.id);

    final stars = calculatePuzzleStars(
      elapsedMs: elapsedMs,
      targetTimeSec: puzzle.targetTimeSec,
      hintsUsed: hintsUsed,
    );

    final bestTime = switch (previous.bestTimeMs) {
      null => elapsedMs,
      final existing => elapsedMs < existing ? elapsedMs : existing,
    };

    final bestMoves = switch (previous.bestMoves) {
      null => moves,
      final existing => moves < existing ? moves : existing,
    };

    final updated = previous.copyWith(
      completed: true,
      bestTimeMs: bestTime,
      bestMoves: bestMoves,
      stars: stars > previous.stars ? stars : previous.stars,
      lastPlayedAt: DateTime.now(),
    );

    await _storage.saveProgress(updated);
    _cachedProgress ??= {};
    _cachedProgress![updated.puzzleId] = updated;

    await _storage.clearResumeState(puzzle.id);
    await _storage.setLastOpenedPuzzle(puzzle.id);

    return updated;
  }

  Future<String?> getLastOpenedPuzzle() {
    return _storage.getLastOpenedPuzzle();
  }

  @visibleForTesting
  void clearMemoryCache() {
    _cachedPacks = null;
    _cachedPuzzleById = null;
    _cachedProgress = null;
  }
}
