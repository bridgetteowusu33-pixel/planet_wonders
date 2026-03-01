import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/pw_theme.dart';
import '../../../shared/widgets/flying_airplane.dart';
import '../data/world_data.dart';
import '../widgets/country_card.dart';

// ---------------------------------------------------------------------------
// Continent facts & real-world country counts
// ---------------------------------------------------------------------------

class _ContinentInfo {
  const _ContinentInfo({
    required this.realCountryCount,
    required this.funFact,
  });
  final int realCountryCount;
  final String funFact;
}

const _continentInfo = <String, _ContinentInfo>{
  'africa': _ContinentInfo(
    realCountryCount: 54,
    funFact: 'Africa is the second-largest continent and home to the longest '
        'river in the world \u{2014} the Nile!',
  ),
  'asia': _ContinentInfo(
    realCountryCount: 49,
    funFact: 'Asia is the largest continent \u{2014} more than half the '
        'world\u{2019}s people live here!',
  ),
  'europe': _ContinentInfo(
    realCountryCount: 44,
    funFact: 'Europe has more than 40 countries and over 200 languages '
        'are spoken here!',
  ),
  'north_america': _ContinentInfo(
    realCountryCount: 23,
    funFact: 'North America has the world\u{2019}s longest coastline '
        'and the Grand Canyon!',
  ),
  'south_america': _ContinentInfo(
    realCountryCount: 12,
    funFact: 'South America is home to the Amazon Rainforest \u{2014} the '
        'largest tropical rainforest on Earth!',
  ),
  'oceania': _ContinentInfo(
    realCountryCount: 14,
    funFact: 'Oceania includes thousands of islands across the Pacific Ocean, '
        'including the Great Barrier Reef!',
  ),
};

// ---------------------------------------------------------------------------
// Continent screen — countries inside a continent
// ---------------------------------------------------------------------------

/// Shows the countries inside a continent as a grid.
///
/// Locked countries display a lock overlay; unlocked ones navigate to
/// the country hub.
class ContinentScreen extends StatelessWidget {
  const ContinentScreen({super.key, required this.continentId});

  final String continentId;

  @override
  Widget build(BuildContext context) {
    final continent = findContinent(continentId);

    if (continent == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Continent not found')),
      );
    }

    final info = _continentInfo[continentId];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '${continent.emoji}  ${continent.name}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: PWColors.navy,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: PWColors.navy),
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_rounded, color: PWColors.navy),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/backgrounds/world/countries.webp',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.25),
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
          const FlyingAirplane(),
          SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final crossAxisCount = w >= 900 ? 5 : w >= 600 ? 4 : 3;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // --- Header ---
                      _ContinentHeader(
                        continentName: continent.name,
                        realCountryCount: info?.realCountryCount,
                        funFact: info?.funFact,
                      ),

                      const SizedBox(height: 16),

                      // --- Country grid ---
                      Expanded(
                        child: GridView.builder(
                          itemCount: continent.countries.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemBuilder: (context, index) {
                            final country = continent.countries[index];
                            return CountryCard(
                              country: country,
                              onTap: () => context.push(
                                '/world/${continent.id}/${country.id}',
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header for the countries page
// ---------------------------------------------------------------------------

class _ContinentHeader extends StatelessWidget {
  const _ContinentHeader({
    required this.continentName,
    this.realCountryCount,
    this.funFact,
  });

  final String continentName;
  final int? realCountryCount;
  final String? funFact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PWColors.blue.withValues(alpha: 0.15),
            PWColors.mint.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            '\u{1F30D} You\u{2019}re now in $continentName!',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PWColors.navy,
            ),
            textAlign: TextAlign.center,
          ),
          if (realCountryCount != null) ...[
            const SizedBox(height: 4),
            Text(
              'There are $realCountryCount countries here.',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PWColors.navy,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: PWColors.yellow.withValues(alpha: 0.3),
            ),
            child: Text(
              '\u{1F31F} Which country would you like to explore today?',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PWColors.navy,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (funFact != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: PWColors.coral.withValues(alpha: 0.12),
              ),
              child: Text(
                '\u{1F4A1} Did you know? $funFact',
                style: GoogleFonts.fredoka(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: PWColors.navy,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
