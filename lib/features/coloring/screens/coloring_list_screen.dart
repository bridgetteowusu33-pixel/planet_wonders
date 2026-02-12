import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../data/coloring_data.dart';

/// Grid of available coloring pages for a country.
class ColoringListScreen extends StatelessWidget {
  const ColoringListScreen({super.key, required this.countryId});

  final String countryId;

  @override
  Widget build(BuildContext context) {
    final pages = pagesForCountry(countryId);
    final countryName =
        countryId[0].toUpperCase() + countryId.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Color $countryName',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: pages.isEmpty
            ? Center(
                child: Text(
                  'No coloring pages yet!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: pages.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return GestureDetector(
                      onTap: () => context.push(
                        '/color/$countryId/${page.id}',
                      ),
                      child: Container(
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              page.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              page.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
