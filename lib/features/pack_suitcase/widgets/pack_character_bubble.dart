import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../../cooking_game/v2/widgets/chef_avatar.dart';

/// Character avatar + speech bubble overlay.
class PackCharacterBubble extends StatelessWidget {
  const PackCharacterBubble({
    super.key,
    required this.countryId,
    required this.line,
    this.mood = ChefAvatarMood.happy,
    this.isTablet = false,
  });

  final String countryId;
  final String line;
  final ChefAvatarMood mood;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ChefAvatar(
          countryId: countryId,
          mood: mood,
          size: isTablet ? 64 : 48,
        ),
        SizedBox(width: isTablet ? 12 : 8),
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: PWColors.navy.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                line,
                key: ValueKey(line),
                style: TextStyle(
                  fontSize: isTablet ? 16 : 13,
                  fontWeight: FontWeight.w600,
                  color: PWColors.navy,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
