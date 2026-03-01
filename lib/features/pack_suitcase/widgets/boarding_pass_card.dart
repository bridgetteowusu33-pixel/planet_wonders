import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../../world_explorer/data/character_intros.dart';
import '../models/suitcase_pack.dart';

/// Decorative boarding-pass card shown on the gate screen.
class BoardingPassCard extends StatelessWidget {
  const BoardingPassCard({super.key, required this.pack, this.isTablet = false});

  final SuitcasePack pack;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 28 : 20,
        vertical: isTablet ? 20 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PWColors.yellow.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: PWColors.yellow.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'BOARDING PASS',
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.4,
              color: PWColors.navy.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 10),
          // Divider dashes
          Row(
            children: List.generate(
              30,
              (_) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 1,
                  color: PWColors.navy.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Destination row
          Row(
            children: [
              // Character avatar
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.destination,
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.w800,
                        color: PWColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Passenger: ${pack.characterName}',
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 13,
                        fontWeight: FontWeight.w600,
                        color: PWColors.navy.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detail('FLIGHT', 'PW-102'),
              _detail('GATE', 'FUN'),
              _detail('ITEMS', '${pack.requiredCount}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final size = isTablet ? 48.0 : 40.0;
    final intro = characterIntroFor(pack.countryId);
    if (intro == null) {
      return Text(
        pack.characterEmoji,
        style: TextStyle(fontSize: isTablet ? 40 : 32),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.asset(
        intro.characterAvatar,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Text(
          pack.characterEmoji,
          style: TextStyle(fontSize: isTablet ? 40 : 32),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: PWColors.navy.withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: PWColors.coral,
          ),
        ),
      ],
    );
  }
}
