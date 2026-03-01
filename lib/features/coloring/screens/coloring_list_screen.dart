import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/coloring_data.dart';

/// Grid of available coloring pages for a country — 3D sticker style.
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
                    const gradTop = Color(0xFFFF6B5F);
                    const gradBottom = Color(0xFFE23C2D);
                    const radius = BorderRadius.all(Radius.circular(24));

                    return GestureDetector(
                      onTap: () => context.push(
                        '/color/$countryId/${page.id}',
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          color: Color.lerp(
                              gradBottom, Colors.black, 0.35),
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
                          child: Stack(
                            children: [
                              // Shine highlight
                              Positioned(
                                left: 6,
                                right: 6,
                                top: 6,
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white
                                            .withValues(alpha: 0.4),
                                        Colors.white
                                            .withValues(alpha: 0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              // Content
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  if (page.thumbnailAsset != null)
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: Image.asset(
                                            page.thumbnailAsset!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            cacheWidth: 400,
                                            errorBuilder: (_, _, _) =>
                                                Center(
                                              child: Text(
                                                page.emoji,
                                                style: const TextStyle(
                                                    fontSize: 48),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          page.emoji,
                                          style: const TextStyle(
                                              fontSize: 48),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8, 0, 8, 10),
                                    child: Text(
                                      page.title,
                                      style: GoogleFonts.fredoka(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
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
    );
  }
}
