import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Lazily builds small procedural textures for crayon/paper effects.
class ColoringTextureCache {
  ColoringTextureCache._();

  static final ColoringTextureCache instance = ColoringTextureCache._();

  ui.Image? _crayonNoise;
  ui.Image? _paperNoise;
  Future<void>? _loading;

  ui.Image? get crayonNoiseImage => _crayonNoise;
  ui.Image? get paperNoiseImage => _paperNoise;

  Future<void> ensureLoaded() {
    if (_crayonNoise != null && _paperNoise != null) {
      return Future.value();
    }
    return _loading ??= _loadAll();
  }

  void dispose() {
    _crayonNoise?.dispose();
    _paperNoise?.dispose();
    _crayonNoise = null;
    _paperNoise = null;
    _loading = null;
  }

  ui.Paint? buildPaperPaint(ui.Rect bounds) {
    final image = _paperNoise;
    if (image == null) return null;
    final matrix = Float64List.fromList(<double>[
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      bounds.left, bounds.top, 0, 1,
    ]);
    final shader = ui.ImageShader(
      image,
      ui.TileMode.repeated,
      ui.TileMode.repeated,
      matrix,
    );
    return ui.Paint()
      ..shader = shader
      ..blendMode = ui.BlendMode.multiply
      ..color = const ui.Color(0x14FFFFFF);
  }

  ui.Paint? buildCrayonTexturePaint(ui.Color color) {
    final image = _crayonNoise;
    if (image == null) return null;
    final shader = ui.ImageShader(
      image,
      ui.TileMode.repeated,
      ui.TileMode.repeated,
      Float64List.fromList(<double>[
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      ]),
    );
    return ui.Paint()
      ..shader = shader
      ..blendMode = ui.BlendMode.multiply
      ..color = color.withValues(alpha: 0.35);
  }

  Future<void> _loadAll() async {
    _crayonNoise = await _createNoiseImage(
      size: 96,
      seed: 97,
      min: 64,
      max: 220,
    );
    _paperNoise = await _createNoiseImage(
      size: 128,
      seed: 7331,
      min: 205,
      max: 250,
    );
  }

  Future<ui.Image> _createNoiseImage({
    required int size,
    required int seed,
    required int min,
    required int max,
  }) {
    final rand = Random(seed);
    final rgba = Uint8List(size * size * 4);
    for (int i = 0; i < size * size; i++) {
      final v = min + rand.nextInt(max - min + 1);
      final o = i * 4;
      rgba[o] = v;
      rgba[o + 1] = v;
      rgba[o + 2] = v;
      rgba[o + 3] = 255;
    }

    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      size,
      size,
      ui.PixelFormat.rgba8888,
      c.complete,
    );
    return c.future;
  }
}
