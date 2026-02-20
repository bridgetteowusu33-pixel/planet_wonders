// File: lib/features/draw_with_me/ui/decorate_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../creative_studio/canvas_screen.dart';
import '../../creative_studio/creative_state.dart';
import '../engine/trace_engine.dart';
import '../models/trace_shape.dart';

class DecorateScreen extends ConsumerStatefulWidget {
  const DecorateScreen({
    super.key,
    required this.packId,
    required this.shapeId,
  });

  final String packId;
  final String shapeId;

  @override
  ConsumerState<DecorateScreen> createState() => _DecorateScreenState();
}

class _DecorateScreenState extends ConsumerState<DecorateScreen> {
  TraceShape? _shape;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadShape();
  }

  Future<void> _loadShape() async {
    try {
      final engine = ref.read(traceEngineProvider);
      final shape = await engine.loadShape(
        packId: widget.packId,
        shapeId: widget.shapeId,
      );
      if (!mounted) return;
      setState(() {
        _shape = shape;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return CreativeCanvasScreen(
      mode: CreativeEntryMode.freeDraw,
      projectId: 'trace_decorate_${widget.packId}_${widget.shapeId}',
      backgroundPainter: _shape != null
          ? _TraceOutlinePainter(shape: _shape!)
          : null,
    );
  }
}

/// Paints the traced shape outline as a faint guide behind the free-draw canvas.
class _TraceOutlinePainter extends CustomPainter {
  _TraceOutlinePainter({required this.shape});

  final TraceShape shape;

  @override
  void paint(Canvas canvas, Size size) {
    final source = shape.viewBox;
    final scaleX = size.width / source.width;
    final scaleY = size.height / source.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final drawWidth = source.width * scale;
    final drawHeight = source.height * scale;
    final dx = (size.width - drawWidth) / 2;
    final dy = (size.height - drawHeight) / 2;

    final matrix = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFBBCCDD);

    for (final segment in shape.segments) {
      final path = parseSvgPathData(segment.pathData)
          .transform(matrix.storage);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TraceOutlinePainter oldDelegate) {
    return oldDelegate.shape != shape;
  }
}
