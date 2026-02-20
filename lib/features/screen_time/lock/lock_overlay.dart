import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/theme/pw_theme.dart';
import '../providers/screen_time_settings_provider.dart';
import '../providers/usage_tracker_provider.dart';
import '../widgets/pin_dialog.dart';

enum LockReason { dailyLimit, bedtime }

class LockOverlay extends ConsumerWidget {
  const LockOverlay({super.key, required this.reason});

  final LockReason reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(screenTimeSettingsProvider);
    final tracker = ref.watch(usageTrackerProvider);
    final tc = PWThemeColors.of(context);

    final isBedtime = reason == LockReason.bedtime;
    final emoji = isBedtime ? '🌙' : '☀️';
    final title = isBedtime ? "It's Sleepy Time!" : 'Great Job Today!';
    final message = isBedtime
        ? 'The stars are out and it\'s time to rest.\nSweet dreams!'
        : 'You played for ${tracker.today.totalMinutes} minutes today.\nTime to take a break!';

    final bgGradient = isBedtime
        ? const [Color(0xFF1A1A4E), Color(0xFF2D1B69)]
        : const [Color(0xFFFFF3E0), Color(0xFFFFE0B2)];

    final textColor = isBedtime ? Colors.white : tc.textPrimary;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),

                  // Decorative stars for bedtime
                  if (isBedtime)
                    const Text(
                      '✨  ⭐  ✨',
                      style: TextStyle(fontSize: 28),
                    ),
                  if (isBedtime) const SizedBox(height: 16),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isBedtime
                          ? Colors.white.withValues(alpha: 0.8)
                          : tc.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (settings.hasPin)
                    FilledButton.icon(
                      onPressed: () => _unlockWithPin(context, ref),
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Ask a Grown-Up'),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            isBedtime ? PWColors.blue : PWColors.mint,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(220, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: (isBedtime ? Colors.white : PWColors.navy)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        isBedtime
                            ? 'Come back in the morning!'
                            : 'Come back tomorrow!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlockWithPin(BuildContext context, WidgetRef ref) async {
    // The LockOverlay lives above the Navigator (in MaterialApp.builder),
    // so its own context cannot host dialogs. Use the root navigator's
    // context instead.
    final navContext =
        PlanetWondersApp.rootNavigatorKey.currentContext;
    if (navContext == null) return;

    final verified = await showPinDialog(
      context: navContext,
      mode: PinMode.verify,
      onVerify: (pin) =>
          ref.read(screenTimeSettingsProvider.notifier).verifyPin(pin),
      onSet: (_) {},
    );

    if (verified && context.mounted) {
      ref.read(usageTrackerProvider.notifier).temporaryUnlock();
    }
  }
}
