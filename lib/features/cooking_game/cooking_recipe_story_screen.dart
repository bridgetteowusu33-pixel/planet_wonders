import 'package:flutter/material.dart';

import '../../core/theme/pw_theme.dart';
import 'cooking_entry.dart';
import 'models/recipe.dart';

/// Guided recipe story mode.
///
/// Keeps interactions simple for kids while reinforcing cultural context.
class CookingRecipeStoryScreen extends StatelessWidget {
  const CookingRecipeStoryScreen({
    super.key,
    required this.recipe,
    required this.countryId,
    required this.source,
  });

  final Recipe recipe;
  final String countryId;
  final String source;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Story Mode'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: PWColors.navy.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(recipe.emoji, style: const TextStyle(fontSize: 52)),
                    const SizedBox(height: 6),
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Learn fun facts, then cook it!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PWColors.navy.withValues(alpha: 0.78),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: recipe.funFacts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final fact = recipe.funFacts[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: PWColors.yellow.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: PWColors.navy.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        '💡 $fact',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => openCookingGame(
                        context,
                        source: source,
                        countryId: countryId,
                        recipeId: recipe.id,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start Guided Cook'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        backgroundColor: PWColors.mint,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
