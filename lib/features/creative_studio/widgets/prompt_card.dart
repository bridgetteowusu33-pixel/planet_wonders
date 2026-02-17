// File: lib/features/creative_studio/widgets/prompt_card.dart
import 'package:flutter/material.dart';

import '../creative_state.dart';

class PromptCard extends StatelessWidget {
  const PromptCard({super.key, required this.prompt, required this.onTap});

  final PromptIdea prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFF6EC6E9).withValues(alpha: 0.22),
                ),
                child: Icon(
                  prompt.icon,
                  size: 28,
                  color: const Color(0xFF2F3A4A),
                ),
              ),
              const Spacer(),
              Text(
                prompt.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                prompt.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF2F3A4A).withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
