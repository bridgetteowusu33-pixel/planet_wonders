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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            itemCount: continent.countries.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
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
  }
}
