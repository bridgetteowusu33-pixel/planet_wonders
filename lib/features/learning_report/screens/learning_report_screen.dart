import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/pw_theme.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../models/learning_stats.dart';
import '../providers/learning_stats_provider.dart';
import '../widgets/badge_item.dart';
import '../widgets/skill_bar.dart';
import '../widgets/summary_card.dart';
import '../widgets/timeline_item.dart';

class LearningReportScreen extends ConsumerStatefulWidget {
  const LearningReportScreen({super.key});

  @override
  ConsumerState<LearningReportScreen> createState() =>
      _LearningReportScreenState();
}

class _LearningReportScreenState extends ConsumerState<LearningReportScreen> {
  ReportPeriod _period = ReportPeriod.allTime;

  // ── Period filtering ─────────────────────────────────────────────────────

  List<ActivityLogEntry> _filterByPeriod(List<ActivityLogEntry> entries) {
    if (_period == ReportPeriod.allTime) return entries;

    final now = DateTime.now();
    final cutoff = switch (_period) {
      ReportPeriod.today => DateTime(now.year, now.month, now.day),
      ReportPeriod.week => now.subtract(const Duration(days: 7)),
      ReportPeriod.month => now.subtract(const Duration(days: 30)),
      ReportPeriod.allTime => DateTime(2000),
    };

    return entries
        .where((e) => e.timestamp.isAfter(cutoff))
        .toList(growable: false);
  }

  List<SkillScore> _skillsFromEntries(List<ActivityLogEntry> entries) {
    final points = <SkillType, int>{};
    for (final entry in entries) {
      for (final kv in skillPointsFor(entry.type).entries) {
        points[kv.key] = (points[kv.key] ?? 0) + kv.value;
      }
    }
    final maxPoints = (entries.length * 2).clamp(1, 1 << 30);
    return SkillType.values.map((type) {
      final raw = (points[type] ?? 0) / maxPoints;
      return buildSkillScore(type, raw);
    }).toList(growable: false);
  }

  // ── Parent tips ──────────────────────────────────────────────────────────

  String _parentTip(List<ActivityLogEntry> entries) {
    if (entries.isEmpty) {
      return 'Start with World Explorer to begin the learning journey!';
    }

    final counts = <ActivityType, int>{};
    for (final e in entries) {
      counts[e.type] = (counts[e.type] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first.key;

    // Find least-used category to suggest
    final all = ActivityType.values.where((t) => t != ActivityType.game);
    final least = all.reduce(
      (a, b) => (counts[a] ?? 0) <= (counts[b] ?? 0) ? a : b,
    );

    final topLabel = _activityLabel(top);
    final leastLabel = _activityLabel(least);

    if (top == least) {
      return 'Great start! Keep exploring different activities to build all skills.';
    }

    return 'Your child loves $topLabel! Try $leastLabel to build new skills.';
  }

  String _activityLabel(ActivityType type) {
    switch (type) {
      case ActivityType.story:
        return 'reading stories';
      case ActivityType.coloring:
        return 'coloring pages';
      case ActivityType.cooking:
        return 'cooking activities';
      case ActivityType.drawing:
        return 'creative drawing';
      case ActivityType.fashion:
        return 'fashion design';
      case ActivityType.game:
        return 'games';
    }
  }

  // ── Timeline grouping ───────────────────────────────────────────────────

  List<Widget> _buildTimeline(List<ActivityLogEntry> entries) {
    if (entries.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No activities yet \u2014 start exploring!',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PWThemeColors.of(context).textMuted,
              ),
            ),
          ),
        ),
      ];
    }

    final widgets = <Widget>[];
    String? lastDateKey;

    for (final entry in entries) {
      final dateKey = _dateGroupLabel(entry.timestamp);
      if (dateKey != lastDateKey) {
        lastDateKey = dateKey;
        widgets.add(TimelineDateHeader(label: dateKey));
      }
      widgets.add(TimelineItem(entry: entry));
    }

    return widgets;
  }

  String _dateGroupLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(dt.year, dt.month, dt.day);

    if (entryDay == today) return 'Today';
    if (entryDay == today.subtract(const Duration(days: 1))) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(learningStatsProvider);
    final achievementState = ref.watch(achievementProvider);

    final filtered = _filterByPeriod(stats.recentActivities);
    final filteredSkills = _skillsFromEntries(filtered);
    final filteredCount = filtered.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
        title: Text(
          'Learning Report',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: PWThemeColors.of(context).textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: stats.loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ── Period selector ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: _PeriodSelector(
                      selected: _period,
                      onChanged: (p) => setState(() => _period = p),
                    ),
                  ),
                ),

                // ── Summary cards ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RepaintBoundary(
                      child: Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              emoji: '\u{2705}', // ✅
                              value: '$filteredCount',
                              label: 'Activities\nCompleted',
                              color: PWColors.mint,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SummaryCard(
                              emoji: '\u{1F30D}', // 🌍
                              value: '${stats.countriesExplored}',
                              label: 'Countries\nExplored',
                              color: PWColors.blue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SummaryCard(
                              emoji: '\u{1F3C6}', // 🏆
                              value: '${stats.badgesEarned}',
                              label: 'Badges\nEarned',
                              color: PWColors.yellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Skills Progress ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RepaintBoundary(
                      child: _SectionCard(
                        title: 'Skills Progress',
                        emoji: '\u{1F4CA}', // 📊
                        child: Column(
                          children: [
                            for (final skill in filteredSkills)
                              SkillBar(skill: skill),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Achievements ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RepaintBoundary(
                      child: _SectionCard(
                        title: 'Achievements',
                        emoji: '\u{1F3C6}', // 🏆
                        child: achievementState.unlockedCount == 0
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Complete activities to earn badges!',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: PWThemeColors.of(context).textMuted,
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 44,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      achievementState.unlockedAchievements
                                          .length,
                                  itemBuilder: (context, index) {
                                    final badge = achievementState
                                        .unlockedAchievements[index];
                                    return BadgeItem(
                                      iconPath: badge.iconPath,
                                      title: badge.title,
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Recent Activity ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: _SectionCard(
                      title: 'Recent Activity',
                      emoji: '\u{1F4C5}', // 📅
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildTimeline(
                          filtered.take(20).toList(),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Parent Tips ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _TipCard(tip: _parentTip(filtered)),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Export (placeholder) ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showComingSoon(context),
                            icon: const Icon(Icons.picture_as_pdf_rounded,
                                size: 18),
                            label: const Text('Download PDF'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showComingSoon(context),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Period selector chips
// ---------------------------------------------------------------------------

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onChanged;

  static const _labels = {
    ReportPeriod.today: 'Today',
    ReportPeriod.week: 'Week',
    ReportPeriod.month: 'Month',
    ReportPeriod.allTime: 'All Time',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final period in ReportPeriod.values) ...[
          if (period != ReportPeriod.values.first) const SizedBox(width: 8),
          _PeriodChip(
            label: _labels[period]!,
            isSelected: period == selected,
            onTap: () => onChanged(period),
          ),
        ],
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? PWColors.blue
              : PWThemeColors.of(context).textMuted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : PWThemeColors.of(context).textMuted,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section card wrapper
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.emoji,
    required this.child,
  });

  final String title;
  final String emoji;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tc = PWThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: tc.shadowColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tc.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Parent tip card
// ---------------------------------------------------------------------------

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PWColors.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PWColors.mint.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('\u{1F4A1}', style: TextStyle(fontSize: 22)), // 💡
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent Tip',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: PWThemeColors.of(context).textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PWThemeColors.of(context).textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
