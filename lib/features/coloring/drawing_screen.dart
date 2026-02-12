import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/gallery_service.dart';
import '../../core/theme/pw_theme.dart';
import 'widgets/brush_size_selector.dart';
import 'widgets/color_palette.dart';
import 'widgets/drawing_canvas.dart';
import 'widgets/drawing_toolbar.dart';

/// Full-screen free-draw experience.
///
/// Opens outside the bottom-nav shell so kids get maximum canvas space.
/// Save button captures the canvas via RepaintBoundary → PNG → gallery.
class DrawingScreen extends ConsumerStatefulWidget {
  const DrawingScreen({super.key});

  @override
  ConsumerState<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends ConsumerState<DrawingScreen> {
  final _canvasKey = GlobalKey();
  bool _saving = false;

  Future<void> _saveDrawing() async {
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to Gallery!'),
            backgroundColor: PWColors.mint,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save drawing')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Let's Draw!",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saving ? null : _saveDrawing,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            tooltip: 'Save to Gallery',
            color: PWColors.navy,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // --- canvas ---
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
                  child: DrawingCanvas(canvasKey: _canvasKey),
                ),
              ),

              const SizedBox(height: 12),

              // --- tools + size ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const DrawingToolbar(),
                  const SizedBox(width: 16),
                  const BrushSizeSelector(),
                ],
              ),

              const SizedBox(height: 12),

              // --- colors ---
              const ColorPalette(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
