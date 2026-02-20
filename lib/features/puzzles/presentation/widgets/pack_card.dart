import 'package:flutter/material.dart';

import '../../data/puzzle_models.dart';
import 'progress_badge.dart';
import 'star_row.dart';

class PackCard extends StatelessWidget {
  const PackCard({
    super.key,
    required this.pack,
    required this.summary,
    required this.onTap,
  });

  final PuzzlePack pack;
  final PackProgressSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${pack.title} pack',
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF9E8), Color(0xFFE8F1FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFD6E5FF), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    pack.thumbnailPath,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    cacheWidth: 256,
                    cacheHeight: 256,
                    filterQuality: FilterQuality.low,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 84,
                      height: 84,
                      color: const Color(0xFFFFD86A),
                      alignment: Alignment.center,
                      child: const Text('🧩', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pack.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF213A7E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      ProgressBadge(
                        completed: summary.completedCount,
                        total: summary.totalCount,
                      ),
                      const SizedBox(height: 8),
                      StarRow(
                        stars: (summary.totalStars / 6).round().clamp(0, 3),
                        mainAxisAlignment: MainAxisAlignment.start,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 28,
                  color: Color(0xFF3B5EC1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
