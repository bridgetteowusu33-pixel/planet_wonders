import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';

/// Shows a calming "Nice break!" dialog when a game finishes.
///
/// "Continue Exploring" pops the dialog and the game screen.
/// "Take a break" navigates home.
Future<void> showGameBreakEndCard(BuildContext context) async {
  final navigator = Navigator.of(context);
  final router = GoRouter.of(context);

  // result is true for "Continue Exploring", false for "Take a break".
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: const EdgeInsets.all(32),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '\u{2728}', // ✨
            style: TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 12),

          Text(
            'Nice break!',
            style: Theme.of(ctx).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),

          Text(
            'You did great!',
            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: PWColors.navy.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 24),

          // Continue Exploring
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: PWColors.mint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Continue Exploring'),
          ),
          const SizedBox(height: 8),

          // Take a break
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Take a break',
              style: TextStyle(
                color: PWColors.navy.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // Dialog is fully closed — safe to navigate.
  if (result == true) {
    navigator.pop(); // pop game screen
  } else {
    router.go('/'); // go home
  }
}
