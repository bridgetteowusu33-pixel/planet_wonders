import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/country.dart';

/// A tappable card for a single country.
///
/// Locked countries show a translucent overlay with a lock icon so kids
/// can see what's coming without feeling pressured.
class CountryCard extends StatelessWidget {
  const CountryCard({
    super.key,
    required this.country,
    required this.onTap,
  });

  final Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: country.isUnlocked ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
        child: Stack(
          children: [
            // Country content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      country.flagEmoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      country.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Lock overlay for locked countries
            if (!country.isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 32,
                      color: PWColors.navy.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
