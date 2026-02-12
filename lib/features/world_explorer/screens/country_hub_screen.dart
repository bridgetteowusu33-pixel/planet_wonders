import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../../core/widgets/activity_card.dart';
import '../data/world_data.dart';

/// The hub for a single country — shows activity cards the kid can explore.
class CountryHubScreen extends StatelessWidget {
  const CountryHubScreen({
    super.key,
    required this.continentId,
    required this.countryId,
  });

  final String continentId;
  final String countryId;

  @override
  Widget build(BuildContext context) {
    final country = findCountry(continentId, countryId);

    if (country == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Country not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${country.flagEmoji}  ${country.name}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // --- Banner ---
              _CountryBanner(
                flagEmoji: country.flagEmoji,
                greeting: country.greeting,
              ),

              const SizedBox(height: 14),

              // --- Subtitle ---
              Text(
                'Discover the wonders of ${country.name}!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                    ),
              ),

              const SizedBox(height: 16),

              // --- Activity grid ---
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: [
                    ActivityCard(
                      emoji: '\u{1F3A8}', // 🎨
                      label: 'Color',
                      color: const Color(0xFFFF9800),
                      onTap: () => context.push('/color/${country.id}'),
                    ),
                    ActivityCard(
                      emoji: '\u{1F4D6}', // 📖
                      label: 'Story',
                      color: const Color(0xFF9C27B0),
                      onTap: () => context.push('/story/${country.id}'),
                    ),
                    ActivityCard(
                      emoji: '\u{1F457}', // 👗
                      label: 'Fashion',
                      color: const Color(0xFF4CAF50),
                      onTap: () => context.push('/fashion/${country.id}'),
                    ),
                    ActivityCard(
                      emoji: '\u{1F373}', // 🍳
                      label: 'Food',
                      color: PWColors.coral,
                      onTap: () => _comingSoon(context, 'Food'),
                    ),
                    ActivityCard(
                      emoji: '\u{1F9E9}', // 🧩
                      label: 'Puzzle',
                      color: PWColors.blue,
                      onTap: () => _comingSoon(context, 'Puzzle'),
                    ),
                    ActivityCard(
                      emoji: '\u{1F3AE}', // 🎮
                      label: 'Games',
                      color: PWColors.mint,
                      onTap: () => _comingSoon(context, 'Games'),
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

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}

/// Illustrated banner placeholder for the country hub.
///
/// Uses a gradient with the country flag + greeting text. Replace the
/// emoji decorations with actual country illustrations later.
class _CountryBanner extends StatelessWidget {
  const _CountryBanner({
    required this.flagEmoji,
    required this.greeting,
  });

  final String flagEmoji;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PWColors.yellow.withValues(alpha: 0.35),
            PWColors.mint.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative emojis (placeholder for illustrations)
          const Positioned(
            top: -4,
            right: 0,
            child: Text(
              '\u{1F3B5}', // 🎵
              style: TextStyle(fontSize: 24),
            ),
          ),
          const Positioned(
            bottom: -4,
            left: 0,
            child: Text(
              '\u{1F331}', // 🌱
              style: TextStyle(fontSize: 20),
            ),
          ),
          // Main content
          Column(
            children: [
              Text(
                flagEmoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                greeting,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
