import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/daily_usage_record.dart';

class ActivityBreakdownCard extends StatelessWidget {
  const ActivityBreakdownCard({super.key, required this.seconds});

  final CategoryMinutes seconds;

  static const _categories = [
    _CategoryInfo('stories', 'Stories', Icons.auto_stories_rounded, PWColors.coral),
    _CategoryInfo('coloring', 'Coloring', Icons.palette_rounded, PWColors.blue),
    _CategoryInfo('cooking', 'Cooking', Icons.restaurant_rounded, PWColors.yellow),
    _CategoryInfo('fashion', 'Fashion', Icons.checkroom_rounded, Color(0xFF9C27B0)),
    _CategoryInfo('worldExplorer', 'Explorer', Icons.public_rounded, PWColors.mint),
    _CategoryInfo('other', 'Other', Icons.apps_rounded, Color(0xFF78909C)),
  ];

  @override
  Widget build(BuildContext context) {
    final tc = PWThemeColors.of(context);
    final totalSeconds = seconds.total;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Activity Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: tc.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          if (totalSeconds == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No activity recorded yet today.',
                style: TextStyle(
                  fontSize: 14,
                  color: tc.textMuted,
                ),
              ),
            )
          else
            ..._categories.map((cat) {
              final catSeconds = seconds.secondsFor(cat.key);
              if (catSeconds == 0) return const SizedBox.shrink();
              final minutes = catSeconds ~/ 60;
              final fraction = totalSeconds > 0 ? catSeconds / totalSeconds : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(cat.icon, size: 20, color: cat.color),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 65,
                      child: Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: tc.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: tc.textMuted.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: fraction,
                          child: Container(
                            decoration: BoxDecoration(
                              color: cat.color,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${minutes}m',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tc.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _CategoryInfo {
  const _CategoryInfo(this.key, this.label, this.icon, this.color);

  final String key;
  final String label;
  final IconData icon;
  final Color color;
}
