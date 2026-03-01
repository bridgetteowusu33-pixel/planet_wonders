import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../cooking_game/cooking_entry.dart';
import '../../cooking_game/v2/widgets/chef_avatar.dart';
import '../models/rush_mission.dart';
import '../widgets/rush_pot_widget.dart';

/// "Mission Complete!" celebration screen.
class RushSuccessScreen extends StatelessWidget {
  const RushSuccessScreen({
    super.key,
    required this.mission,
    required this.wrongTaps,
    required this.timerFractionRemaining,
  });

  final RushMission mission;
  final int wrongTaps;
  final double timerFractionRemaining;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pot in party state
                RushPotWidget(
                  countryId: mission.countryId,
                  face: 'party',
                  size: 100,
                ),
                const SizedBox(height: 12),

                // Character avatar
                ChefAvatar(
                  countryId: mission.countryId,
                  size: 128,
                  mood: ChefAvatarMood.proud,
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Mission Complete! \u{1F389}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PWColors.coral,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'You collected all the ingredients for ${mission.recipeName}!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                Text(
                  'The dish is ready to cook!',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Stats
                if (wrongTaps == 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: PWColors.mint.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '\u{2B50} Perfect \u{2014} zero wrong taps!',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: PWColors.mint,
                      ),
                    ),
                  ),

                const SizedBox(height: 28),

                // Primary: Cook This Dish
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      openCookingHub(
                        context,
                        source: 'ingredient_rush',
                        countryId: mission.countryId,
                        recipeId: mission.recipeId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PWColors.coral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Cook This Dish!'),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary: Back to Games
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
