import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/world_data.dart';
import '../widgets/country_card.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${continent.emoji}  ${continent.name}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final crossAxisCount = w >= 900 ? 4 : w >= 600 ? 3 : 2;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    itemCount: continent.countries.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
