import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/cooking_step.dart';

class CookingHeader extends StatelessWidget {
  const CookingHeader({
    super.key,
    required this.recipeName,
    required this.state,
    required this.progress,
  });

  final String recipeName;
  final CookingState state;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final stepLabel = switch (state) {
      CookingState.intro => 'Get Ready',
      CookingState.addIngredients => '1/3 Add',
      CookingState.stir => '2/3 Stir',
      CookingState.plate => '3/3 Serve',
      CookingState.complete => 'Complete',
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍳 $recipeName',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                stepLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PWColors.blue,
                    ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: PWColors.navy.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(PWColors.mint),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
