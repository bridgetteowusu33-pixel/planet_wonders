# Pro Coloring Engine — Implementation Plan

## Executive Summary

This plan transforms Planet Wonders' coloring system from a basic pixel-flood-fill implementation into a **production-quality, App Store-ready coloring engine** with:

- ✅ **Region-based mask fill** (leak-proof, instant)
- ✅ **Three brush types** (Marker, Crayon, Soft Brush)
- ✅ **Action-based undo/redo**
- ✅ **Pinch-to-zoom** up to 4x with pan
- ✅ **Layered non-destructive rendering**
- ✅ **Optimized for low-RAM devices**

---

## Implementation Approach

### User Requirements (Confirmed)
1. **Pre-generated region mask files** — offline preprocessing workflow
2. **Priority: Fill → Brushes → Zoom** — phased rollout
3. **Replace existing system in-place** — refactor `lib/features/coloring/`
4. **Production quality** — no toy examples, App Store ready

### Current System Issues
- Basic BFS flood-fill (leaks on anti-aliased edges)
- No undo/redo
- No zoom/pan
- Memory leaks (`ui.Image` not disposed)
- Performance issues (`shouldRepaint` always true)
- Only one brush type

---

## Phase 1: Region Fill System (Week 1)

### 1.1 Mask File Format

**Design**: Single-channel (grayscale) PNG where pixel value = region ID
- Value `0` = outline/border (not fillable)
- Values `1-255` = distinct fillable regions
- Same dimensions as outline image (1024×1024)
- ~30-80 KB per mask (8-bit grayscale compresses well)

**Asset Structure**:
```
assets/coloring/usa/masks/
  usa_01_map_mask.png
  usa_02_mountains_mask.png
  ... (15 files)
assets/coloring/ghana/masks/
  kente_mask.png
  ... (4 files, generated from programmatic outlines)
```

### 1.2 Mask Generation Tooling

**File to create**: `tools/generate_masks.py`

Python script using OpenCV:
```python
# Input: outline PNG (black lines on white)
# Process:
#   1. Convert to grayscale
#   2. Threshold to binary (black lines = foreground)
#   3. Dilate lines by 1-2px to seal anti-aliased gaps
#   4. Invert (white regions become foreground)
#   5. connectedComponents() labels each region with unique ID
#   6. Output single-channel PNG (pixel value = region ID)
```

For Ghana programmatic pages: First rasterize `CustomPainter` to PNG via Flutter test, then run mask generator.

### 1.3 Core Implementation

**Files to CREATE**:

1. **`lib/features/coloring/painters/region_mask.dart`** — Region mask loader and lookup
   ```dart
   class RegionMask {
     final int width, height;
     final Uint8List pixels;  // single-channel, O(1) lookup

     int regionAt(int x, int y);
     Set<int> get allRegions;
     Rect boundsForRegion(int regionId);
   }

   Future<RegionMask> loadRegionMask(String assetPath);
   ```

2. **`lib/features/coloring/painters/region_fill_painter.dart`** — Fill layer renderer
   ```dart
   void paintRegionFills(
     Canvas canvas,
     Size canvasSize, {
     required RegionMask mask,
     required Map<int, Color> regionFills,
   });
   ```
   Uses scanline rendering: iterate mask rows, find horizontal runs of matching region ID, draw as rectangles.

**Files to MODIFY**:

1. **`lib/features/coloring/models/coloring_page.dart`** — Add `maskAsset` field
   ```dart
   class ColoringPage {
     final String? maskAsset;  // NEW: 'assets/coloring/usa/masks/...'
   }
   ```

2. **`lib/features/coloring/models/drawing_state.dart`** — Full rewrite to action-based model
   ```dart
   sealed class DrawingAction {}
   class StrokeAction extends DrawingAction { final Stroke stroke; }
   class RegionFillAction extends DrawingAction { final int regionId; final Color color; }

   class DrawingState {
     final List<DrawingAction> actions;       // undo stack
     final List<DrawingAction> redoStack;     // redo stack

     Map<int, Color> get regionFills { ... }  // derived from actions
     List<Stroke> get strokes { ... }         // derived from actions
   }
   ```
   **Key change**: Fills are lightweight `(regionId, color)` data, not GPU-resident `ui.Image`.

3. **`lib/features/coloring/providers/drawing_provider.dart`** — Rewrite for new state
   ```dart
   void fillRegion(int regionId, Color color) {
     state = state.copyWith(
       actions: [...state.actions, RegionFillAction(regionId: regionId, color: color)],
       redoStack: [],  // new action clears redo
     );
   }

   void undo() { /* pop from actions, push to redoStack */ }
   void redo() { /* pop from redoStack, push to actions */ }
   ```

