// File: lib/features/creative_studio/scene_picker.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/pw_theme.dart';
import 'creative_state.dart';
import 'widgets/scene_card.dart';

class ScenePickerScreen extends StatelessWidget {
  const ScenePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scene Builder'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a place, then add your own drawing.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PWColors.navy.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: kSceneOptions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.05,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final scene = kSceneOptions[index];
                    return SceneCard(
                      scene: scene,
                      onTap: () => context.push(
                        '/creative-studio/canvas?mode=scene_builder&sceneId=${scene.id}',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
