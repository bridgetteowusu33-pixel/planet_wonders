import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

/// Shows a gentle "Want a quick game break?" dialog.
///
/// [gameName] is displayed on the preview card (e.g. "Memory Match").
/// [gameEmoji] is the preview emoji (e.g. "🃏").
/// [onPlay] fires when the kid taps "Play".
/// [onDismiss] fires when the kid taps "Not now" or taps outside.
Future<void> showGameBreakPrompt(
  BuildContext context, {
  required String gameName,
  String gameEmoji = '\u{1F3B4}', // 🃴
  required VoidCallback onPlay,
  required VoidCallback onDismiss,
}) async {
  // result is true when "Play" is pressed, null on barrier tap or "Not now".
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: const EdgeInsets.all(28),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Controller emoji
          const Text(
            '\u{1F3AE}', // 🎮
            style: TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 12),

          Text(
            'Want a quick game break?',
            style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          Text(
            'Just a short, fun game!',
            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: PWColors.navy.withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Game preview card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: PWColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PWColors.blue.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(gameEmoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(
                  gameName,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Play button
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: PWColors.mint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Play'),
          ),
          const SizedBox(height: 8),

          // Not now button
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Not now',
              style: TextStyle(
                color: PWColors.navy.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // Dialog is fully closed at this point — safe to navigate.
  if (result == true) {
    onPlay();
  } else {
    onDismiss();
  }
}
