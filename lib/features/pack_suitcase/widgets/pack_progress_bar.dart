import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

/// Linear progress bar showing packed-item count.
class PackProgressBar extends StatelessWidget {
  const PackProgressBar({
    super.key,
    required this.packed,
    required this.required_,
    this.isTablet = false,
  });

  final int packed;
  final int required_;
  final bool isTablet;

  double get _fraction =>
      required_ > 0 ? (packed / required_).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          'Packed: $packed / $required_',
          style: TextStyle(
            fontSize: isTablet ? 17 : 14,
            fontWeight: FontWeight.w700,
            color: PWColors.navy,
          ),
        ),
        const SizedBox(height: 6),
        // Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: isTablet ? 16 : 12,
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    color: PWColors.navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: _fraction,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [PWColors.mint, PWColors.blue],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
