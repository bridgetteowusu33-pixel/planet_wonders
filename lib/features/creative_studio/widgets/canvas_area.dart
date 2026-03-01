// File: lib/features/creative_studio/widgets/canvas_area.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../coloring_engine/core/spline_path.dart';
import '../creative_controller.dart';
import '../creative_state.dart';

class CanvasArea extends ConsumerStatefulWidget {
  const CanvasArea({super.key, required this.repaintKey, this.backgroundPainter});

  final GlobalKey repaintKey;
  final CustomPainter? backgroundPainter;

  @override
  ConsumerState<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends ConsumerState<CanvasArea> {
  static const double _sceneSize = 1200;

  final GlobalKey _viewportKey = GlobalKey();

  bool _isDrawing = false;
  double _scale = 1;
  Offset _offset = Offset.zero;

  double _startScale = 1;
  Offset _startSceneFocal = Offset.zero;

  Offset _toScene(Offset local) {
    final dx = (local.dx - _offset.dx) / _scale;
    final dy = (local.dy - _offset.dy) / _scale;
    return Offset(dx.clamp(0, _sceneSize), dy.clamp(0, _sceneSize));
  }

  @override
  Widget build(BuildContext context) {
    final tool = ref.watch(
      creativeControllerProvider.select((state) => state.tool),
    );
    final currentColor = ref.watch(
      creativeControllerProvider.select((state) => state.currentColor),
    );
    final sceneId = ref.watch(
      creativeControllerProvider.select((state) => state.sceneId),
    );
    final canvasColor = ref.watch(
      creativeControllerProvider.select((state) => state.canvasColor),
    );
    final strokes = ref.watch(
      creativeControllerProvider.select((state) => state.strokes),
    );
    final activeStroke = ref.watch(
      creativeControllerProvider.select((state) => state.activeStroke),
    );
    final stickers = ref.watch(
      creativeControllerProvider.select((state) => state.stickers),
    );
    final selectedStickerId = ref.watch(
      creativeControllerProvider.select((state) => state.selectedStickerId),
    );
    final controller = ref.read(creativeControllerProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        return DragTarget<StickerItem>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) {
            final renderBox =
                _viewportKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox == null) return;
            final localPoint = renderBox.globalToLocal(details.offset);
            controller.addSticker(details.data, position: _toScene(localPoint));
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              key: _viewportKey,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDCE6F0), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => controller.selectSticker(null),
                  onScaleStart: (details) {
                    if (details.pointerCount > 1) {
                      if (_isDrawing) {
                        _isDrawing = false;
                        controller.endStroke();
                      }

                      _startScale = _scale;
                      _startSceneFocal = _toScene(details.localFocalPoint);
                      return;
                    }

                    if (tool == CreativeTool.fill) {
                      controller.fillCanvas(currentColor);
                      return;
                    }

                    _isDrawing = true;
                    controller.startStroke(_toScene(details.localFocalPoint));
                  },
                  onScaleUpdate: (details) {
                    if (details.pointerCount > 1) {
                      if (_isDrawing) {
                        _isDrawing = false;
                        controller.endStroke();
                      }

                      final nextScale = (_startScale * details.scale)
                          .clamp(1.0, 4.0)
                          .toDouble();
                      final nextOffset =
                          details.localFocalPoint -
                          (_startSceneFocal * nextScale);

                      setState(() {
                        _scale = nextScale;
                        _offset = nextOffset;
                      });
                      return;
                    }

                    if (!_isDrawing) return;
                    controller.updateStroke(_toScene(details.localFocalPoint));
                  },
                  onScaleEnd: (_) {
                    if (_isDrawing) {
                      _isDrawing = false;
                      controller.endStroke();
                    }
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Transform.translate(
                          offset: _offset,
                          child: RepaintBoundary(
                            key: widget.repaintKey,
                            child: Transform.scale(
                              scale: _scale,
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                width: _sceneSize,
                                height: _sceneSize,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: _buildSceneDecoration(
                                          sceneId: sceneId,
                                          canvasColor: canvasColor,
                                        ),
                                      ),
                                    ),
                                    if (widget.backgroundPainter != null)
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: widget.backgroundPainter,
                                        ),
                                      ),
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _StrokeLayerPainter(
                                          strokes: strokes,
                                          activeStroke: activeStroke,
                                        ),
                                      ),
                                    ),
                                    ...stickers.map(
                                      (sticker) => Positioned(
                                        left: sticker.position.dx - 56,
                                        top: sticker.position.dy - 56,
                                        child: _EditableSticker(
                                          sticker: sticker,
                                          selected:
                                              selectedStickerId == sticker.id,
                                          canvasScale: _scale,
                                          onSelected: () => controller
                                              .selectSticker(sticker.id),
                                          onChanged:
                                              (position, scale, rotation) =>
                                                  controller
                                                      .updateStickerTransform(
                                                        stickerId: sticker.id,
                                                        position: position,
                                                        scale: scale,
                                                        rotation: rotation,
                                                      ),
                                          onChangeStart:
                                              controller.beginStickerTransform,
                                          onChangeEnd:
                                              controller.commitStickerTransform,
                                          onRemove: () => controller
                                              .removeSticker(sticker.id),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${(_scale * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (candidateData.isNotEmpty)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              border: Border.all(
                                color: const Color(0xFF6EC6E9),
                                width: 3,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Drop sticker here',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Decoration _buildSceneDecoration({
    required String? sceneId,
    required Color canvasColor,
  }) {
    SceneOption? scene;
    if (sceneId != null) {
      for (final option in kSceneOptions) {
        if (option.id == sceneId) {
          scene = option;
          break;
        }
      }
    }

    if (scene != null) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: scene.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    return BoxDecoration(color: canvasColor);
  }
}

class _StrokeLayerPainter extends CustomPainter {
  _StrokeLayerPainter({required this.strokes, required this.activeStroke});

  final List<CreativeStroke> strokes;
  final CreativeStroke? activeStroke;

  @override
  void paint(Canvas canvas, Size size) {
    final usesEraser =
        (activeStroke?.isEraser ?? false) ||
        strokes.any((stroke) => stroke.isEraser);
    if (usesEraser) {
      canvas.saveLayer(Offset.zero & size, Paint());
    }

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..isAntiAlias = true
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.width
        ..color = stroke.color
        ..blendMode = stroke.isEraser ? BlendMode.clear : BlendMode.srcOver;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.width / 2, paint);
        continue;
      }

      final path = buildSplinePath(stroke.points);
      canvas.drawPath(path, paint);
    }

    final active = activeStroke;
    if (active != null && active.points.isNotEmpty) {
      final paint = Paint()
        ..isAntiAlias = true
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = active.width
        ..color = active.color
        ..blendMode = active.isEraser ? BlendMode.clear : BlendMode.srcOver;

      if (active.points.length == 1) {
        canvas.drawCircle(active.points.first, active.width / 2, paint);
      } else {
        final path = buildSplinePath(active.points);
        canvas.drawPath(path, paint);
      }
    }

    if (usesEraser) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _StrokeLayerPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.activeStroke != activeStroke;
  }
}

