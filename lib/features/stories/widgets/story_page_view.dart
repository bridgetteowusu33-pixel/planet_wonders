import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/story.dart';
import 'fact_bubble.dart';

/// Renders a single story page: illustration area, text, and optional fact.
class StoryPageView extends StatelessWidget {
  const StoryPageView({super.key, required this.page});

  final StoryPage page;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- illustration placeholder ---
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: page.bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- page title ---
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 10),

          // --- story text ---
          Text(
            page.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.6,
                  color: PWColors.navy,
                ),
          ),

          const SizedBox(height: 16),

          // --- "Did You Know?" bubble ---
          if (page.hasFact)
            FactBubble(
              fact: page.fact!,
              category: page.factCategory,
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
