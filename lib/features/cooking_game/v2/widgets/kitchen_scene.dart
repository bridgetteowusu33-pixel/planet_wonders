import 'package:flutter/material.dart';

import '../models/pot_face_state.dart';
import 'chef_avatar.dart';
import 'illustrated_pot.dart';
import 'steam_effect.dart';

/// Composited kitchen scene: kitchen bg → steam → pot → chef + speech bubble.
/// Used as the visual centerpiece in the step player.
class KitchenSceneWidget extends StatelessWidget {
  const KitchenSceneWidget({
    super.key,
    required this.countryId,
    required this.potFace,
    required this.progress,
    required this.chefLine,
    this.showSteam = false,
    this.chefMood = ChefAvatarMood.happy,
  });

  final String countryId;
  final PotFaceState potFace;
  final double progress;
  final String chefLine;
  final bool showSteam;
  final ChefAvatarMood chefMood;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Background provided by V2CookingShell — keep transparent.
            // Steam wisps above pot
            if (showSteam)
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: SteamEffect(
                    countryId: countryId,
                    width: 100,
                    height: 60,
                  ),
                ),
              ),
            // Illustrated pot (centered)
            Positioned.fill(
              child: Center(
                child: IllustratedPot(
                  countryId: countryId,
                  faceState: potFace,
                  size: 320,
                  progress: progress,
                ),
              ),
            ),
            // Chef avatar + speech bubble (bottom-left)
            if (chefLine.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0, right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      ChefAvatar(
                        countryId: countryId,
                        size: 90,
                        mood: chefMood,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFD166),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            chefLine,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF264653),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