class _EditableSticker extends StatefulWidget {
  const _EditableSticker({
    required this.sticker,
    required this.selected,
    required this.canvasScale,
    required this.onSelected,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onRemove,
  });

  final StickerInstance sticker;
  final bool selected;
  final double canvasScale;
  final VoidCallback onSelected;
  final VoidCallback onChangeStart;
  final void Function(Offset position, double scale, double rotation) onChanged;
  final VoidCallback onChangeEnd;
  final VoidCallback onRemove;

  @override
  State<_EditableSticker> createState() => _EditableStickerState();
}

class _EditableStickerState extends State<_EditableSticker> {
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
        widget.onChangeStart();
        _startPosition = widget.sticker.position;
        _startScale = widget.sticker.scale;
        _startRotation = widget.sticker.rotation;
        _startFocal = details.focalPoint;
      },
      onScaleUpdate: (details) {
        final deltaScene =
            (details.focalPoint - _startFocal) / widget.canvasScale;
        widget.onChanged(
          _startPosition + deltaScene,
          (_startScale * details.scale).clamp(0.35, 3.0).toDouble(),
          _startRotation + details.rotation,
        );
      },
      onScaleEnd: (_) {
        widget.onChangeEnd();
      },
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
            child: _buildStickerContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStickerContent() {
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
