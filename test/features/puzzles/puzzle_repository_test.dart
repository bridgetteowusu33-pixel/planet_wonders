import 'package:flutter_test/flutter_test.dart';
import 'package:planet_wonders/features/puzzles/data/puzzle_catalog.dart';
import 'package:planet_wonders/features/puzzles/data/puzzle_repository.dart';
import 'package:planet_wonders/features/puzzles/data/puzzle_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PuzzleRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = PuzzleRepository(
      catalog: PuzzleCatalog(loader: (_) async => _catalogJson),
      storage: PuzzleStorage(),
    );
  });

  test('loads Ghana pack catalog and puzzles', () async {
    final packs = await repository.getPacks();

    expect(packs, hasLength(1));
    expect(packs.first.id, 'ghana_pack');
    expect(packs.first.puzzles, hasLength(2));
    expect(packs.first.puzzles.first.id, 'ghana_01_beach');
  });

  test('persists completion and calculates stars', () async {
    final puzzle = (await repository.getPacks()).first.puzzles.first;

    final progress = await repository.completePuzzle(
      puzzle: puzzle,
      elapsedMs: 45000,
      moves: 19,
      hintsUsed: 0,
    );

    expect(progress.completed, isTrue);
    expect(progress.stars, 3);
    expect(progress.bestMoves, 19);

    final loaded = await repository.getProgressForPuzzle(puzzle.id);
    expect(loaded.completed, isTrue);
    expect(loaded.stars, 3);
  });

  test('unlocks later puzzle only after previous completion', () async {
    final pack = (await repository.getPacks()).first;

    final initialUnlocked = await repository.unlockedPuzzleIds(pack.id);
    expect(initialUnlocked.contains('ghana_01_beach'), isTrue);
    expect(initialUnlocked.contains('ghana_02_market'), isFalse);

    await repository.completePuzzle(
      puzzle: pack.puzzles.first,
      elapsedMs: 130000,
      moves: 33,
      hintsUsed: 0,
    );

    final updatedUnlocked = await repository.unlockedPuzzleIds(pack.id);
    expect(updatedUnlocked.contains('ghana_02_market'), isTrue);
  });

  test('saves and loads puzzle resume state', () async {
    final puzzle = (await repository.getPacks()).first.puzzles.first;

    await repository.saveResume(
      puzzle: puzzle,
      seed: 1234,
      placedPieceIds: {'r0_c0', 'r0_c1'},
      moves: 5,
      elapsedMs: 12000,
      hintsUsed: 3,
    );

    final resume = await repository.loadResume(puzzle.id);
    expect(resume, isNotNull);
    expect(resume!.seed, 1234);
    expect(resume.placedPieceIds, containsAll({'r0_c0', 'r0_c1'}));
    expect(resume.hintsUsed, 3);
  });
}

const _catalogJson = '''
{
  "packs": [
    {
      "id": "ghana_pack",
      "title": "Ghana Pack",
      "countryCode": "GH",
      "thumbnail": "assets/puzzles/ghana/thumbs/ghana_cover.png",
      "difficultyTiers": ["easy", "medium", "hard"],
      "puzzles": [
        {
          "id": "ghana_01_beach",
          "title": "Beach Day",
          "image": "assets/puzzles/ghana/full/ghana_01_beach.jpg",
          "thumbnail": "assets/puzzles/ghana/thumbs/ghana_01_beach.png",
          "rows": 3,
          "cols": 3,
          "difficulty": "easy",
          "targetTimeSec": 90,
          "unlockedByDefault": true
        },
        {
          "id": "ghana_02_market",
          "title": "Busy Market",
          "image": "assets/puzzles/ghana/full/ghana_02_market.jpg",
          "thumbnail": "assets/puzzles/ghana/thumbs/ghana_02_market.png",
          "rows": 4,
          "cols": 4,
          "difficulty": "easy",
          "targetTimeSec": 120,
          "unlockedByDefault": false
        }
      ]
    }
  ]
}
''';
