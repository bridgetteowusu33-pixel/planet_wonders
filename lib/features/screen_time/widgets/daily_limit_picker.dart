import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

class DailyLimitPicker extends StatelessWidget {
  const DailyLimitPicker({
    super.key,
    required this.currentLimit,
    required this.onChanged,
  });

  /// Current limit in minutes (0 = unlimited).
  final int currentLimit;
  final ValueChanged<int> onChanged;

  static const _options = [
    _LimitOption(30, '30 min'),
    _LimitOption(45, '45 min'),
    _LimitOption(60, '1 hour'),
    _LimitOption(90, '1.5 hours'),
    _LimitOption(120, '2 hours'),
    _LimitOption(0, 'Unlimited'),
  ];

  @override
  Widget build(BuildContext context) {
    final tc = PWThemeColors.of(context);

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
          Row(
            children: [
              const Icon(Icons.timer_rounded, size: 20, color: PWColors.blue),
              const SizedBox(width: 8),
              Text(
                'Daily Limit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tc.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((opt) {
              final selected = opt.minutes == currentLimit;
              return GestureDetector(
                onTap: () => onChanged(opt.minutes),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? PWColors.mint
                        : tc.textMuted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: selected
                        ? Border.all(
                            color: PWColors.mint.withValues(alpha: 0.6),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? Colors.white : tc.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LimitOption {
  const _LimitOption(this.minutes, this.label);

  final int minutes;
  final String label;
}
