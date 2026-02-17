// File: lib/features/creative_studio/gallery_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/gallery_service.dart';
import '../../core/theme/pw_theme.dart';

class CreativeStudioGalleryScreen extends StatefulWidget {
  const CreativeStudioGalleryScreen({super.key});

  @override
  State<CreativeStudioGalleryScreen> createState() =>
      _CreativeStudioGalleryScreenState();
}

class _CreativeStudioGalleryScreenState
    extends State<CreativeStudioGalleryScreen> {
  List<File> _artworks = <File>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    final files = await GalleryService.loadGallery();
    if (!mounted) return;
    setState(() {
      _artworks = files;
      _loading = false;
    });
  }

  Future<void> _showArtworkOptions(File artwork) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final dpr = MediaQuery.of(context).devicePixelRatio;
                      final cacheWidth = (constraints.maxWidth * dpr)
                          .round()
                          .clamp(1, 4096)
                          .toInt();
                      return Image.file(
                        artwork,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        cacheWidth: cacheWidth,
                        filterQuality: FilterQuality.low,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog<void>(
                      context: this.context,
                      builder: (_) => Dialog.fullscreen(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: InteractiveViewer(
                                minScale: 1,
                                maxScale: 4,
                                child: Image.file(
                                  artwork,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                            ),
                            SafeArea(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  onPressed: () =>
                                      Navigator.of(this.context).pop(),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('View'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    this.context.push('/creative-studio/canvas?mode=free_draw');
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Continue Drawing'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Art'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _artworks.isEmpty
              ? _EmptyCreativeGallery(
                  onStart: () {
                    context.push('/creative-studio/canvas?mode=free_draw');
                  },
                )
              : GridView.builder(
                  itemCount: _artworks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemBuilder: (context, index) {
                    final artwork = _artworks[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _showArtworkOptions(artwork),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final dpr = MediaQuery.of(
                                    context,
                                  ).devicePixelRatio;
                                  final cacheWidth =
                                      (constraints.maxWidth * dpr)
                                          .round()
                                          .clamp(1, 4096)
                                          .toInt();
                                  return Image.file(
                                    artwork,
                                    fit: BoxFit.cover,
                                    cacheWidth: cacheWidth,
                                    filterQuality: FilterQuality.low,
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 16,
                                    color: PWColors.navy,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Artwork ${index + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                  ),
                                ],
                              ),
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

class _EmptyCreativeGallery extends StatelessWidget {
  const _EmptyCreativeGallery({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PWColors.blue.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.palette_rounded,
              size: 48,
              color: PWColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          Text('No art yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Create your first masterpiece in Free Draw.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PWColors.navy.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(onPressed: onStart, child: const Text('Start Drawing')),
        ],
      ),
    );
  }
}
