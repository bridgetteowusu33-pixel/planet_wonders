import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/puzzle_models.dart';
import '../providers/puzzle_providers.dart';
import 'widgets/puzzle_tile.dart';

class PuzzlePackScreen extends ConsumerStatefulWidget {
  const PuzzlePackScreen({super.key, required this.packId});

  final String packId;

  @override
  ConsumerState<PuzzlePackScreen> createState() => _PuzzlePackScreenState();
}

class _PuzzlePackScreenState extends ConsumerState<PuzzlePackScreen> {
  PuzzleDifficulty? _filter;

  @override
  Widget build(BuildContext context) {
    final packAsync = ref.watch(puzzlePackProvider(widget.packId));
    final progressAsync = ref.watch(puzzleProgressMapProvider);
    final unlockedAsync = ref.watch(unlockedPuzzleIdsProvider(widget.packId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Levels'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F4FF), Color(0xFFFFF3D9)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: packAsync.when(
              data: (pack) {
                if (pack == null) {
                  return const Center(child: Text('Pack not found'));
                }

                final progress =
                    progressAsync.value ??
                    const <String, PuzzleProgress>{};
                final unlocked = unlockedAsync.value ?? const <String>{};

                final puzzles = pack.puzzles
                    .where((p) => _filter == null || p.difficulty == _filter)
                    .toList(growable: false);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final maxExtent = constraints.maxWidth >= 1024
                        ? 190.0
                        : constraints.maxWidth >= 820
                        ? 210.0
                        : 220.0;

                    return Column(
                      children: [
                        _PackHeader(pack: pack),
                        const SizedBox(height: 10),
                        _DifficultyFilters(
                          selected: _filter,
                          onSelected: (value) {
                            setState(() => _filter = value);
                          },
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: GridView.builder(
                            itemCount: puzzles.length,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: maxExtent,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.83,
                                ),
                            itemBuilder: (context, index) {
                              final puzzle = puzzles[index];
                              final isLocked = !unlocked.contains(puzzle.id);
                              return PuzzleTile(
                                puzzle: puzzle,
                                progress: progress[puzzle.id],
                                locked: isLocked,
                                onTap: () {
                                  context.push(
                                    '/games/puzzles/play/${puzzle.id}?packId=${pack.id}',
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Could not load levels.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PackHeader extends StatelessWidget {
  const _PackHeader({required this.pack});

  final PuzzlePack pack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFEAF3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFC9DCFF), width: 2),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              pack.thumbnailPath,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              cacheWidth: 256,
              cacheHeight: 256,
              filterQuality: FilterQuality.low,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 72,
                color: const Color(0xFFFFD86A),
                alignment: Alignment.center,
                child: const Text('🧩', style: TextStyle(fontSize: 30)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_countryFlag(pack.countryCode)} ${pack.title}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF1C376E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pick a level and start building.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4B6191),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _countryFlag(String countryCode) {
    final code = countryCode.toUpperCase();
    if (code.length != 2) return '🌍';
    return String.fromCharCodes(
      code.codeUnits.map((unit) => 0x1F1E6 + unit - 65),
    );
  }
}

class _DifficultyFilters extends StatelessWidget {
  const _DifficultyFilters({required this.selected, required this.onSelected});

  final PuzzleDifficulty? selected;
  final ValueChanged<PuzzleDifficulty?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Easy',
            selected: selected == PuzzleDifficulty.easy,
            onTap: () => onSelected(PuzzleDifficulty.easy),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Medium',
            selected: selected == PuzzleDifficulty.medium,
            onTap: () => onSelected(PuzzleDifficulty.medium),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Hard',
            selected: selected == PuzzleDifficulty.hard,
            onTap: () => onSelected(PuzzleDifficulty.hard),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? const Color(0xFF2E68E8) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF2E68E8) : const Color(0xFFCFD7EA),
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? Colors.white : const Color(0xFF4D608A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
