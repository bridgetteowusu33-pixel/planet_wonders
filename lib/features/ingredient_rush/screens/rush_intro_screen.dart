import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../../cooking_game/v2/widgets/chef_avatar.dart';
import '../models/rush_difficulty.dart';
import '../models/rush_mission.dart';

/// Mission briefing screen with difficulty picker and objectives preview.
class RushIntroScreen extends StatelessWidget {
  const RushIntroScreen({
    super.key,
    required this.mission,
    required this.difficulty,
    required this.onDifficultyChanged,
    required this.onStart,
  });

  final RushMission mission;
  final RushDifficulty difficulty;
  final ValueChanged<RushDifficulty> onDifficultyChanged;
  final VoidCallback onStart;

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
                // Character avatar
                ChefAvatar(
                  countryId: mission.countryId,
                  size: 80,
                  mood: ChefAvatarMood.excited,
                ),
                const SizedBox(height: 16),

                // Recipe dish image + name
                _buildDishHeader(context),
                const SizedBox(height: 6),
                Text(
                  'Ingredient Rush!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PWColors.coral,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 20),

                // Mission briefing
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Collect these ingredients:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      ...mission.objectives.map((obj) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                _objectiveIcon(obj),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${obj.name} x${obj.targetCount}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Difficulty selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: RushDifficulty.values.map((d) {
                    final isSelected = d == difficulty;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text('${d.emoji} ${d.label}'),
                        selected: isSelected,
                        onSelected: (_) => onDifficultyChanged(d),
                        selectedColor: PWColors.yellow.withValues(alpha: 0.4),
                        backgroundColor: Colors.white.withValues(alpha: 0.7),
                        labelStyle: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? PWColors.yellow
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Start button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PWColors.coral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Start Mission!'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDishHeader(BuildContext context) {
    final path = mission.dishImagePath;
    return Column(
      children: [
        if (path != null)
          Image.asset(
            path,
            width: 160,
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(
              mission.recipeEmoji,
              style: const TextStyle(fontSize: 96),
            ),
          )
        else
          Text(
            mission.recipeEmoji,
            style: const TextStyle(fontSize: 96),
          ),
        const SizedBox(height: 8),
        Text(
          mission.recipeName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _objectiveIcon(RushObjective obj) {
    final path = obj.assetPath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(
        path,
        width: 28,
        height: 28,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(
          obj.emoji,
          style: const TextStyle(fontSize: 22),
        ),
      );
    }
    return Text(obj.emoji, style: const TextStyle(fontSize: 22));
  }
}
