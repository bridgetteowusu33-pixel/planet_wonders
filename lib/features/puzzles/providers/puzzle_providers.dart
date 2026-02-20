import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/puzzle_catalog.dart';
import '../data/puzzle_models.dart';
import '../data/puzzle_repository.dart';
import '../data/puzzle_storage.dart';

final puzzleCatalogProvider = Provider<PuzzleCatalog>((ref) {
  return PuzzleCatalog();
});

final puzzleStorageProvider = Provider<PuzzleStorage>((ref) {
  return PuzzleStorage();
});

final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  return PuzzleRepository(
    catalog: ref.watch(puzzleCatalogProvider),
    storage: ref.watch(puzzleStorageProvider),
  );
});

final puzzlePacksProvider = FutureProvider<List<PuzzlePack>>((ref) async {
  return ref.watch(puzzleRepositoryProvider).getPacks();
});

final puzzlePackProvider = FutureProvider.family<PuzzlePack?, String>((
  ref,
  packId,
) async {
  return ref.watch(puzzleRepositoryProvider).getPackById(packId);
});

final puzzleByIdProvider = FutureProvider.family<PuzzleItem?, String>((
  ref,
  puzzleId,
) async {
  return ref.watch(puzzleRepositoryProvider).getPuzzleById(puzzleId);
});

final puzzleProgressMapProvider = FutureProvider<Map<String, PuzzleProgress>>((
  ref,
) async {
  return ref.watch(puzzleRepositoryProvider).getProgressMap(forceRefresh: true);
});

final puzzleProgressByIdProvider = Provider.family<PuzzleProgress?, String>((
  ref,
  puzzleId,
) {
  final map = ref.watch(puzzleProgressMapProvider).value;
  return map?[puzzleId];
});

final packSummaryProvider = FutureProvider.family<PackProgressSummary, String>((
  ref,
  packId,
) async {
  final pack = await ref.watch(puzzlePackProvider(packId).future);
  final progress =
      ref.watch(puzzleProgressMapProvider).value ?? const <String, PuzzleProgress>{};

  if (pack == null) {
    return const PackProgressSummary(
      packId: '',
      completedCount: 0,
      totalCount: 0,
      totalStars: 0,
    );
  }

  var completed = 0;
  var stars = 0;
  for (final puzzle in pack.puzzles) {
    final p = progress[puzzle.id];
    if (p?.completed ?? false) completed += 1;
    stars += p?.stars ?? 0;
  }

  return PackProgressSummary(
    packId: pack.id,
    completedCount: completed,
    totalCount: pack.puzzles.length,
    totalStars: stars,
  );
});

final unlockedPuzzleIdsProvider = FutureProvider.family<Set<String>, String>((
  ref,
  packId,
) async {
  final pack = await ref.watch(puzzlePackProvider(packId).future);
  final progress =
      ref.watch(puzzleProgressMapProvider).value ?? const <String, PuzzleProgress>{};
  if (pack == null) return const <String>{};

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
    if (progress[previous.id]?.completed ?? false) {
      unlocked.add(puzzle.id);
    }
  }

  return unlocked;
});

final puzzleActionsProvider = Provider<PuzzleActions>((ref) {
  return PuzzleActions(ref);
});

class PuzzleActions {
  const PuzzleActions(this._ref);

  final Ref _ref;

  PuzzleRepository get _repo => _ref.read(puzzleRepositoryProvider);

  Future<void> touchPuzzle(String puzzleId) async {
    await _repo.touchPuzzle(puzzleId);
  }

  Future<void> saveResume({
    required PuzzleItem puzzle,
    required int seed,
    required Set<String> placedPieceIds,
    required int moves,
    required int elapsedMs,
    required int hintsUsed,
  }) async {
    await _repo.saveResume(
      puzzle: puzzle,
      seed: seed,
      placedPieceIds: placedPieceIds,
      moves: moves,
      elapsedMs: elapsedMs,
      hintsUsed: hintsUsed,
    );
  }

  Future<PuzzleResumeState?> loadResume(String puzzleId) async {
    return _repo.loadResume(puzzleId);
  }

  Future<PuzzleProgress> completePuzzle({
    required PuzzleItem puzzle,
    required int elapsedMs,
    required int moves,
    required int hintsUsed,
  }) async {
    final progress = await _repo.completePuzzle(
      puzzle: puzzle,
      elapsedMs: elapsedMs,
      moves: moves,
      hintsUsed: hintsUsed,
    );
    _invalidateDerived();
    return progress;
  }

  Future<void> clearResume(String puzzleId) async {
    await _repo.clearResume(puzzleId);
  }

  Future<String?> getLastOpenedPuzzle() {
    return _repo.getLastOpenedPuzzle();
  }

  void _invalidateDerived() {
    _ref.invalidate(puzzleProgressMapProvider);
  }
}
