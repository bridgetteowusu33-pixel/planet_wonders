import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/gallery_service.dart';
import '../../../core/theme/pw_theme.dart';
import '../../../coloring/palette_bar.dart';
import '../../game_breaks/providers/game_break_settings_provider.dart';
import '../../learning_report/models/learning_stats.dart';
import '../../learning_report/providers/learning_stats_provider.dart';
import '../../game_breaks/widgets/game_break_prompt.dart';
import '../data/coloring_data.dart';
import '../controllers/coloring_save_controller.dart';
import '../models/coloring_page.dart';
import '../models/drawing_state.dart';
import '../painters/image_outline_painter.dart';
import '../painters/region_mask.dart';
import '../painters/region_mask_resolver.dart';
import '../providers/drawing_provider.dart';
import '../widgets/brush_size_selector.dart';
import '../widgets/brush_type_selector.dart';
import '../widgets/coloring_canvas.dart';
import '../widgets/drawing_toolbar.dart';

/// Full-screen coloring page experience.
///
/// Layout (top → bottom):
///   1. Top bar — back, "Country · Page Title", audio toggle, settings
///   2. Fixed single-row horizontal color bar
///   3. Canvas — white card with outline
///   4. Toolbar — Brush, Fill, Eraser, Undo
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
  ConsumerState<ColoringPageScreen> createState() => _ColoringPageScreenState();
}

