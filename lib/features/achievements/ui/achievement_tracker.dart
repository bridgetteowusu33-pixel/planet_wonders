import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../providers/achievement_provider.dart';

class AchievementTrackerScreen extends ConsumerWidget {
  const AchievementTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: state.loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _ProgressSummary(
                      unlocked: state.unlockedCount,
                      total: state.totalCount,
                      score: state.unlockedScore,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.definitions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final achievement = state.definitions[index];
                          final unlocked =
                              state.unlockedIds.contains(achievement.id);
                          return _AchievementTile(
                            title: achievement.title,
                            description: achievement.description,
                            iconPath: achievement.iconPath,
                            unlocked: unlocked,
                            score: achievement.score,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.unlocked,
    required this.total,
    required this.score,
  });

  final int unlocked;
  final int total;
  final int score;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : unlocked / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            PWColors.yellow.withValues(alpha: 0.3),
            PWColors.mint.withValues(alpha: 0.26),
            PWColors.blue.withValues(alpha: 0.22),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Unlocked $unlocked of $total badges',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: PWColors.navy.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(PWColors.mint),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: $score',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PWColors.navy,
                ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.title,
    required this.description,
    required this.iconPath,
    required this.unlocked,
    required this.score,
  });

  final String title;
  final String description;
  final String iconPath;
  final bool unlocked;
  final int score;

  @override
  Widget build(BuildContext context) {
    final cardColor = unlocked ? Colors.white : const Color(0xFFF2F4F7);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: unlocked ? 1.0 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked
                ? PWColors.mint.withValues(alpha: 0.55)
                : PWColors.navy.withValues(alpha: 0.12),
            width: 1.7,
          ),
          boxShadow: [
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: unlocked
                    ? PWColors.yellow.withValues(alpha: 0.16)
                    : PWColors.navy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    unlocked ? Icons.emoji_events_rounded : Icons.lock_rounded,
                    color: unlocked ? PWColors.yellow : PWColors.navy,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      Text(
                        '+$score',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: unlocked
                                  ? PWColors.mint
                                  : PWColors.navy.withValues(alpha: 0.45),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PWColors.navy.withValues(alpha: 0.76),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
