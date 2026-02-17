import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../cooking_game/cooking_entry.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/food_data.dart';
import '../models/food_dish.dart';

/// Food Home + Food Grid screen for one country.
class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key, required this.countryId});

  final String countryId;

  @override
  Widget build(BuildContext context) {
    final pack = findFoodPack(countryId);
    final country = findCountryById(countryId);
    final countryName = country?.name ?? countryId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '\u{1F374} Taste of $countryName',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: pack == null || pack.dishes.isEmpty
            ? _NoFood(countryName: countryName)
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _FoodBanner(
                      flagEmoji: country?.flagEmoji ?? '',
                      countryName: countryName,
                    ),
                    const SizedBox(height: 10),
                    _FoodModeRow(
                      countryId: countryId,
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: GridView.builder(
                        itemCount: pack.dishes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.84,
                        ),
                        itemBuilder: (context, index) {
                          final dish = pack.dishes[index];
                          return _FoodCard(
                            dish: dish,
                            onTap: () => context.push(
                              '/food/$countryId/${dish.id}',
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

class _FoodModeRow extends StatelessWidget {
  const _FoodModeRow({required this.countryId});

  final String countryId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FoodModeCard(
            color: PWColors.mint,
            icon: Icons.soup_kitchen_rounded,
            title: 'Cooking Game',
            subtitle: 'Play and cook',
            onTap: () => openCookingHub(
              context,
              source: 'food',
              countryId: countryId,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FoodModeCard(
            color: PWColors.coral,
            icon: Icons.menu_book_rounded,
            title: 'Recipe Story',
            subtitle: 'Cook with a story',
            onTap: () => context.push('/recipe-story/$countryId?source=food'),
          ),
        ),
      ],
    );
  }
}

class _FoodModeCard extends StatelessWidget {
  const _FoodModeCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: PWColors.navy),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PWColors.navy.withValues(alpha: 0.72),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodBanner extends StatelessWidget {
  const _FoodBanner({
    required this.flagEmoji,
    required this.countryName,
  });

  final String flagEmoji;
  final String countryName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            PWColors.yellow.withValues(alpha: 0.35),
            PWColors.coral.withValues(alpha: 0.22),
            PWColors.mint.withValues(alpha: 0.28),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            flagEmoji,
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Adventure',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover yummy dishes from $countryName!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PWColors.navy.withValues(alpha: 0.78),
                      ),
                ),
              ],
            ),
          ),
          const Text(
            '\u{1F355}', // 🍕
            style: TextStyle(fontSize: 26),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({
    required this.dish,
    required this.onTap,
  });

  final FoodDish dish;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  dish.previewAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      dish.emoji,
                      style: const TextStyle(fontSize: 52),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                children: [
                  Text(
                    dish.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dish.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoFood extends StatelessWidget {
  const _NoFood({required this.countryName});

  final String countryName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '\u{1F372}', // 🍲
              style: TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 10),
            Text(
              'Food pack for $countryName is coming soon!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
