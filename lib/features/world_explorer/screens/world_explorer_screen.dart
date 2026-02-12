import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/world_data.dart';
import '../widgets/continent_card.dart';

/// Top-level World Explorer — a grid of continents to choose from.
class WorldExplorerScreen extends StatelessWidget {
  const WorldExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'World Explorer',
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
              Text(
                'Tap a place to explore the planet!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: worldContinents.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final continent = worldContinents[index];
                    return ContinentCard(
                      continent: continent,
                      onTap: () => context.push('/world/${continent.id}'),
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
