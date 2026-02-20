import 'package:flutter/material.dart';

import '../../data/puzzle_models.dart';
import 'star_row.dart';

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({
    super.key,
    required this.puzzle,
    required this.progress,
    required this.locked,
    required this.onTap,
  });

  final PuzzleItem puzzle;
  final PuzzleProgress? progress;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stars = progress?.stars ?? 0;

    return Semantics(
      button: !locked,
      label: locked
          ? '${puzzle.title}, locked'
          : '${puzzle.title}, $stars stars',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: locked ? null : onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFEFF5FF)],
            ),
            border: Border.all(
              color: locked ? const Color(0xFFD7DCE5) : const Color(0xFFB6D1FF),
              width: 1.6,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          puzzle.thumbnailPath,
                          fit: BoxFit.cover,
                          cacheWidth: 256,
                          cacheHeight: 256,
                          filterQuality: FilterQuality.low,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: const Color(0xFFFFD86A),
                                alignment: Alignment.center,
                                child: const Text(
                                  '🧩',
                                  style: TextStyle(fontSize: 30),
                                ),
                              ),
                        ),
                      ),
                      if (locked)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xB2000000),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  puzzle.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF253B73),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                StarRow(stars: stars, size: 16),
                const SizedBox(height: 2),
                Text(
                  locked
                      ? 'Complete previous puzzle'
                      : _bestTimeLabel(progress?.bestTimeMs),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: locked
                        ? const Color(0xFFDFE5F3)
                        : const Color(0xFF4A5E8E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _bestTimeLabel(int? bestTimeMs) {
    if (bestTimeMs == null || bestTimeMs <= 0) return 'Not completed';
    final totalSec = bestTimeMs ~/ 1000;
    final mins = totalSec ~/ 60;
    final sec = totalSec % 60;
    return 'Best $mins:${sec.toString().padLeft(2, '0')}';
  }
}
