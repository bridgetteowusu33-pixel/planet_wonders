import 'package:flutter/material.dart';

class ProgressBadge extends StatelessWidget {
  const ProgressBadge({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3D2A5), width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.map_rounded, size: 15, color: Color(0xFF775B24)),
          const SizedBox(width: 6),
          Text(
            '$completed/$total · ${(ratio * 100).round()}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF5E4A1D),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
