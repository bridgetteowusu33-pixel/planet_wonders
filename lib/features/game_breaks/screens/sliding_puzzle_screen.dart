import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/sliding_puzzle_registry.dart';
import '../models/puzzle_state.dart';
import '../painters/puzzle_painters.dart';
import '../providers/sliding_puzzle_provider.dart';
import '../widgets/game_break_end_card.dart';
import '../widgets/puzzle_reference_image.dart';
import '../widgets/puzzle_tile_widget.dart';

/// Full-screen 3×3 sliding tile puzzle.
///
/// Tap a tile next to the empty space to slide it. Complete the image
/// to win. Move counter and timer track progress — no pressure, just fun.
class SlidingPuzzleScreen extends ConsumerStatefulWidget {
  const SlidingPuzzleScreen({super.key, required this.countryId});

  final String countryId;

  @override
  ConsumerState<SlidingPuzzleScreen> createState() =>
      _SlidingPuzzleScreenState();
}

class _SlidingPuzzleScreenState extends ConsumerState<SlidingPuzzleScreen> {
  bool _endShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(slidingPuzzleProvider.notifier).setup(widget.countryId);
    });
  }

  Future<void> _showEndAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    showGameBreakEndCard(context);
  }

  String get _countryLabel {
    final country = findCountryById(widget.countryId);
    return country?.name ??
        (widget.countryId[0].toUpperCase() + widget.countryId.substring(1));
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final puzzleState = ref.watch(slidingPuzzleProvider);
    final data =
        findSlidingPuzzleData(widget.countryId) ?? fallbackSlidingPuzzle;

    // Show end card once on completion.
    if (puzzleState.completed && !_endShown) {
      _endShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEndAfterDelay();
      });
    }

    return Scaffold(
      backgroundColor: data.bgColor,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ── Top bar ──
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  ),
                  Expanded(
                    child: Text(
                      '$_countryLabel \u{00B7} Sliding Puzzle',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // balance the back button
                ],
              ),

              const SizedBox(height: 12),

              // ── Stats row ──
              _StatsRow(
                moveCount: puzzleState.moveCount,
                elapsedSeconds: puzzleState.elapsedSeconds,
                formatTime: _formatTime,
                painter: puzzleState.painter,
                imagePath: puzzleState.imagePath,
                imageLabel: puzzleState.imageLabel,
              ),

              const SizedBox(height: 16),

              // ── Puzzle grid ──
              Expanded(
                child: puzzleState.tiles.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _PuzzleGrid(
                        puzzleState: puzzleState,
                        onTileTap: (index) => ref
                            .read(slidingPuzzleProvider.notifier)
                            .tapTile(index),
                      ),
              ),

              // ── History fact ──
              if (puzzleState.historyFact != null) ...[
                const SizedBox(height: 8),
                _HistoryFactCard(fact: puzzleState.historyFact!),
              ],

              const SizedBox(height: 8),

              // ── Reset button ──
              if (!puzzleState.completed && puzzleState.tiles.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      ref.read(slidingPuzzleProvider.notifier).reset(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Shuffle Again'),
                  style: TextButton.styleFrom(
                    foregroundColor: PWColors.navy.withValues(alpha: 0.6),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.moveCount,
    required this.elapsedSeconds,
    required this.formatTime,
    required this.painter,
    required this.imagePath,
    required this.imageLabel,
  });

  final int moveCount;
  final int elapsedSeconds;
  final String Function(int) formatTime;
  final PuzzlePainter? painter;
  final String? imagePath;
  final String? imageLabel;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: PWColors.navy.withValues(alpha: 0.5),
          fontSize: 11,
        );
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        );

    final hasImage = painter != null || imagePath != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Moves
        Column(
          children: [
            Text('$moveCount', style: valueStyle),
            Text('Moves', style: labelStyle),
          ],
        ),

        const SizedBox(width: 24),

        // Timer
        Column(
          children: [
            Text(formatTime(elapsedSeconds), style: valueStyle),
            Text('Time', style: labelStyle),
          ],
        ),

        const SizedBox(width: 24),

        // Reference image
        if (hasImage) ...[
          Column(
            children: [
              PuzzleReferenceImage(
                painter: painter,
                imagePath: imagePath,
                size: 56,
              ),
              const SizedBox(height: 2),
              Text(imageLabel ?? 'Goal', style: labelStyle),
            ],
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Puzzle grid
// ---------------------------------------------------------------------------

class _PuzzleGrid extends StatelessWidget {
  const _PuzzleGrid({
    required this.puzzleState,
    required this.onTileTap,
  });

  final SlidingPuzzleState puzzleState;
  final ValueChanged<int> onTileTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        // Cap at 400 for very large screens.
        final gridSide = maxSide.clamp(0.0, 400.0);
        const spacing = 4.0;
        final tileSize =
            (gridSide - (puzzleState.gridSize - 1) * spacing) /
                puzzleState.gridSize;

        return Center(
          child: SizedBox(
            width: gridSide,
            height: gridSide,
            child: Stack(
              children: [
                for (final tile in puzzleState.tiles)
                  if (!tile.isEmpty)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      left: (tile.currentIndex % puzzleState.gridSize) *
                          (tileSize + spacing),
                      top: (tile.currentIndex ~/ puzzleState.gridSize) *
                          (tileSize + spacing),
                      child: PuzzleTileWidget(
                        correctIndex: tile.correctIndex,
                        gridSize: puzzleState.gridSize,
                        painter: puzzleState.painter,
                        imagePath: puzzleState.imagePath,
                        tileSize: tileSize,
                        isCorrect: tile.isInCorrectPosition,
                        onTap: () => onTileTap(tile.currentIndex),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// History fact card
// ---------------------------------------------------------------------------

class _HistoryFactCard extends StatelessWidget {
  const _HistoryFactCard({required this.fact});

  final String fact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: PWColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.auto_stories_rounded, size: 18, color: PWColors.coral),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fact,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PWColors.navy.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
