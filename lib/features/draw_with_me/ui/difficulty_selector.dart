// File: lib/features/draw_with_me/ui/difficulty_selector.dart
import 'package:flutter/material.dart';

import '../models/trace_shape.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final TraceDifficulty value;
  final ValueChanged<TraceDifficulty> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final chips = [
      _DifficultyChipData(
        label: 'Easy',
        icon: Icons.sentiment_satisfied_alt_rounded,
        difficulty: TraceDifficulty.easy,
        color: const Color(0xFF9BD27A),
      ),
      _DifficultyChipData(
        label: 'Medium',
        icon: Icons.auto_awesome_rounded,
        difficulty: TraceDifficulty.medium,
        color: const Color(0xFFF5C45A),
      ),
      _DifficultyChipData(
        label: 'Hard',
        icon: Icons.whatshot_rounded,
        difficulty: TraceDifficulty.hard,
        color: const Color(0xFFF28D86),
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final chip in chips)
          ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(chip.icon, size: compact ? 15 : 17),
                const SizedBox(width: 6),
                Text(chip.label),
              ],
            ),
            selected: value == chip.difficulty,
            showCheckmark: false,
            backgroundColor: chip.color.withValues(alpha: 0.28),
            selectedColor: chip.color,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: compact ? 12 : 13,
              color: const Color(0xFF2F3A4A),
            ),
            onSelected: (_) => onChanged(chip.difficulty),
          ),
      ],
    );
  }
}

class _DifficultyChipData {
  const _DifficultyChipData({
    required this.label,
    required this.icon,
    required this.difficulty,
    required this.color,
  });

  final String label;
  final IconData icon;
  final TraceDifficulty difficulty;
  final Color color;
}
