import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/flying_airplane.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/coloring_data.dart';

/// Lists every country that has coloring pages, shown as 3D sticker cards.
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
          countryIds.isEmpty
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
                      final pageCount =
                          coloringRegistry[countryId]?.length ?? 0;

                      final name = country?.name ??
                          (countryId[0].toUpperCase() +
                              countryId.substring(1));
                      final flag = country?.flagEmoji ?? '';

                      const gradTop = Color(0xFFFF6B5F);
                      const gradBottom = Color(0xFFE23C2D);
                      const radius = BorderRadius.all(Radius.circular(22));

                      return GestureDetector(
                        onTap: () => context.push('/color/$countryId'),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            color: Color.lerp(
                                gradBottom, Colors.black, 0.35),
                          ),
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: const BoxDecoration(
                              borderRadius: radius,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [gradTop, gradBottom],
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$pageCount coloring ${pageCount == 1 ? 'page' : 'pages'}',
                                        style: GoogleFonts.nunito(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
