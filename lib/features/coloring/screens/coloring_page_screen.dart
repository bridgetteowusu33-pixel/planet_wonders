import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/gallery_service.dart';
import '../../../core/theme/pw_theme.dart';
import '../../../coloring/palette_bar.dart';
import '../../creative_studio/creative_state.dart' show StickerItem, StickerInstance;
import '../../creative_studio/widgets/sticker_card.dart';
import '../../game_breaks/providers/game_break_settings_provider.dart';
import '../../learning_report/models/learning_stats.dart';
import '../../learning_report/providers/learning_stats_provider.dart';
import '../../stickers/providers/sticker_provider.dart';
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

  // Sticker overlay state.
  List<StickerInstance> _stickerInstances = [];
  String? _selectedStickerId;

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
    _scheduleRestoreProgressForCurrentPage();
  }

  bool _outlineLoadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_outlineLoadStarted) {
      _outlineLoadStarted = true;
      _loadOutlineIfNeeded();
    }
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
      _stickerInstances = [];
      _selectedStickerId = null;
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
    await _loadStickers();
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
    await _persistStickers();
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
      } catch (e, st) {
        debugPrint('Coloring outline load failed: $e\n$st');
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
    // Deselect stickers so selection border doesn't appear in export.
    setState(() {
      _saving = true;
      _selectedStickerId = null;
    });

    // Wait a frame so the selection border is removed before capture.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      await GalleryService.saveDrawing(byteData.buffer.asUint8List());
      ref.invalidate(galleryProvider);

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
      ref.read(stickerProvider.notifier).checkAndAward(
            conditionType: 'coloring_completed',
            countryId: widget.countryId,
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
                          context.push('/games/$cId/memory');
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
    setState(() {
      _stickerInstances = [];
      _selectedStickerId = null;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('coloring_stickers_$_currentPageStorageKey');
    if (!mounted) return;
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

  // ---------------------------------------------------------------------------
  // Sticker methods
  // ---------------------------------------------------------------------------

  Future<void> _openStickerPanel() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ColoringStickerPanel(
        countryId: widget.countryId,
        onStickerSelected: _addSticker,
      ),
    );
  }

  void _addSticker(StickerItem item) {
    final instance = StickerInstance(
      id: 'sticker_${DateTime.now().microsecondsSinceEpoch}',
      itemId: item.id,
      label: item.label,
      emoji: item.emoji,
      assetPath: item.assetPath,
      position: const Offset(150, 150),
      scale: 1,
      rotation: 0,
    );
    setState(() {
      _stickerInstances = [..._stickerInstances, instance];
      _selectedStickerId = instance.id;
    });
    unawaited(_persistStickers());
  }

  void _updateStickerTransform({
    required String stickerId,
    required Offset position,
    required double scale,
    required double rotation,
  }) {
    setState(() {
      _stickerInstances = _stickerInstances
          .map(
            (s) => s.id == stickerId
                ? s.copyWith(
                    position: position,
                    scale: scale.clamp(0.35, 3.0).toDouble(),
                    rotation: rotation,
                  )
                : s,
          )
          .toList(growable: false);
      _selectedStickerId = stickerId;
    });
  }

  void _removeSticker(String stickerId) {
    setState(() {
      _stickerInstances = _stickerInstances
          .where((s) => s.id != stickerId)
          .toList(growable: false);
      if (_selectedStickerId == stickerId) _selectedStickerId = null;
    });
    unawaited(_persistStickers());
  }

  void _selectSticker(String? id) {
    if (_selectedStickerId == id) return;
    setState(() => _selectedStickerId = id);
  }

  Future<void> _persistStickers() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'coloring_stickers_$_currentPageStorageKey';
    if (_stickerInstances.isEmpty) {
      await prefs.remove(key);
      return;
    }
    final data = _stickerInstances
        .map(
          (s) => <String, dynamic>{
            'id': s.id,
            'itemId': s.itemId,
            'label': s.label,
            'emoji': s.emoji,
            'assetPath': s.assetPath,
            'x': s.position.dx,
            'y': s.position.dy,
            'scale': s.scale,
            'rotation': s.rotation,
          },
        )
        .toList(growable: false);
    await prefs.setString(key, jsonEncode(data));
  }

  Future<void> _loadStickers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('coloring_stickers_$_currentPageStorageKey');
    if (raw == null || raw.isEmpty) {
      setState(() {
        _stickerInstances = [];
        _selectedStickerId = null;
      });
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      setState(() {
        _stickerInstances = list.map((item) {
          final map = item as Map<String, dynamic>;
          return StickerInstance(
            id: map['id'] as String,
            itemId: map['itemId'] as String,
            label: map['label'] as String,
            emoji: map['emoji'] as String,
            assetPath: map['assetPath'] as String?,
            position: Offset(
              (map['x'] as num).toDouble(),
              (map['y'] as num).toDouble(),
            ),
            scale: (map['scale'] as num).toDouble(),
            rotation: (map['rotation'] as num).toDouble(),
          );
        }).toList();
        _selectedStickerId = null;
      });
    } catch (_) {
      setState(() {
        _stickerInstances = [];
        _selectedStickerId = null;
      });
    }
  }

  Widget? _buildStickerOverlay() {
    if (_stickerInstances.isEmpty) return null;
    return Stack(
      children: _stickerInstances.map((sticker) {
        final size = 112 * sticker.scale;
        return Positioned(
          left: sticker.position.dx - size / 2,
          top: sticker.position.dy - size / 2,
          child: _EditableColoringSticker(
            sticker: sticker,
            selected: _selectedStickerId == sticker.id,
            onSelected: () => _selectSticker(sticker.id),
            onChanged: (position, scale, rotation) =>
                _updateStickerTransform(
                  stickerId: sticker.id,
                  position: position,
                  scale: scale,
                  rotation: rotation,
                ),
            onChangeEnd: () => unawaited(_persistStickers()),
            onRemove: () => _removeSticker(sticker.id),
          ),
        );
      }).toList(),
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
                            child: GestureDetector(
                              onTap: () => _selectSticker(null),
                              child: ColoringCanvas(
                                canvasKey: _canvasKey,
                                paintOutline: painter,
                                regionMask: _regionMask,
                                stickerOverlay: _buildStickerOverlay(),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // --- 4. Toolbar + size ---
                      DrawingToolbar(onResetRequested: _confirmReset),
                      const SizedBox(height: 8),
                      const BrushTypeSelector(),
                      const SizedBox(height: 8),
                      const BrushSizeSelector(),

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
                          const SizedBox(width: 8),
                          // "Stickers" button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _openStickerPanel,
                              icon: const Icon(
                                Icons.emoji_emotions_rounded,
                                size: 18,
                              ),
                              label: const Text('Stickers'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: PWColors.yellow,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // "Save" button
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
                                : const Icon(Icons.camera_alt_rounded),
                            label: const Text('Save'),
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

// ---------------------------------------------------------------------------
// Sticker picker bottom sheet for coloring pages.
// ---------------------------------------------------------------------------

class _ColoringStickerPanel extends ConsumerWidget {
  const _ColoringStickerPanel({
    required this.countryId,
    required this.onStickerSelected,
  });

  final String countryId;
  final void Function(StickerItem item) onStickerSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stickerState = ref.watch(stickerProvider);

    // Show both general stickers and country-specific stickers.
    final generalStickers = stickerState.stickersForCountry('general');
    final countryStickers = stickerState.stickersForCountry(countryId);
    final allStickers = [...countryStickers, ...generalStickers];
    final collected =
        allStickers.where((s) => stickerState.isCollected(s.id)).toList();
    final lockedCount = allStickers.length - collected.length;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFD9E3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'My Stickers',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap a sticker to place it on your coloring page.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF708499),
              ),
            ),
            const SizedBox(height: 10),
            if (collected.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: PWColors.navy.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      '\u{1F31F}',
                      style: TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No stickers yet!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: PWColors.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Complete stories, cook recipes, and play games\n'
                      'to earn stickers you can use here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: PWColors.navy.withValues(alpha: 0.5),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 280,
                child: GridView.builder(
                  itemCount: collected.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.92,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final sticker = collected[index];
                    final item = StickerItem(
                      id: sticker.id,
                      label: sticker.label,
                      emoji: sticker.emoji,
                      assetPath: sticker.assetPath,
                    );
                    return StickerCard(
                      sticker: item,
                      onTap: () {
                        onStickerSelected(item);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            if (lockedCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: PWColors.yellow.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PWColors.yellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      '\u{1F513}',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$lockedCount more sticker${lockedCount == 1 ? '' : 's'} to earn! '
                        'Complete activities to unlock them.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: PWColors.navy.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Editable sticker placed on the coloring canvas.
// ---------------------------------------------------------------------------

class _EditableColoringSticker extends StatefulWidget {
  const _EditableColoringSticker({
    required this.sticker,
    required this.selected,
    required this.onSelected,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onRemove,
  });

  final StickerInstance sticker;
  final bool selected;
  final VoidCallback onSelected;
  final void Function(Offset position, double scale, double rotation) onChanged;
  final VoidCallback onChangeEnd;
  final VoidCallback onRemove;

  @override
  State<_EditableColoringSticker> createState() =>
      _EditableColoringStickerState();
}

class _EditableColoringStickerState extends State<_EditableColoringSticker> {
  Offset _startPosition = Offset.zero;
  double _startScale = 1;
  double _startRotation = 0;
  Offset _startFocal = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final size = 112 * widget.sticker.scale;

    return GestureDetector(
      onTap: widget.onSelected,
      onDoubleTap: widget.onRemove,
      onScaleStart: (details) {
        widget.onSelected();
        _startPosition = widget.sticker.position;
        _startScale = widget.sticker.scale;
        _startRotation = widget.sticker.rotation;
        _startFocal = details.focalPoint;
      },
      onScaleUpdate: (details) {
        final delta = details.focalPoint - _startFocal;
        widget.onChanged(
          _startPosition + delta,
          (_startScale * details.scale).clamp(0.35, 3.0).toDouble(),
          _startRotation + details.rotation,
        );
      },
      onScaleEnd: (_) => widget.onChangeEnd(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: widget.selected
              ? Border.all(color: const Color(0xFF2F3A4A), width: 2)
              : null,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: Center(
          child: Transform.rotate(
            angle: widget.sticker.rotation,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final scale = widget.sticker.scale;
    final path = widget.sticker.assetPath;
    if (path != null && path.isNotEmpty) {
      final imgSize = 80.0 * scale;
      return Image.asset(
        path,
        width: imgSize,
        height: imgSize,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(
          widget.sticker.emoji,
          style: TextStyle(fontSize: 44 * scale),
        ),
      );
    }
    return Text(
      widget.sticker.emoji,
      style: TextStyle(fontSize: 44 * scale),
    );
  }
}
