import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/gallery_service.dart';
import '../../core/theme/pw_theme.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryProvider);
    final dpr = MediaQuery.of(context).devicePixelRatio;
    const gridSpacing = 12.0;
    const horizontalPadding = 32.0; // parent padding: 16 + 16
    final cellWidth =
        (MediaQuery.of(context).size.width - horizontalPadding - gridSpacing) /
        2;
    final cacheWidth = (cellWidth * dpr).round().clamp(1, 1024).toInt();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'My Gallery',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Your saved artwork',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: galleryAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Center(
                  child: Text('Could not load gallery'),
                ),
                data: (drawings) => drawings.isEmpty
                    ? const _EmptyGallery()
                    : RepaintBoundary(
                        child: GridView.builder(
                          cacheExtent: 900,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: drawings.length,
                          itemBuilder: (context, index) {
                            return RepaintBoundary(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  drawings[index],
                                  fit: BoxFit.cover,
                                  cacheWidth: cacheWidth,
                                  filterQuality: FilterQuality.low,
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
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.brush_rounded,
            size: 64,
            color: PWColors.blue.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No artwork yet!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Start drawing to fill your gallery',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PWColors.navy.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