4. **`lib/features/coloring/widgets/coloring_canvas.dart`** — Update fill tap handler
   ```dart
   void _handleFillTap(Offset localPosition) {
     // Convert tap coords to mask coords
     final mx = (localPosition.dx / canvasSize.width * mask.width).round();
     final my = (localPosition.dy / canvasSize.height * mask.height).round();

     final regionId = mask.regionAt(mx, my);
     if (regionId == 0) return;  // tapped outline, ignore

     ref.read(drawingProvider.notifier).fillRegion(regionId, color);
   }
   ```
   **Instant fill** — no async, no bitmap capture, no BFS. Just array lookup.

5. **`lib/features/coloring/data/coloring_data.dart`** — Add `maskAsset` to all 15 USA pages
   ```dart
   ColoringPage(
     id: 'map',
     outlineAsset: 'assets/coloring/usa/nature/usa_01_map.png',
     maskAsset: 'assets/coloring/usa/masks/usa_01_map_mask.png',  // NEW
   ),
   ```

6. **`pubspec.yaml`** — Add mask directories
   ```yaml
   assets:
     - assets/coloring/usa/masks/
     - assets/coloring/ghana/masks/
   ```

**Files to DELETE**:
- **`lib/features/coloring/painters/flood_fill.dart`** — replaced entirely by region mask system

### 1.4 Testing
- Unit test: `RegionMask.regionAt()` with synthetic 10×10 mask
- Unit test: Action-based undo/redo state transitions
- Widget test: Fill tap → verify `fillRegion` called with correct region ID
- Integration test: Load real USA mask, tap regions, verify fills render

### 1.5 Performance Risks
| Risk | Mitigation |
|------|-----------|
| Mask loading adds startup time | Load mask in parallel with outline image |
| Scanline fill slow for many regions | Acceptable for <40 regions; cache if needed |
| 1MB raw bytes in memory | Only one mask loaded at a time (autoDispose) |

---

## Phase 2: Brush System (Week 2, Days 1-3)

### 2.1 Brush Abstraction

**Files to CREATE**:

1. **`lib/features/coloring/painters/brushes/brush.dart`** — Abstract interface
   ```dart
   abstract class Brush {
     Paint createPaint(Color color, double width);
     Path modifyPath(Path path) => path;  // optional jitter/texture
     String get displayName;
     IconData get icon;
   }
   ```

2. **`lib/features/coloring/painters/brushes/marker_brush.dart`** — Default smooth marker
   ```dart
   class MarkerBrush extends Brush {
     Paint createPaint(Color color, double width) => Paint()
       ..color = color
       ..strokeWidth = width
       ..strokeCap = StrokeCap.round
       ..strokeJoin = StrokeJoin.round;
   }
   ```

3. **`lib/features/coloring/painters/brushes/crayon_brush.dart`** — Textured crayon
   ```dart
   class CrayonBrush extends Brush {
     Paint createPaint(Color color, double width) => Paint()
       ..color = color.withValues(alpha: 0.85)
       ..strokeWidth = width * 1.3
       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.8);

     Path modifyPath(Path path) => _addJitter(path, amplitude: 0.5);
   }
   ```

4. **`lib/features/coloring/painters/brushes/soft_brush.dart`** — Watercolor-like
   ```dart
   class SoftBrush extends Brush {
     Paint createPaint(Color color, double width) => Paint()
       ..color = color.withValues(alpha: 0.3)
       ..strokeWidth = width * 2.0
       ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 0.4);
   }
   ```

5. **`lib/features/coloring/painters/brushes/brush_registry.dart`** — Brush lookup
   ```dart
   const brushes = <BrushType, Brush>{
     BrushType.marker: MarkerBrush(),
     BrushType.crayon: CrayonBrush(),
     BrushType.softBrush: SoftBrush(),
   };
   ```

6. **`lib/features/coloring/widgets/brush_picker.dart`** — Horizontal picker UI
   - Three circular buttons (Marker, Crayon, Soft)
   - Active brush gets blue highlight ring
   - Shown below toolbar when brush tool active

**Files to MODIFY**:

1. **`lib/features/coloring/models/drawing_state.dart`** — Add `BrushType` enum
   ```dart
   enum BrushType { marker, crayon, softBrush }

   class Stroke {
     final BrushType brushType;  // NEW
     final bool isEraser;         // NEW: explicit flag
   }
   ```

2. **`lib/features/coloring/painters/stroke_painter.dart`** — Use brush abstraction
   ```dart
   void _paintStroke(Canvas canvas, Stroke stroke) {
     if (stroke.isEraser) { _paintEraserStroke(canvas, stroke); return; }

     final brush = brushes[stroke.brushType] ?? MarkerBrush();
     final paint = brush.createPaint(stroke.color, stroke.width);
     final path = brush.modifyPath(_buildStrokePath(stroke.points));

     canvas.drawPath(path, paint);
   }
   ```

