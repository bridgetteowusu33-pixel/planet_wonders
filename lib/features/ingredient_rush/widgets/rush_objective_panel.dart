import 'package:flutter/material.dart';

import '../models/rush_mission.dart';

/// HUD panel showing the current objective: ingredient icon, name, and counter.
class RushObjectivePanel extends StatelessWidget {
  const RushObjectivePanel({
    super.key,
    required this.objective,
    required this.collected,
    this.countryId = 'ghana',
  });

  final RushObjective objective;
  final int collected;
  final String countryId;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Container(
        key: ValueKey<String>(objective.ingredientId),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(width: 8),
            Text(
              'Collect: ${objective.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$collected / ${objective.targetCount}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFFE65100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final path = objective.assetPath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(
        path,
        width: 36,
        height: 36,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(
          objective.emoji,
          style: const TextStyle(fontSize: 28),
        ),
      );
    }
    return Text(
      objective.emoji,
      style: const TextStyle(fontSize: 28),
    );
  }
}