class _ColoringPageScreenState extends ConsumerState<ColoringPageScreen>
    with WidgetsBindingObserver {
  final _canvasKey = GlobalKey();
  bool _saving = false;

  // Image-based outline loading state.
  OutlinePainter? _resolvedPainter;
  ui.Image? _loadedImage; // held for disposal
  bool _imageLoading = false;
  String? _imageError;
  bool _restoringProgress = true;
  int _restoreSession = 0;
  DrawingState _lastKnownDrawingState = const DrawingState();
  ColoringSaveController? _saveController;
  ProviderSubscription<DrawingState>? _drawingStateSubscription;

  // Region mask loading state (for fill tool).
  RegionMask? _regionMask;

  String get _countryLabel =>
      widget.countryId[0].toUpperCase() + widget.countryId.substring(1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _saveController = ref.read(
      coloringSaveControllerProvider(_currentPageStorageKey),
    );
    _lastKnownDrawingState = ref.read(drawingProvider);
    _drawingStateSubscription = ref.listenManual<DrawingState>(
      drawingProvider,
      _onDrawingStateChanged,
    );
    _loadOutlineIfNeeded();
    _scheduleRestoreProgressForCurrentPage();
  }

  @override
  void didUpdateWidget(covariant ColoringPageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryId != widget.countryId ||
        oldWidget.pageId != widget.pageId) {
      final previousController = _saveController;
      unawaited(
        _saveCurrentPageNow(
          controllerOverride: previousController,
          stateOverride: _lastKnownDrawingState,
        ),
      );

      _loadedImage?.dispose();
      _loadedImage = null;
      _resolvedPainter = null;
      _imageError = null;
      _regionMask = null;
      _saveController = ref.read(
        coloringSaveControllerProvider(_currentPageStorageKey),
      );
      _drawingStateSubscription?.close();
      _drawingStateSubscription = ref.listenManual<DrawingState>(
        drawingProvider,
        _onDrawingStateChanged,
      );
      _loadOutlineIfNeeded();
      _scheduleRestoreProgressForCurrentPage();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _drawingStateSubscription?.close();
    unawaited(
      _saveCurrentPageNow(
        controllerOverride: _saveController,
        stateOverride: _lastKnownDrawingState,
      ),
    );
    _loadedImage?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_saveCurrentPageNow());
    }
  }

  String get _currentPageStorageKey =>
      _storagePageKey(widget.countryId, widget.pageId);

  String _storagePageKey(String countryId, String pageId) {
    return '$countryId/$pageId';
  }

  Future<void> _restoreProgressForCurrentPage() async {
    final restoreSession = ++_restoreSession;

    if (mounted) {
      setState(() => _restoringProgress = true);
    }

    // Ensure provider writes happen outside build/lifecycle execution windows.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || restoreSession != _restoreSession) return;

    final notifier = ref.read(drawingProvider.notifier);
    notifier.clear();

    final saveController = ref.read(
      coloringSaveControllerProvider(_currentPageStorageKey),
    );
    final restored = await saveController.restoreSavedState();

    if (!mounted || restoreSession != _restoreSession) return;

    if (restored != null) {
      notifier.restoreState(restored);
    }

    if (!mounted || restoreSession != _restoreSession) return;
    setState(() => _restoringProgress = false);
    _lastKnownDrawingState = ref.read(drawingProvider);
  }

  void _scheduleRestoreProgressForCurrentPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future<void>(() => _restoreProgressForCurrentPage());
    });
  }

  Future<void> _saveCurrentPageNow({
    ColoringSaveController? controllerOverride,
    DrawingState? stateOverride,
  }) async {
    if (_restoringProgress && stateOverride == null) return;

    final saveController = controllerOverride ?? _saveController;
    if (saveController == null) return;

    DrawingState state = _lastKnownDrawingState;
    if (stateOverride != null) {
      state = stateOverride;
    } else if (mounted) {
      state = ref.read(drawingProvider);
    }
    _lastKnownDrawingState = state;
    await saveController.saveNow(state);
  }

  void _onDrawingStateChanged(DrawingState? previous, DrawingState next) {
    _lastKnownDrawingState = next;
    if (previous == null) return;
    if (_restoringProgress) return;

    final actionsChanged = previous.actions.length != next.actions.length;
    final redoChanged = previous.redoStack.length != next.redoStack.length;
    if (!actionsChanged && !redoChanged) return;

    _saveController?.autoSave(next);
  }

  Future<void> _loadOutlineIfNeeded() async {
    final page = findColoringPage(widget.countryId, widget.pageId);
    if (page == null) return;
    final pageKey = '${page.countryId}/${page.id}';

    // Programmatic painter — use directly, no async work.
    if (page.paintOutline != null) {
      _resolvedPainter = page.paintOutline;
      _resolveMaskForPage(
        page: page,
        pageKey: pageKey,
        painter: page.paintOutline!,
      );
      return;
    }

    // Image-based outline — load from assets.
    if (page.outlineAsset != null) {
      setState(() => _imageLoading = true);
      try {
        final mediaQuery = MediaQuery.maybeOf(context);
        final targetDecodeSize = mediaQuery == null
            ? 1280
            : (mediaQuery.size.shortestSide * mediaQuery.devicePixelRatio * 1.8)
                  .round()
                  .clamp(768, 1600)
                  .toInt();
        final data = await rootBundle.load(page.outlineAsset!);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
          targetWidth: targetDecodeSize,
          targetHeight: targetDecodeSize,
        );
        final frame = await codec.getNextFrame();
        if (mounted) {
          _loadedImage = frame.image;
          setState(() {
            _resolvedPainter = createImageOutlinePainter(frame.image);
            _imageLoading = false;
          });
          _resolveMaskForPage(
            page: page,
            pageKey: pageKey,
            painter: _resolvedPainter!,
          );
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

  Future<void> _resolveMaskForPage({
    required ColoringPage page,
    required String pageKey,
    required OutlinePainter painter,
  }) async {
    try {
      final mask = await RegionMaskResolver.instance.resolve(
        pageKey: pageKey,
        outlinePainter: painter,
        maskAssetPath: page.maskAsset,
      );
      if (!mounted) return;
      if (widget.countryId != page.countryId || widget.pageId != page.id) {
        return;
      }
      setState(() {
        _regionMask = mask;
      });
    } catch (_) {
      // Silently ignore mask loading errors — fill tool just won't be available
    }
  }

  Future<void> _finishColoring() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      await GalleryService.saveDrawing(byteData.buffer.asUint8List());

      final logPage = findColoringPage(widget.countryId, widget.pageId);
      ref.read(learningStatsProvider.notifier).logActivity(
        ActivityLogEntry(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          type: ActivityType.coloring,
          label: 'Colored ${logPage?.title ?? widget.pageId}',
          countryId: widget.countryId,
          timestamp: DateTime.now(),
          emoji: '\u{1F58D}\u{FE0F}',
        ),
      );

      if (mounted) await _showCelebration();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not save')));
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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

  Future<void> _confirmReset() async {
    final shouldReset =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Start over?'),
            content: const Text('Your colors will be erased.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(backgroundColor: PWColors.coral),
                child: const Text('Reset'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldReset || !mounted) return;

    final saveController = ref.read(
      coloringSaveControllerProvider(_currentPageStorageKey),
    );
    await saveController.clearSavedState();
    if (!mounted) return;

    ref.read(drawingProvider.notifier).clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Page reset')));
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        await _saveCurrentPageNow();
        if (!mounted) return;
        navigator.pop(result);
      },
      child: Scaffold(
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
            child: Stack(
              children: [
                AbsorbPointer(
                  absorbing: _restoringProgress,
                  child: Column(
                    children: [
                      // --- 2. Fixed-height horizontal palette bar ---
                      const PaletteBar(height: 58),

                      const SizedBox(height: 10),

                      // --- 3. Canvas (fills remaining space — ~70-75%) ---
                      Expanded(
                        child: RepaintBoundary(
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
                              regionMask: _regionMask,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // --- 4. Toolbar + size ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 430;
                            if (isCompact) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DrawingToolbar(
                                    onResetRequested: _confirmReset,
                                  ),
                                  const SizedBox(height: 8),
                                  const BrushTypeSelector(),
                                  const SizedBox(height: 8),
                                  const BrushSizeSelector(),
                                ],
                              );
                            }

                            return Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                DrawingToolbar(onResetRequested: _confirmReset),
                                const BrushTypeSelector(),
                                const BrushSizeSelector(),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // --- 5. Bottom actions ---
                      Row(
                        children: [
                          // "Did You Know?" button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: page.hasFact
                                  ? () =>
                                        _showFact(page.fact!, page.factCategory)
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
                if (_restoringProgress)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.7),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
