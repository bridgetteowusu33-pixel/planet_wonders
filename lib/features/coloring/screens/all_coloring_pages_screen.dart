import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/coloring_data.dart';

/// Lists every country that has coloring pages, shown as flag + name cards.
/// Tapping a country navigates to that country's coloring page grid.
class AllColoringPagesScreen extends StatelessWidget {
  const AllColoringPagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final countryIds = coloringRegistry.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Coloring Pages',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: countryIds.isEmpty
          ? Center(
              child: Text(
                'No coloring pages yet!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.separated(
                itemCount: countryIds.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final countryId = countryIds[index];
                  final country = findCountryById(countryId);
                  final pageCount = coloringRegistry[countryId]?.length ?? 0;

                  final name = country?.name ??
                      (countryId[0].toUpperCase() + countryId.substring(1));
                  final flag = country?.flagEmoji ?? '';

                  return GestureDetector(
                    onTap: () => context.push('/color/$countryId'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: PWColors.navy.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            flag,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$pageCount coloring ${pageCount == 1 ? 'page' : 'pages'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: PWColors.navy
                                            .withValues(alpha: 0.5),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: PWColors.navy.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
