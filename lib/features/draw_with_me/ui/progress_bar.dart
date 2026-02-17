// File: lib/features/draw_with_me/ui/progress_bar.dart
import 'package:flutter/material.dart';

class TraceProgressBar extends StatelessWidget {
  const TraceProgressBar({
    super.key,
    required this.progress,
    required this.segmentText,
  });

  final double progress;
  final String segmentText;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Progress',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              '${(clamped * 100).round()}% · $segmentText',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4D6278),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 12,
            backgroundColor: const Color(0xFFE7EFF7),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF61C18E)),
          ),
        ),
      ],
    );
  }
}
