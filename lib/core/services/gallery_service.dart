import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Simple local-only gallery storage.
///
/// Drawings are saved as PNG files inside the app's documents directory
/// under a `gallery/` subfolder.  No cloud, no sharing — parent-safe.
class GalleryService {
  static Future<String> get _galleryPath async {
    final dir = await getApplicationDocumentsDirectory();
    final gallery = Directory('${dir.path}/gallery');
    if (!await gallery.exists()) {
      await gallery.create(recursive: true);
    }
    return gallery.path;
  }

  /// Save raw PNG bytes and return the file path.
  static Future<String> saveDrawing(Uint8List pngBytes) async {
    final path = await _galleryPath;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('$path/drawing_$timestamp.png');
    await file.writeAsBytes(pngBytes);
    return file.path;
  }

  /// Load all saved drawings, newest first.
  static Future<List<File>> loadGallery() async {
    final path = await _galleryPath;
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.png')) {
        files.add(entity);
      }
    }
    // Newest first (filenames contain timestamp).
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  /// Delete a single artwork.
  static Future<void> deleteDrawing(File file) async {
    if (await file.exists()) await file.delete();
  }
}
