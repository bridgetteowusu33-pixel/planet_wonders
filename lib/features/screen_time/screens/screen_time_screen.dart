import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/screen_time_settings.dart';
import '../providers/screen_time_settings_provider.dart';
import '../providers/usage_tracker_provider.dart';
import '../widgets/activity_breakdown_card.dart';
import '../widgets/bedtime_lock_card.dart';
import '../widgets/daily_limit_picker.dart';
import '../widgets/pin_dialog.dart';
import '../widgets/usage_progress_card.dart';
import '../widgets/weekly_chart.dart';

class ScreenTimeScreen extends ConsumerWidget {
  const ScreenTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(screenTimeSettingsProvider);
    final tracker = ref.watch(usageTrackerProvider);
    final tc = PWThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(
        title: Text(
          'Screen Time',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: tc.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: tc.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // 1. Today's usage progress
          UsageProgressCard(
            usedMinutes: tracker.today.totalMinutes,
            limitMinutes: settings.dailyLimitMinutes,
          ),
          const SizedBox(height: 16),

          // 2. Weekly chart
          WeeklyChart(
            today: tracker.today,
            history: tracker.weekHistory,
          ),
          const SizedBox(height: 16),

          // 3. Activity breakdown
          ActivityBreakdownCard(seconds: tracker.today.seconds),
          const SizedBox(height: 16),

          // 4. Daily limit picker
          DailyLimitPicker(
            currentLimit: settings.dailyLimitMinutes,
            onChanged: (minutes) {
              ref
                  .read(screenTimeSettingsProvider.notifier)
                  .setDailyLimit(minutes);
            },
          ),
          const SizedBox(height: 16),

          // 5. Bedtime lock
          BedtimeLockCard(
            enabled: settings.bedtimeLockEnabled,
            startHour: settings.bedtimeLockStartHour,
            endHour: settings.bedtimeLockEndHour,
            onToggle: (enabled) {
              ref
                  .read(screenTimeSettingsProvider.notifier)
                  .setBedtimeLockEnabled(enabled);
            },
            onChangeHours: (start, end) {
              ref
                  .read(screenTimeSettingsProvider.notifier)
                  .setBedtimeLockHours(startHour: start, endHour: end);
            },
          ),
          const SizedBox(height: 16),

          // 6. PIN management
          _PinCard(settings: settings, tc: tc),
        ],
      ),
    );
  }
}

class _PinCard extends ConsumerWidget {
  const _PinCard({required this.settings, required this.tc});

  final ScreenTimeSettings settings;
  final PWThemeColors tc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPin = settings.hasPin;

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
              Icon(
                hasPin ? Icons.lock_rounded : Icons.lock_open_rounded,
                size: 20,
                color: PWColors.coral,
              ),
              const SizedBox(width: 8),
              Text(
                'Parent PIN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tc.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasPin
                ? 'PIN is set. Kids must enter PIN to change settings or dismiss lock.'
                : 'No PIN set. Anyone can change settings.',
            style: TextStyle(fontSize: 13, color: tc.textMuted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (!hasPin)
                FilledButton(
                  onPressed: () => _setPin(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: PWColors.coral,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Set PIN'),
                )
              else ...[
                FilledButton(
                  onPressed: () => _changePin(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: PWColors.coral,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Change PIN'),
                ),
                OutlinedButton(
                  onPressed: () => _removePin(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tc.textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Remove'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setPin(BuildContext context, WidgetRef ref) async {
    await showPinDialog(
      context: context,
      mode: PinMode.set,
      onVerify: (_) => true,
      onSet: (pin) {
        ref.read(screenTimeSettingsProvider.notifier).setPin(pin);
      },
    );
  }

  Future<void> _changePin(BuildContext context, WidgetRef ref) async {
    // First verify old PIN
    final verified = await showPinDialog(
      context: context,
      mode: PinMode.verify,
      onVerify: (pin) =>
          ref.read(screenTimeSettingsProvider.notifier).verifyPin(pin),
      onSet: (_) {},
    );
    if (!verified || !context.mounted) return;

    // Then set new PIN
    await showPinDialog(
      context: context,
      mode: PinMode.set,
      onVerify: (_) => true,
      onSet: (pin) {
        ref.read(screenTimeSettingsProvider.notifier).setPin(pin);
      },
    );
  }

  Future<void> _removePin(BuildContext context, WidgetRef ref) async {
    final verified = await showPinDialog(
      context: context,
      mode: PinMode.verify,
      onVerify: (pin) =>
          ref.read(screenTimeSettingsProvider.notifier).verifyPin(pin),
      onSet: (_) {},
    );
    if (verified) {
      ref.read(screenTimeSettingsProvider.notifier).clearPin();
    }
  }
}
