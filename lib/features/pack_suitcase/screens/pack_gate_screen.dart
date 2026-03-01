import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../../cooking_game/v2/widgets/chef_avatar.dart';
import '../models/pack_difficulty.dart';
import '../models/suitcase_pack.dart';
import '../widgets/boarding_pass_card.dart';

/// Boarding-pass intro + difficulty picker (gate phase).
class PackGateScreen extends StatelessWidget {
  const PackGateScreen({
    super.key,
    required this.pack,
    required this.difficulty,
    required this.onDifficultyChanged,
    required this.onStart,
  });

  final SuitcasePack pack;
  final PackDifficulty difficulty;
  final ValueChanged<PackDifficulty> onDifficultyChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 520 : 420),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 24,
              vertical: isTablet ? 24 : 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Character
                ChefAvatar(
                  countryId: pack.countryId,
                  size: isTablet ? 100 : 80,
                  mood: ChefAvatarMood.excited,
                ),
                const SizedBox(height: 16),

                // Boarding pass
                BoardingPassCard(pack: pack, isTablet: isTablet),
                const SizedBox(height: 16),

                // Hint
                if (pack.hint.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '\u{1F4A1} ${pack.hint}', // 💡
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: PWColors.navy,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Difficulty selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: PackDifficulty.values.map((d) {
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
                  height: isTablet ? 56 : 52,
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
                    child: const Text('Start Packing!'),
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
