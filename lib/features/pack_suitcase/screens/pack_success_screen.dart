import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../cooking_game/v2/widgets/chef_avatar.dart';
import '../models/suitcase_pack.dart';
import '../widgets/suitcase_widget.dart';

/// "All Packed! Boarding!" celebration screen.
class PackSuccessScreen extends StatelessWidget {
  const PackSuccessScreen({
    super.key,
    required this.pack,
    required this.wrongDropCount,
  });

  final SuitcasePack pack;
  final int wrongDropCount;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 520 : 420),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Closed suitcase
                SuitcaseWidget(
                  isOpen: false,
                  packedItems: pack.correctItems,
                  onAcceptItem: (_) {},
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),

                // Character avatar
                ChefAvatar(
                  countryId: pack.countryId,
                  size: isTablet ? 160 : 128,
                  mood: ChefAvatarMood.proud,
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'All Packed! \u{2708}\u{FE0F}', // ✈️
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PWColors.coral,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'You packed everything for ${pack.destination}!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Perfect badge
                if (wrongDropCount == 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: PWColors.mint.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '\u{2B50} Perfect Packer \u{2014} zero wrong items!',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: PWColors.mint,
                      ),
                    ),
                  ),
                const SizedBox(height: 28),

                // Primary: Go Explore
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final continent = _continentFor(pack.countryId);
                      context.push('/world/$continent/${pack.countryId}');
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
                    child: Text('Go Explore ${_capitalize(pack.countryId)}!'),
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

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String _continentFor(String countryId) => switch (countryId) {
        'ghana' || 'nigeria' => 'africa',
        'uk' || 'italy' => 'europe',
        'usa' || 'mexico' => 'north_america',
        'japan' => 'asia',
        _ => 'africa',
      };
}
