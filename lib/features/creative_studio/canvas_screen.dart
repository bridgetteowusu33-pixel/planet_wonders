// File: lib/features/creative_studio/canvas_screen.dart
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/gallery_service.dart';
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

  Future<void> _openColorPanel() async {
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
            style: Theme.of(context).textTheme.titleLarge,
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
            IconButton(
              onPressed: _exporting ? null : _exportToGallery,
              icon: _exporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              tooltip: 'Save to My Art',
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: creativeState.isLoaded
                ? Column(
                    children: [
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
                      Expanded(
                        child: CanvasArea(
                          repaintKey: _canvasRepaintKey,
                          backgroundPainter: widget.backgroundPainter,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.tune_rounded, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Brush',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Expanded(
                            child: Slider(
                              value: creativeState.brushSize,
                              min: 2,
                              max: 32,
                              divisions: 15,
                              label: creativeState.brushSize.round().toString(),
                              onChanged: controller.setBrushSize,
                            ),
                          ),
                          Text(
                            '${creativeState.brushSize.round()} px',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Draw with one finger. Pinch with two fingers to zoom/pan up to 4x.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PWColors.navy.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CreativeToolbar(
                        onOpenColors: _openColorPanel,
                        onOpenStickers: _openStickerPanel,
                        onOpenBackgrounds: _openBackgroundPanel,
                        onReset: _confirmReset,
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
