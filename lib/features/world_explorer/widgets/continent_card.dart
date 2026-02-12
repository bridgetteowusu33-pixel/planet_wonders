import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/continent.dart';

/// A tappable card showing a continent's emoji, name, and progress count.
class ContinentCard extends StatelessWidget {
  const ContinentCard({
    super.key,
    required this.continent,
    required this.onTap,
  });

  final Continent continent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = continent.countries.length;
    final unlocked = continent.unlockedCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              continent.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              continent.name,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$unlocked / $total explored',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PWColors.navy.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
