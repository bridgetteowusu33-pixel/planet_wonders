import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/puzzle_providers.dart';
import 'widgets/pack_card.dart';

class PuzzleHomeScreen extends ConsumerWidget {
  const PuzzleHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsAsync = ref.watch(puzzlePacksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzles'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE7F5FF), Color(0xFFFFF4D8)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: packsAsync.when(
              data: (packs) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth >= 820;
                    final crossAxisCount = isTablet ? 2 : 1;

                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Build pictures, earn stars!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF1F3C82),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Choose a country pack and start solving.',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: const Color(0xFF48619B),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final pack = packs[index];
                            final summaryAsync = ref.watch(
                              packSummaryProvider(pack.id),
                            );

                            return summaryAsync.when(
                              data: (summary) => PackCard(
                                pack: pack,
                                summary: summary,
                                onTap: () => context.push(
                                  '/games/puzzles/pack/${pack.id}',
                                ),
                              ),
                              loading: () => const _PackSkeletonCard(),
                              error: (error, stack) =>
                                  const _PackSkeletonCard(),
                            );
                          }, childCount: packs.length),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: isTablet ? 2.5 : 2.15,
                              ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Could not load puzzle packs.',
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

class _PackSkeletonCard extends StatelessWidget {
  const _PackSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }
}
