import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/daily_usage_record.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    super.key,
    required this.today,
    required this.history,
  });

  final DailyUsageRecord today;
  final List<DailyUsageRecord> history;

  @override
  Widget build(BuildContext context) {
    final tc = PWThemeColors.of(context);
    final days = _buildWeekDays();
    final maxMinutes =
        days.map((d) => d.minutes).fold<int>(1, (a, b) => a > b ? a : b);

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
            'This Week',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: tc.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final barFraction =
                    maxMinutes > 0 ? day.minutes / maxMinutes : 0.0;
                return Expanded(
                  child: _DayBar(
                    label: day.label,
                    minutes: day.minutes,
                    fraction: barFraction,
                    isToday: day.isToday,
                    tc: tc,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<_DayData> _buildWeekDays() {
    final now = DateTime.now();
    final todayKey = DailyUsageRecord.todayKey();
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Build a map of dateKey → minutes for quick lookup
    final usageMap = <String, int>{};
    usageMap[today.dateKey] = today.totalMinutes;
    for (final record in history) {
      usageMap[record.dateKey] = record.totalMinutes;
    }

    // Generate 7 days ending with today
    final result = <_DayData>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final weekday = date.weekday; // 1=Mon, 7=Sun
      result.add(_DayData(
        label: dayLabels[weekday - 1],
        minutes: usageMap[key] ?? 0,
        isToday: key == todayKey,
      ));
    }
    return result;
  }
}

class _DayData {
  const _DayData({
    required this.label,
    required this.minutes,
    required this.isToday,
  });

  final String label;
  final int minutes;
  final bool isToday;
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.minutes,
    required this.fraction,
    required this.isToday,
    required this.tc,
  });

  final String label;
  final int minutes;
  final double fraction;
  final bool isToday;
  final PWThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final barColor = isToday ? PWColors.blue : PWColors.mint;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (minutes > 0)
            Text(
              '${minutes}m',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: tc.textMuted,
              ),
            ),
          const SizedBox(height: 4),
          Container(
            height: (fraction * 80).clamp(4.0, 80.0),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(6),
              border: isToday
                  ? Border.all(color: PWColors.navy.withValues(alpha: 0.3), width: 1.5)
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? tc.textPrimary : tc.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
