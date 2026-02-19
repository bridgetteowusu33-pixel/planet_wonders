import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../domain/recipe_album_entry.dart';
import '../providers/recipe_album_provider.dart';

/// "My Recipe Book" — displays all completed recipes with stars,
/// earned badges, play count, and a replay button.
class RecipeAlbumScreen extends ConsumerWidget {
  const RecipeAlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumState = ref.watch(recipeAlbumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Recipe Book',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: albumState.loading
            ? const Center(child: CircularProgressIndicator())
            : albumState.entries.isEmpty
            ? _EmptyState()
            : _AlbumContent(entries: albumState.entries),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state — no recipes completed yet
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '\u{1F4D6}', // 📖
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              'Your recipe book is empty!',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a recipe story to add it here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: PWColors.navy.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Album content — header stats + list of entries
// ---------------------------------------------------------------------------

class _AlbumContent extends StatelessWidget {
  const _AlbumContent({required this.entries});

  final List<RecipeAlbumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final totalRewards = entries.fold<int>(
      0,
      (sum, e) => sum + e.earnedRewards.length,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Stats header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  PWColors.coral.withValues(alpha: 0.18),
                  PWColors.yellow.withValues(alpha: 0.22),
                  PWColors.mint.withValues(alpha: 0.18),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '\u{1F468}\u{200D}\u{1F373}',
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Recipe Collection',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entries.length} ${entries.length == 1 ? 'recipe' : 'recipes'} \u{00B7} $totalRewards badges earned',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PWColors.navy.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Recipe entries
          Expanded(
            child: ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (context, index) {
                return _AlbumEntryCard(entry: entries[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual album entry card
// ---------------------------------------------------------------------------

class _AlbumEntryCard extends StatelessWidget {
  const _AlbumEntryCard({required this.entry});

  final RecipeAlbumEntry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to replay the recipe story.
        context.push('/recipe-story/${entry.countryId}/${entry.recipeId}');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: PWColors.yellow.withValues(alpha: 0.25),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: emoji + title + stars
            Row(
              children: [
                // Recipe emoji
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        PWColors.coral.withValues(alpha: 0.15),
                        PWColors.yellow.withValues(alpha: 0.15),
                      ],
                    ),
                    border: Border.all(
                      color: PWColors.coral.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      entry.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _countryLabel(entry.countryId),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: PWColors.navy.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (entry.playCount > 1) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: PWColors.blue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${entry.playCount}x',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: PWColors.blue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Stars
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final filled = i < entry.stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 22,
                        color: filled
                            ? PWColors.yellow
                            : PWColors.navy.withValues(alpha: 0.2),
                      ),
                    );
                  }),
                ),
              ],
            ),
            // Badge row (if any rewards earned)
            if (entry.earnedRewards.isNotEmpty) ...[
              const SizedBox(height: 10),
              // Badge title + reward chips
              Row(
                children: [
                  if (entry.badgeTitle != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: PWColors.mint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: PWColors.mint.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '\u{1F9D1}\u{200D}\u{1F373}',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.badgeTitle!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: PWColors.mint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: entry.earnedRewards.map((reward) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: PWColors.yellow.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: PWColors.yellow.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    reward.emoji,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    reward.title,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            // Replay button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push(
                    '/recipe-story/${entry.countryId}/${entry.recipeId}',
                  );
                },
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('Cook Again'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  foregroundColor: PWColors.coral,
                  side: BorderSide(
                    color: PWColors.coral.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _countryLabel(String countryId) {
    return countryId
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
