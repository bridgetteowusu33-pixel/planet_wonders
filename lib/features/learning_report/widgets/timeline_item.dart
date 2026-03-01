import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/pw_theme.dart';
import '../../world_explorer/data/world_data.dart';
import '../models/learning_stats.dart';

/// A single activity entry in the timeline list.
class TimelineItem extends StatelessWidget {
  const TimelineItem({super.key, required this.entry});

  final ActivityLogEntry entry;

  Color get _bgColor {
    switch (entry.type) {
      case ActivityType.story:
        return PWColors.blue;
      case ActivityType.coloring:
        return PWColors.coral;
      case ActivityType.cooking:
        return PWColors.yellow;
      case ActivityType.drawing:
        return PWColors.coral;
      case ActivityType.fashion:
        return PWColors.mint;
      case ActivityType.game:
        return const Color(0xFFAB7BF5);
    }
  }

  String get _timeAgo {
    final now = DateTime.now();
    final diff = now.difference(entry.timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final m = entry.timestamp.month;
    final d = entry.timestamp.day;
    return '${_monthNames[m - 1]} $d';
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bgColor.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(entry.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.label,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: PWThemeColors.of(context).textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.countryId.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _CountryTag(countryId: entry.countryId),
                    ],
                  ],
                ),
                Text(
                  _timeAgo,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
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

/// A date group header for the timeline.
class TimelineDateHeader extends StatelessWidget {
  const TimelineDateHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.fredoka(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: PWThemeColors.of(context).textMuted,
        ),
      ),
    );
  }
}

class _CountryTag extends StatelessWidget {
  const _CountryTag({required this.countryId});

  final String countryId;

  @override
  Widget build(BuildContext context) {
    final country = findCountryById(countryId);
    if (country == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: PWColors.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            country.flagEmoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            country.name,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: PWColors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
