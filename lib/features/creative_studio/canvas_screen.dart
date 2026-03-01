// File: lib/features/creative_studio/canvas_screen.dart
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../coloring/color_button.dart';
import '../../core/services/gallery_service.dart';
import '../stickers/providers/sticker_provider.dart';
import '../../core/theme/pw_theme.dart';
import 'background_panel.dart';
import 'color_panel.dart';
import 'creative_controller.dart';
import 'creative_state.dart';
import 'sticker_panel.dart';
import 'widgets/canvas_area.dart';
import 'widgets/toolbar.dart';

class CreativeCanvasScreen extends ConsumerStatefulWidget {
  const CreativeCanvasScreen({
    super.key,
    required this.mode,
    this.promptId,
    this.sceneId,
    this.projectId,
    this.backgroundPainter,
  });

  final CreativeEntryMode mode;
  final String? promptId;
  final String? sceneId;
  final String? projectId;
  final CustomPainter? backgroundPainter;

  @override
  ConsumerState<CreativeCanvasScreen> createState() =>
      _CreativeCanvasScreenState();
}

class _CreativeCanvasScreenState extends ConsumerState<CreativeCanvasScreen>
    with WidgetsBindingObserver {
  final GlobalKey _canvasRepaintKey = GlobalKey();
  late final CreativeController _controller;

  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ref.read(creativeControllerProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadProject(
        mode: widget.mode,
        promptId: widget.promptId,
        sceneId: widget.sceneId,
        projectOverride: widget.projectId,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.saveNow(updateSavingState: false));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_controller.saveNow(updateSavingState: false));
    }
  }

  Future<void> _openMoreColors() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ColorPanel(),
    );
  }

  Future<void> _openStickerPanel() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StickerPanel(),
    );
  }

  Future<void> _openBackgroundPanel() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BackgroundPanel(),
    );
  }

  Future<void> _confirmReset() async {
    final shouldReset =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Start over?'),
            content: const Text(
              'Your drawing, stickers, and colors will be erased.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: PWColors.coral),
                child: const Text('Reset'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldReset) return;
    await _controller.resetCanvas();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Canvas reset')));
  }

  Future<void> _exportToGallery() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    try {
      final boundary =
          _canvasRepaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;

      await GalleryService.saveDrawing(bytes.buffer.asUint8List());
      ref.invalidate(galleryProvider);
      await _controller.saveNow(updateSavingState: false);

      ref.read(stickerProvider.notifier).checkAndAward(
        conditionType: 'drawing_saved',
        countryId: '',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved to My Art')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not save artwork')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final creativeState = ref.watch(creativeControllerProvider);
    final controller = ref.read(creativeControllerProvider.notifier);

    final prompt = creativeState.promptId == null
        ? null
        : controller.promptById(creativeState.promptId!);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        await _controller.saveNow(updateSavingState: false);
        if (!mounted) return;
        navigator.pop(result);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            creativeState.canvasTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (creativeState.isSaving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: creativeState.isLoaded
                ? Column(
                    children: [
                      // --- 1. Prompt card (optional) ---
                      if (prompt != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF7FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFB8DFF6),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(prompt.icon, color: PWColors.navy),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Idea: ${prompt.title} - ${prompt.subtitle}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // --- 2. Inline color palette bar ---
                      _CreativePaletteBar(
                        colors: kDefaultCreativePalette,
                        activeColor: creativeState.currentColor,
                        onColorSelected: controller.selectColor,
                        onMoreColors: _openMoreColors,
                      ),

                      const SizedBox(height: 10),

                      // --- 3. Canvas ---
                      Expanded(
                        child: CanvasArea(
                          repaintKey: _canvasRepaintKey,
                          backgroundPainter: widget.backgroundPainter,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // --- 4. Toolbar (horizontal scroll) ---
                      CreativeToolbar(
                        onResetRequested: _confirmReset,
                      ),

                      const SizedBox(height: 6),

                      // --- 5. Brush type (horizontal scroll) ---
                      const CreativeBrushTypeSelector(),

                      const SizedBox(height: 6),

                      // --- 6. Brush size (horizontal scroll) ---
                      const CreativeBrushSizeSelector(),

                      const SizedBox(height: 10),

                      // --- 5. Bottom actions ---
                      Row(
                        children: [
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
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _openBackgroundPanel,
                              icon: const Icon(
                                Icons.landscape_rounded,
                                size: 18,
                              ),
                              label: const Text('Scenes'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: PWColors.navy.withValues(alpha: 0.15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: _exporting ? null : _exportToGallery,
                            icon: _exporting
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
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline horizontal palette bar matching coloring pages' PaletteBar.
// ---------------------------------------------------------------------------

class _CreativePaletteBar extends StatelessWidget {
  const _CreativePaletteBar({
    required this.colors,
    required this.activeColor,
    required this.onColorSelected,
    required this.onMoreColors,
  });

  final List<Color> colors;
  final Color activeColor;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onMoreColors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: colors.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 2),
        itemBuilder: (context, index) {
          if (index == colors.length) {
            return _MoreColorsButton(onTap: onMoreColors);
          }

          final color = colors[index];
          final isSelected = color.toARGB32() == activeColor.toARGB32();
          return PaletteColorButton(
            color: color,
            selected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              onColorSelected(color);
            },
            semanticLabel: 'Color ${index + 1}',
          );
        },
      ),
    );
  }
}

class _MoreColorsButton extends StatelessWidget {
  const _MoreColorsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Semantics(
        button: true,
        label: 'More colors',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCFD8DC), width: 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 22,
              color: Color(0xFF37474F),
            ),
          ),
        ),
      ),
    );
  }
}
