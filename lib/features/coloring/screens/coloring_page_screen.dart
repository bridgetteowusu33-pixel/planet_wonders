import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/gallery_service.dart';
import '../../../core/theme/pw_theme.dart';
import '../../game_breaks/providers/game_break_settings_provider.dart';
import '../../game_breaks/widgets/game_break_prompt.dart';
import '../data/coloring_data.dart';
import '../models/coloring_page.dart';
import '../painters/image_outline_painter.dart';
import '../widgets/brush_size_selector.dart';
import '../widgets/color_palette.dart';
import '../widgets/coloring_canvas.dart';
import '../widgets/drawing_toolbar.dart';

/// Full-screen coloring page experience.
///
/// Layout (top → bottom):
///   1. Top bar — back, "Country · Page Title", audio toggle, settings
///   2. Canvas — 70-75% of screen, white card with outline
///   3. Toolbar — Brush, Fill, Eraser, Undo
///   4. Color palette — 8 primary + "More" toggle
///   5. Bottom actions — "Did You Know?" (left) + "Done" (right)
class ColoringPageScreen extends ConsumerStatefulWidget {
  const ColoringPageScreen({
    super.key,
    required this.countryId,
    required this.pageId,
  });

  final String countryId;
  final String pageId;

  @override
  ConsumerState<ColoringPageScreen> createState() =>
      _ColoringPageScreenState();
}

class _ColoringPageScreenState extends ConsumerState<ColoringPageScreen> {
  final _canvasKey = GlobalKey();
  bool _saving = false;

  // Image-based outline loading state.
  OutlinePainter? _resolvedPainter;
  ui.Image? _loadedImage; // held for disposal
  bool _imageLoading = false;
  String? _imageError;

  String get _countryLabel =>
      widget.countryId[0].toUpperCase() + widget.countryId.substring(1);

  @override
  void initState() {
    super.initState();
    _loadOutlineIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ColoringPageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryId != widget.countryId ||
        oldWidget.pageId != widget.pageId) {
      _loadedImage?.dispose();
      _loadedImage = null;
      _resolvedPainter = null;
      _imageError = null;
      _loadOutlineIfNeeded();
    }
  }

  @override
  void dispose() {
    _loadedImage?.dispose();
    super.dispose();
  }

  Future<void> _loadOutlineIfNeeded() async {
    final page = findColoringPage(widget.countryId, widget.pageId);
    if (page == null) return;

    // Programmatic painter — use directly, no async work.
    if (page.paintOutline != null) {
      _resolvedPainter = page.paintOutline;
      return;
    }

    // Image-based outline — load from assets.
    if (page.outlineAsset != null) {
      setState(() => _imageLoading = true);
      try {
        final data = await rootBundle.load(page.outlineAsset!);
        final codec =
            await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        if (mounted) {
          _loadedImage = frame.image;
          setState(() {
            _resolvedPainter = createImageOutlinePainter(frame.image);
            _imageLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _imageError = 'Could not load outline image';
            _imageLoading = false;
          });
        }
      }
    }
  }

  Future<void> _finishColoring() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      await GalleryService.saveDrawing(byteData.buffer.asUint8List());

      if (mounted) await _showCelebration();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showCelebration() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '\u{1F389}', // 🎉
              style: TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 12),
            Text(
              'Beautiful!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Saved to your Gallery',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PWColors.navy.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // close celebration dialog

                // Schedule next navigation on the next frame to avoid
                // _debugLocked assertion from back-to-back navigator calls.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;

                  final settings = ref.read(gameBreakSettingsProvider);
                  if (settings.enabled && settings.afterActivities) {
                    showGameBreakPrompt(
                      context,
                      gameName: 'Memory Match',
                      gameEmoji: '\u{1F0CF}', // 🃏
                      onPlay: () {
                        if (!mounted) return;
                        final cId = widget.countryId;
                        Navigator.of(context).pop(); // pop coloring screen
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.push('/game-break/memory/$cId');
                        });
                      },
                      onDismiss: () {
                        if (!mounted) return;
                        Navigator.of(context).pop(); // back to list
                      },
                    );
                  } else {
                    Navigator.of(context).pop(); // back to list
                  }
                });
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFact(String fact, String? category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PWColors.navy.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  '\u{1F4A1}', // 💡
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 10),
                Text(
                  'Did You Know?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (category != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: PWColors.mint.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PWColors.navy,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              fact,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = findColoringPage(widget.countryId, widget.pageId);

    if (page == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Page not found')),
      );
    }

    // Show loading spinner while an image-based outline loads.
    if (_imageLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '$_countryLabel \u{00B7} ${page.title}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error if image failed to load.
    if (_imageError != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_imageError!)),
      );
    }

    final painter = _resolvedPainter ?? page.paintOutline!;

    return Scaffold(
      // --- 1. Top bar ---
      appBar: AppBar(
        title: Text(
          '$_countryLabel \u{00B7} ${page.title}', // Country · Page Title
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Audio toggle placeholder
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio coming soon!')),
              );
            },
          ),
          // Settings placeholder
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // --- 2. Canvas (fills remaining space — ~70-75%) ---
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: PWColors.navy.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ColoringCanvas(
                    canvasKey: _canvasKey,
                    paintOutline: painter,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- 3. Toolbar + size ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const DrawingToolbar(),
                  const SizedBox(width: 16),
                  const BrushSizeSelector(),
                ],
              ),

              const SizedBox(height: 10),

              // --- 4. Color palette ---
              const ColorPalette(),

              const SizedBox(height: 10),

              // --- 5. Bottom actions ---
              Row(
                children: [
                  // "Did You Know?" button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: page.hasFact
                          ? () => _showFact(page.fact!, page.factCategory)
                          : null,
                      icon: const Text(
                        '\u{1F4A1}', // 💡
                        style: TextStyle(fontSize: 18),
                      ),
                      label: const Text('Did You Know?'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: page.hasFact
                              ? PWColors.yellow
                              : PWColors.navy.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // "Done" button
                  FilledButton.icon(
                    onPressed: _saving ? null : _finishColoring,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_rounded),
                    label: const Text('Done'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 44),
                      backgroundColor: PWColors.mint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
