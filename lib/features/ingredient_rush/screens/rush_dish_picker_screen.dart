import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../../cooking_game/v2/widgets/chef_avatar.dart';
import '../models/rush_mission.dart';

/// Grid picker showing all available dishes for a country.
class RushDishPickerScreen extends StatelessWidget {
  const RushDishPickerScreen({
    super.key,
    required this.countryId,
    required this.missions,
    required this.onPick,
  });

  final String countryId;
  final List<RushMission> missions;
  final ValueChanged<RushMission> onPick;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Character + title
                ChefAvatar(
                  countryId: countryId,
                  size: 72,
                  mood: ChefAvatarMood.excited,
                ),
                const SizedBox(height: 12),
                Text(
                  'Pick a Dish!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose which ingredients to collect',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 20),

                // Dish grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final crossAxisCount = w >= 400 ? 3 : 2;

                      return GridView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: missions.length,
                        itemBuilder: (context, index) {
                          final mission = missions[index];
                          return _DishCard(
                            mission: mission,
                            onTap: () => onPick(mission),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.mission, required this.onTap});

  final RushMission mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dish image
            _buildDishImage(),
            const SizedBox(height: 8),

            // Dish name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                mission.recipeName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),

            // Ingredient count
            Text(
              '${mission.objectives.length} ingredients',
              style: TextStyle(
                fontSize: 11,
                color: PWColors.navy.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishImage() {
    final path = mission.dishImagePath;
    if (path != null) {
      return Image.asset(
        path,
        width: 112,
        height: 112,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(
          mission.recipeEmoji,
          style: const TextStyle(fontSize: 88),
        ),
      );
    }
    return Text(
      mission.recipeEmoji,
      style: const TextStyle(fontSize: 88),
    );
  }
}
