import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../cooking_game/v2/widgets/chef_avatar.dart';
import '../models/suitcase_pack.dart';

/// Gentle "Time's Up" retry screen.
class PackRetryScreen extends StatelessWidget {
  const PackRetryScreen({
    super.key,
    required this.pack,
    required this.onRetry,
  });

  final SuitcasePack pack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 520 : 420),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Character avatar
                ChefAvatar(
                  countryId: pack.countryId,
                  size: isTablet ? 80 : 64,
                  mood: ChefAvatarMood.thinking,
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Time\u{2019}s Up! \u{23F0}', // ⏰
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PWColors.navy,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'Don\u{2019}t worry \u{2014} you can try again!\nYou were so close!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Try Again
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PWColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Try Again!'),
                  ),
                ),
                const SizedBox(height: 12),

                // Back to Games
                TextButton(
                  onPressed: () => context.go('/games'),
                  child: const Text('Back to Games'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
