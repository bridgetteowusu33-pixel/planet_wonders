import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planet_wonders/features/puzzles/data/puzzle_catalog.dart';
import 'package:planet_wonders/features/puzzles/data/puzzle_repository.dart';
import 'package:planet_wonders/features/puzzles/data/puzzle_storage.dart';
import 'package:planet_wonders/features/puzzles/presentation/puzzle_home_screen.dart';
import 'package:planet_wonders/features/puzzles/presentation/puzzle_pack_screen.dart';
import 'package:planet_wonders/features/puzzles/presentation/puzzle_play_screen.dart';
import 'package:planet_wonders/features/puzzles/presentation/widgets/draggable_piece.dart';
import 'package:planet_wonders/features/puzzles/presentation/widgets/puzzle_board.dart';
import 'package:planet_wonders/features/puzzles/providers/puzzle_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PuzzleHome renders packs', (tester) async {
    final repo = _buildRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [puzzleRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: PuzzleHomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ghana Pack'), findsOneWidget);
    expect(find.text('Build pictures, earn stars!'), findsOneWidget);
  });

  testWidgets('Pack screen filters difficulty', (tester) async {
    final repo = _buildRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [puzzleRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: PuzzlePackScreen(packId: 'ghana_pack')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Beach Day'), findsOneWidget);
    expect(find.text('Ghana Flag'), findsOneWidget);

    await tester.tap(find.text('Hard'));
    await tester.pumpAndSettle();

    expect(find.text('Ghana Flag'), findsOneWidget);
    expect(find.text('Beach Day'), findsNothing);
  });

  testWidgets('Completing puzzle triggers win modal', (tester) async {
    final repo = _buildRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [puzzleRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(
          home: PuzzlePlayScreen(
            puzzleId: 'ghana_01_beach',
            packId: 'ghana_pack',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final pieceFinder = find.byType(DraggablePiece).first;
    final boardFinder = find.byType(PuzzleBoard).first;

    final pieceCenter = tester.getCenter(pieceFinder);
    final boardCenter = tester.getCenter(boardFinder);

    final gesture = await tester.startGesture(pieceCenter);
    await tester.pump(const Duration(milliseconds: 650));
    await gesture.moveTo(boardCenter);
    await tester.pump();
    await gesture.up();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Great Job!'), findsOneWidget);
  });
}

PuzzleRepository _buildRepository() {
  return PuzzleRepository(
    catalog: PuzzleCatalog(loader: (_) async => _catalogJson),
    storage: PuzzleStorage(),
  );
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
          "rows": 1,
          "cols": 1,
          "difficulty": "easy",
          "targetTimeSec": 90,
          "unlockedByDefault": true
        },
        {
          "id": "ghana_06_flag",
          "title": "Ghana Flag",
          "image": "assets/puzzles/ghana/full/ghana_06_flag.jpg",
          "thumbnail": "assets/puzzles/ghana/thumbs/ghana_06_flag.png",
          "rows": 2,
          "cols": 2,
          "difficulty": "hard",
          "targetTimeSec": 120,
          "unlockedByDefault": false
        }
      ]
    }
  ]
}
''';