3. **`lib/features/coloring/widgets/drawing_toolbar.dart`** — Add redo button, brush picker toggle

### 2.2 Testing
- Unit test: Each `Brush.createPaint()` verifies color, width, alpha
- Golden test: Render known stroke path with each brush, compare to golden PNG
- Widget test: Brush picker tap → verify provider state change

### 2.3 Performance Risks
| Risk | Mitigation |
|------|-----------|
| Crayon jitter adds points | Decimate input points via Douglas-Peucker |
| Soft brush blur expensive | Cache completed strokes as `ui.Image` (Phase 4) |

---

## Phase 3: Zoom & Pan (Week 2, Days 4-5)

### 3.1 InteractiveViewer Integration

**Files to CREATE**:

1. **`lib/features/coloring/providers/zoom_provider.dart`** — Zoom state (optional)
   ```dart
   class ZoomState {
     final double scale;
     final Offset translation;
     bool get isZoomed => scale > 1.05;
   }
   ```

2. **`lib/features/coloring/widgets/zoom_indicator.dart`** — Floating "2.0x" badge
   - Shows current zoom level
   - Tap to reset to 1.0x
   - Fades out after 2s inactivity

**Files to MODIFY**:

1. **`lib/features/coloring/widgets/coloring_canvas.dart`** — Wrap in `InteractiveViewer`
   ```dart
   InteractiveViewer(
     transformationController: _transformController,
     minScale: 1.0,
     maxScale: 4.0,
     child: GestureDetector(
       onPanStart: (d) {
         final canvasPoint = _screenToCanvas(d.localPosition);
         ref.read(drawingProvider.notifier).startStroke(canvasPoint);
       },
     ),
   )
   ```

2. **Coordinate transform handling**:
   ```dart
   Offset _screenToCanvas(Offset screenPoint) {
     final inverse = Matrix4.inverted(_transformController.value);
     final vector = inverse.transform3(Vector3(screenPoint.dx, screenPoint.dy, 0));
     return Offset(vector.x, vector.y);
   }
   ```
   All touch events (draw + fill tap) must use this transform.

3. **Auto-zoom on fill** (optional):
   ```dart
   void _autoZoomToRegion(int regionId) {
     final bounds = _regionMask.boundsForRegion(regionId);
     // Animate to 2x zoom centered on region
     _transformController.value = _computeTransformForBounds(bounds);
   }
   ```

### 3.2 Testing
- Widget test: Verify zoom limits (1x-4x)
- Unit test: `_screenToCanvas` correctness at various zoom levels
- Integration test: Draw stroke while zoomed, undo, verify coordinates

### 3.3 Performance Risks
| Risk | Mitigation |
|------|-----------|
| Repainting at 4x zoom expensive | Canvas stays at base resolution; zoom is just transform |
| Pan gesture conflicts with draw | Only pan with 2 fingers; 1 finger always draws |

---

## Phase 4: Performance & Polish (Week 3)

### 4.1 PictureRecorder Caching

**File to CREATE**: `lib/features/coloring/painters/canvas_cache.dart`

```dart
class CanvasCache {
  ui.Image? _cachedStrokes;
  int _cachedStrokeCount = 0;

  Future<ui.Image?> getStrokeCache(List<Stroke> strokes, Size size) async {
    if (strokes.length == _cachedStrokeCount && _cachedStrokes != null) {
      return _cachedStrokes;
    }

    // Render all strokes to image via PictureRecorder
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paintStrokes(canvas, size, strokes: strokes);
    final picture = recorder.endRecording();

    _cachedStrokes?.dispose();
    _cachedStrokes = await picture.toImage(size.width.ceil(), size.height.ceil());
    _cachedStrokeCount = strokes.length;

    return _cachedStrokes;
  }
}
```

**Key insight**: When stroke is completed, flatten all strokes into cached `ui.Image`. Only active (in-progress) stroke needs real-time rendering.

### 4.2 Fix shouldRepaint

**File to modify**: `lib/features/coloring/widgets/coloring_canvas.dart`

```dart
@override
bool shouldRepaint(covariant _ColoringPainter old) {
  return old.activeStroke != activeStroke ||
      old.strokes.length != strokes.length ||
      old.regionFills != regionFills;
}
```

### 4.3 Proper ui.Image Disposal

- Add `CanvasCache.dispose()` in widget's `dispose()`
- Region fills are data-only (no `ui.Image`), so no GPU leak
- AutoDispose on provider releases everything on navigation

### 4.4 Paper Texture Overlay (Optional)

**File to create**: `assets/textures/paper_grain.png` (256×256 seamless)

