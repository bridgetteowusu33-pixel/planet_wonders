// File: lib/features/creative_studio/widgets/scene_card.dart
import 'package:flutter/material.dart';

import '../creative_state.dart';

class SceneCard extends StatelessWidget {
  const SceneCard({
    super.key,
    required this.scene,
    required this.onTap,
    this.selected = false,
  });

  final SceneOption scene;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: scene.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: selected ? const Color(0xFF2F3A4A) : Colors.white,
              width: selected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(scene.icon, color: const Color(0xFF2F3A4A), size: 30),
                const Spacer(),
                Text(
                  scene.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF2F3A4A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scene.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF2F3A4A).withValues(alpha: 0.75),
                    fontWeight: FontWeight.w700,
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
