import 'package:flutter/material.dart';

import '../../core/theme/pw_theme.dart';
import 'cooking_entry.dart';
import 'models/recipe.dart';

/// Unified Cooking Hub.
///
/// All entry points (Home, Food, Games) should land here first.
class CookingHubScreen extends StatelessWidget {
  const CookingHubScreen({
    super.key,
    required this.source,
    required this.countryId,
    this.recipe,
  });

  final String source;
  final String countryId;
  final Recipe? recipe;

  @override
  Widget build(BuildContext context) {
    final title = switch (source) {
      'food' => '🍲 Let\'s Cook ${_countryLabel(countryId)} Food!',
      'games' => '🍳 Let\'s Play Cooking!',
      _ => '🍳 Cooking Fun',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Fun'),
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
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      PWColors.yellow.withValues(alpha: 0.28),
                      PWColors.blue.withValues(alpha: 0.22),
                      PWColors.mint.withValues(alpha: 0.24),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PWColors.navy.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How do you want to cook today?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PWColors.navy.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 1.45,
                  mainAxisSpacing: 12,
                  children: [
                    _ModeCard(
                      color: const Color(0xFFFF9800),
                      emoji: '\u{1F373}', // 🍳
                      title: 'Free Cooking',
                      subtitle: 'Sandbox-style mini-game play',
                      actionLabel: 'Play Free Cook',
                      onTap: () => _openFreeCooking(context),
                    ),
                    _ModeCard(
                      color: const Color(0xFF8E24AA),
                      emoji: '\u{1F4D6}', // 📖
                      title: 'Recipe Stories',
                      subtitle: 'Guided cultural food story mode',
                      actionLabel: 'Open Recipe Story',
                      onTap: () => _openRecipeStory(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFreeCooking(BuildContext context) {
    if (recipe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cooking recipe found yet.')),
      );
      return;
    }
    openCookingGame(
      context,
      source: source,
      countryId: countryId,
      recipeId: recipe!.id,
    );
  }

  void _openRecipeStory(BuildContext context) {
    openCookingRecipeStory(
      context,
      source: source,
      countryId: countryId,
      recipeId: null,
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.color,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final Color color;
  final String emoji;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.58), width: 2),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PWColors.navy.withValues(alpha: 0.74),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size(170, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _countryLabel(String countryId) {
  return countryId
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
