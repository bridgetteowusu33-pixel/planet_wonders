import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/services/gallery_service.dart';
import '../../core/theme/pw_theme.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> _drawings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    final files = await GalleryService.loadGallery();
    if (mounted) {
      setState(() {
        _drawings = files;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _drawings.isEmpty
                  ? _EmptyGallery()
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _drawings.length,
                      itemBuilder: (context, index) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final dpr = MediaQuery.of(context).devicePixelRatio;
                            final cacheWidth = (constraints.maxWidth * dpr)
                                .round()
                                .clamp(1, 4096)
                                .toInt();
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _drawings[index],
                                fit: BoxFit.cover,
                                cacheWidth: cacheWidth,
                                filterQuality: FilterQuality.low,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
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
