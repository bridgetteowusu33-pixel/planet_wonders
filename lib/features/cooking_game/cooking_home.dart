import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/pw_theme.dart';
import '../../shared/widgets/flying_airplane.dart';
import 'cooking_entry.dart';
import 'data/recipes_ghana.dart';
import 'models/recipe.dart';

// Countries that have cooking recipes.
const _cookingCountries = [
  (id: 'ghana', name: 'Ghana', emoji: '\u{1F1EC}\u{1F1ED}', flag: 'assets/flags/ghana.webp'),
  (id: 'nigeria', name: 'Nigeria', emoji: '\u{1F1F3}\u{1F1EC}', flag: 'assets/flags/nigeria.webp'),
  (id: 'uk', name: 'United Kingdom', emoji: '\u{1F1EC}\u{1F1E7}', flag: 'assets/flags/uk.webp'),
  (id: 'usa', name: 'United States', emoji: '\u{1F1FA}\u{1F1F8}', flag: 'assets/flags/usa.webp'),
];

/// Unified Cooking Hub.
///
/// When [countryId] is null, shows a country picker.
/// When set, shows the per-country cooking mode options.
class CookingHubScreen extends StatelessWidget {
  const CookingHubScreen({
    super.key,
    required this.source,
    required this.countryId,
    this.recipe,
  });

  final String source;
  final String? countryId;
  final Recipe? recipe;

  @override
  Widget build(BuildContext context) {
    if (countryId == null) {
      return _CookingCountryPicker(source: source);
    }

    final title = switch (source) {
      'food' => '\u{1F372} Let\'s Cook ${_countryLabel(countryId!)} Food!',
      'games' => '\u{1F373} Let\'s Play Cooking!',
      _ => '\u{1F373} Cooking Fun',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Fun'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          const FlyingAirplane(),
          SafeArea(
        child: SingleChildScrollView(
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
              _ModeCard(
                color: const Color(0xFFFF9800),
                emoji: '\u{1F373}', // 🍳
                title: 'Free Cooking',
                subtitle: 'Sandbox-style mini-game play',
                actionLabel: 'Play Free Cook',
                onTap: () => _openFreeCooking(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  void _openFreeCooking(BuildContext context) {
    final cid = countryId;
    if (cid == null || cid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a country first.')),
      );
      return;
    }
    // Launch V2 kitchen screen for the selected country.
    context.push(
      Uri(
        path: '/cooking-v2-kitchen',
        queryParameters: {'countryId': cid},
      ).toString(),
    );
  }

}

// ---------------------------------------------------------------------------
// Country picker shown when no country is specified
// ---------------------------------------------------------------------------

class _CookingCountryPicker extends StatelessWidget {
  const _CookingCountryPicker({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Fun'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          const FlyingAirplane(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Pick a Country!',
                    style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: PWColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Which kitchen do you want to cook in?',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: PWColors.navy.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _cookingCountries.length,
                    itemBuilder: (context, index) {
                      final c = _cookingCountries[index];
                      final recipeCount =
                          cookingRecipesForCountry(c.id).length;
                      return _CountryCard(
                        name: c.name,
                        flagAsset: c.flag,
                        recipeCount: recipeCount,
                        onTap: () => context.push(
                          cookingRoute(
                            source: source,
                            view: 'hub',
                            countryId: c.id,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryCard extends StatelessWidget {
  const _CountryCard({
    required this.name,
    required this.flagAsset,
    required this.recipeCount,
    required this.onTap,
  });

  final String name;
  final String flagAsset;
  final int recipeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: PWColors.yellow.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                flagAsset,
                width: 56,
                height: 38,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Text(
                  '\u{1F3F3}',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: PWColors.navy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '$recipeCount recipes',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PWColors.navy.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
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
