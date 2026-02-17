// File: lib/features/draw_with_me/ui/decorate_screen.dart
import 'package:flutter/widgets.dart';

import '../../creative_studio/canvas_screen.dart';
import '../../creative_studio/creative_state.dart';

class DecorateScreen extends StatelessWidget {
  const DecorateScreen({
    super.key,
    required this.packId,
    required this.shapeId,
  });

  final String packId;
  final String shapeId;

  @override
  Widget build(BuildContext context) {
    return CreativeCanvasScreen(
      mode: CreativeEntryMode.freeDraw,
      projectId: 'trace_decorate_${packId}_$shapeId',
    );
  }
}
