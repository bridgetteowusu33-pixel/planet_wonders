// File: lib/features/creative_studio/prompt_picker.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/pw_theme.dart';
import 'creative_state.dart';
import 'widgets/prompt_card.dart';

class PromptPickerScreen extends StatelessWidget {
  const PromptPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw With Me'),
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
                'Pick an idea and start drawing.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PWColors.navy.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: kPromptIdeas.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final prompt = kPromptIdeas[index];
                    return PromptCard(
                      prompt: prompt,
                      onTap: () => context.push(
                        '/creative-studio/canvas?mode=draw_with_me&promptId=${prompt.id}',
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
