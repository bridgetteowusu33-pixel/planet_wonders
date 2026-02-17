// File: lib/features/creative_studio/background_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'creative_controller.dart';
import 'creative_state.dart';
import 'widgets/scene_card.dart';

class BackgroundPanel extends ConsumerWidget {
  const BackgroundPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creativeControllerProvider);
    final controller = ref.read(creativeControllerProvider.notifier);

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFD9E3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Backgrounds', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Choose a scene or keep plain paper.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF708499),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 270,
              child: GridView.builder(
                itemCount: kSceneOptions.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.28,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final selected = state.sceneId == null;
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: controller.clearScene,
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF2F3A4A)
                                  : const Color(0xFFD8E1EA),
                              width: selected ? 3 : 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Plain Paper',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final scene = kSceneOptions[index - 1];
                  return SceneCard(
                    scene: scene,
                    selected: state.sceneId == scene.id,
                    onTap: () => controller.applyScene(scene.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
