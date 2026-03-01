import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/pw_theme.dart';
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
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: pack == null || pack.dishes.isEmpty
            ? _NoFood(countryName: countryName)
            : LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final crossAxisCount = w >= 900 ? 4 : w >= 600 ? 3 : 2;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Padding(
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
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
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
                },
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
    return _FoodModeCard(
      color: PWColors.mint,
      icon: Icons.soup_kitchen_rounded,
      title: 'Cooking Game',
      subtitle: 'Play and cook',
      onTap: () => context.push(
        '/cooking-v2-kitchen?countryId=$countryId',
      ),
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
    final gradTop = Color.lerp(color, Colors.white, 0.25)!;
    final gradBottom = color;
    const radius = BorderRadius.all(Radius.circular(18));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: Color.lerp(gradBottom, Colors.black, 0.35),
        ),
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradTop, gradBottom],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
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
    const gradTop = Color(0xFFFFC23B);
    const gradBottom = Color(0xFFEA8B1D);
    const radius = BorderRadius.all(Radius.circular(22));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: Color.lerp(gradBottom, Colors.black, 0.35),
        ),
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradTop, gradBottom],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22)),
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
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                child: Text(
                  dish.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
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