```dart
// Apply as subtle overlay on white background
if (_paperTexture != null) {
  final shader = ImageShader(_paperTexture!, TileMode.repeated, TileMode.repeated, Matrix4.identity().storage);
  canvas.drawRect(bounds, Paint()
    ..shader = shader
    ..blendMode = BlendMode.multiply
    ..color = Colors.white.withValues(alpha: 0.05));
}
```

### 4.5 Low-RAM Optimization
- Mask is `Uint8List` (1MB), not `ui.Image`
- Fill cache uses `Picture.toImage` (GPU-resident)
- Stroke cache is single `ui.Image`, not one per stroke
- AutoDispose releases everything on navigation

### 4.6 Testing
- **Memory profiling**: Use DevTools to verify no `ui.Image` leaks after 10 screen navigations
- **Performance test**: Measure frame times with 20 filled regions + 50 strokes at 4x zoom
- **shouldRepaint unit test**: Verify returns false when nothing changed

---

## Complete File Inventory

### FILES TO CREATE (13 new)
1. `lib/features/coloring/painters/region_mask.dart`
2. `lib/features/coloring/painters/region_fill_painter.dart`
3. `lib/features/coloring/painters/brushes/brush.dart`
4. `lib/features/coloring/painters/brushes/marker_brush.dart`
5. `lib/features/coloring/painters/brushes/crayon_brush.dart`
6. `lib/features/coloring/painters/brushes/soft_brush.dart`
7. `lib/features/coloring/painters/brushes/brush_registry.dart`
8. `lib/features/coloring/painters/canvas_cache.dart`
9. `lib/features/coloring/widgets/brush_picker.dart`
10. `lib/features/coloring/widgets/zoom_indicator.dart`
11. `lib/features/coloring/providers/zoom_provider.dart`
12. `tools/generate_masks.py`
13. `assets/coloring/usa/masks/*.png` (15 mask files)

### FILES TO MODIFY (8 existing)
1. `lib/features/coloring/models/coloring_page.dart` — Add `maskAsset` field
2. `lib/features/coloring/models/drawing_state.dart` — **Full rewrite**: action-based, redo, brush types
3. `lib/features/coloring/providers/drawing_provider.dart` — **Full rewrite**: redo, fillRegion, brush types
4. `lib/features/coloring/painters/stroke_painter.dart` — Use Brush abstraction
5. `lib/features/coloring/widgets/coloring_canvas.dart` — **Full rewrite**: InteractiveViewer, mask fill, caching
6. `lib/features/coloring/widgets/drawing_toolbar.dart` — Add redo button, brush picker
7. `lib/features/coloring/screens/coloring_page_screen.dart` — Load mask, wire zoom
8. `lib/features/coloring/data/coloring_data.dart` — Add `maskAsset` paths
9. `pubspec.yaml` — Add mask asset directories

### FILES TO DELETE (1)
1. `lib/features/coloring/painters/flood_fill.dart` — Replaced by region mask

### FILES UNCHANGED (7)
1. `lib/features/coloring/screens/coloring_list_screen.dart`
2. `lib/features/coloring/screens/all_coloring_pages_screen.dart`
3. `lib/features/coloring/widgets/color_palette.dart`
4. `lib/features/coloring/widgets/brush_size_selector.dart`
5. `lib/features/coloring/painters/ghana_outlines.dart`
6. `lib/features/coloring/painters/image_outline_painter.dart`
7. `lib/features/coloring/drawing_screen.dart` — Free-draw, separate feature

---

## Implementation Timeline

```
Week 1: Phase 1 (Region Fill)
  Day 1: Generate 15 USA masks + 4 Ghana masks
  Day 2-3: Implement RegionMask, rewrite drawing_state.dart
  Day 4: Rewrite drawing_provider.dart + coloring_canvas.dart
  Day 5: Testing, delete flood_fill.dart

Week 2: Phase 2 (Brushes) + Phase 3 (Zoom)
  Day 1-2: Brush abstraction + 3 implementations
  Day 3: Brush picker UI, update toolbar
  Day 4-5: InteractiveViewer zoom/pan + coordinate transforms

Week 3: Phase 4 (Performance/Polish)
  Day 1-2: PictureRecorder caching, fix shouldRepaint
  Day 3-4: Paper texture, memory profiling
  Day 5: Final QA, golden tests
```

---

## Critical Success Factors

1. **Mask generation must be correct** — Sealed regions, no leaks
2. **Coordinate transforms must be precise** — Drawing/filling at any zoom level
3. **Memory discipline** — Dispose all `ui.Image` objects
4. **Free-draw compatibility** — Shared `DrawingState` must work for both features

---

## Next Step

Generate the 15 USA mask files using the Python script, then begin Phase 1 implementation.
