import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

class BedtimeLockCard extends StatelessWidget {
  const BedtimeLockCard({
    super.key,
    required this.enabled,
    required this.startHour,
    required this.endHour,
    required this.onToggle,
    required this.onChangeHours,
  });

  final bool enabled;
  final int startHour;
  final int endHour;
  final ValueChanged<bool> onToggle;
  final void Function(int start, int end) onChangeHours;

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

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
              const Icon(Icons.bedtime_rounded, size: 20, color: Color(0xFF7C4DFF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bedtime Lock',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary,
                  ),
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: onToggle,
                activeThumbColor: const Color(0xFF7C4DFF),
                activeTrackColor: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 8),
            Text(
              'App locks during bedtime hours',
              style: TextStyle(fontSize: 13, color: tc.textMuted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _HourChip(
                  label: 'Start',
                  hour: startHour,
                  formatted: _formatHour(startHour),
                  tc: tc,
                  onTap: () => _pickHour(context, isStart: true),
                ),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded,
                    size: 18, color: tc.textMuted),
                const SizedBox(width: 12),
                _HourChip(
                  label: 'End',
                  hour: endHour,
                  formatted: _formatHour(endHour),
                  tc: tc,
                  onTap: () => _pickHour(context, isStart: false),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickHour(BuildContext context, {required bool isStart}) async {
    final current = isStart ? startHour : endHour;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isStart) {
        onChangeHours(picked.hour, endHour);
      } else {
        onChangeHours(startHour, picked.hour);
      }
    }
  }
}

class _HourChip extends StatelessWidget {
  const _HourChip({
    required this.label,
    required this.hour,
    required this.formatted,
    required this.tc,
    required this.onTap,
  });

  final String label;
  final int hour;
  final String formatted;
  final PWThemeColors tc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: tc.textMuted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: tc.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatted,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
