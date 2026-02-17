import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/drawing_state.dart';

/// Provides a page-scoped save controller keyed by a stable page ID
/// (example: `ghana/mountains`).
final coloringSaveControllerProvider =
    Provider.family<ColoringSaveController, String>((ref, pageKey) {
      final controller = ColoringSaveController(pageKey: pageKey);
      ref.onDispose(controller.dispose);
      return controller;
    });

/// Handles local persistence for coloring progress.
///
/// Design notes:
/// - Uses file storage for larger payloads (less pressure on SharedPreferences).
/// - Supports fallback migration from legacy SharedPreferences storage.
/// - Saves only serializable drawing data (strokes + region fills + tool prefs).
/// - Uses debounce to avoid disk thrashing on rapid interactions.
/// - Supports explicit flush on app lifecycle changes.
class ColoringSaveController {
  ColoringSaveController({required this.pageKey});

  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const int _schemaVersion = 1;
  static const int _isolateEncodePointThreshold = 1400;
  static const String _storageDirectoryName = 'coloring_state';

  /// Enables debug prints for save/read/serialize timing.
  static bool verboseProfilingLogs = false;

  final String pageKey;
  final List<DrawingAction> _cachedActionRefs = <DrawingAction>[];
  final List<Map<String, dynamic>?> _cachedSerializedActions =
      <Map<String, dynamic>?>[];
  final List<int> _cachedSerializedPointCounts = <int>[];

  Timer? _debounceTimer;
  DrawingState? _queuedAutoSaveState;
  String? _pendingPayload;
  bool _saveInProgress = false;
  Future<void> _serializeChain = Future<void>.value();
  int _serializeRequestId = 0;
  int _cachedPointCount = 0;
  Future<File>? _payloadFileFuture;

  String get _legacyStorageKey => 'coloring_state_$pageKey';

  /// Debounced auto-save entrypoint used after significant actions.
  void autoSave(DrawingState state) {
    _queuedAutoSaveState = state;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      unawaited(_flushQueuedAutoSave());
    });
  }

  /// Immediate save used on lifecycle events (background/paused).
  Future<void> saveNow(DrawingState state) async {
    _debounceTimer?.cancel();
    _queuedAutoSaveState = null;
    await _enqueueSerialization(state, includeActiveStroke: true);
    await flushPendingSave(waitForSerialization: false);
  }

  Future<void> _flushQueuedAutoSave() async {
    final state = _queuedAutoSaveState;
    _queuedAutoSaveState = null;
    if (state == null) return;

    await _enqueueSerialization(state, includeActiveStroke: false);
    await flushPendingSave(waitForSerialization: false);
  }

  /// Flushes any queued payload to disk.
  Future<void> flushPendingSave({bool waitForSerialization = true}) async {
    if (waitForSerialization) {
      await _serializeChain;
    }

    final payload = _pendingPayload;
    if (payload == null) return;

    if (_saveInProgress) return;
    _saveInProgress = true;

    try {
      await _profileAsync('write_payload', () async {
        final file = await _payloadFile();
        await file.writeAsString(payload, flush: false);
      });

      // Best-effort cleanup for migrated legacy entries.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_legacyStorageKey);

      // Clear only if this exact payload was written.
      if (_pendingPayload == payload) {
        _pendingPayload = null;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Coloring save failed for $pageKey: $error');
        debugPrint('$stackTrace');
      }
    } finally {
      _saveInProgress = false;

      // If another save was queued while writing, flush again.
      if (_pendingPayload != null && _pendingPayload != payload) {
        await flushPendingSave(waitForSerialization: false);
      }
    }
  }

  /// Loads previously saved progress for this page.
  Future<DrawingState?> restoreSavedState() async {
    try {
      final fileRaw = await _profileAsync('read_payload_file', () async {
        final file = await _payloadFile();
        if (!await file.exists()) return null;
        final text = await file.readAsString();
        return text.isEmpty ? null : text;
      });

      if (fileRaw != null) {
        final decoded = jsonDecode(fileRaw);
        if (decoded is! Map<String, dynamic>) return null;
        return _deserializeState(decoded);
      }

      // Legacy fallback + migration path.
      final prefs = await SharedPreferences.getInstance();
      final legacyRaw = prefs.getString(_legacyStorageKey);
      if (legacyRaw == null || legacyRaw.isEmpty) return null;

      await _profileAsync('migrate_legacy_payload', () async {
        final file = await _payloadFile();
        await file.writeAsString(legacyRaw, flush: false);
      });
      await prefs.remove(_legacyStorageKey);

      final decoded = jsonDecode(legacyRaw);
      if (decoded is! Map<String, dynamic>) return null;

      return _deserializeState(decoded);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Coloring restore failed for $pageKey: $error');
        debugPrint('$stackTrace');
      }
      return null;
    }
  }

  /// Clears persisted progress for this page.
  Future<void> clearSavedState() async {
    _debounceTimer?.cancel();
    _queuedAutoSaveState = null;
    _pendingPayload = null;
    _clearSerializedActionCache();

    try {
      final file = await _payloadFile();
      if (await file.exists()) {
        await file.delete();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_legacyStorageKey);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Coloring clear failed for $pageKey: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    final queued = _queuedAutoSaveState;
    _queuedAutoSaveState = null;

    if (queued != null) {
      unawaited(
        _enqueueSerialization(
          queued,
          includeActiveStroke: false,
        ).then((_) => flushPendingSave(waitForSerialization: false)),
      );
      return;
    }

    if (_pendingPayload != null) {
      unawaited(flushPendingSave());
    }
  }

  Future<void> _enqueueSerialization(
    DrawingState state, {
    required bool includeActiveStroke,
  }) {
    final requestId = ++_serializeRequestId;
    _serializeChain = _serializeChain
        .then((_) async {
          if (requestId != _serializeRequestId) {
            return;
          }
          final payloadSnapshot = _profileSync('build_payload_snapshot', () {
            return _buildSerializedPayload(
              state,
              includeActiveStroke: includeActiveStroke,
            );
          });
          final encoded = await _profileAsync('encode_payload', () {
            return _encodePayload(
              payloadSnapshot.payload,
              pointCount: payloadSnapshot.pointCount,
            );
          });

          if (requestId == _serializeRequestId) {
            _pendingPayload = encoded;
          }
        })
        .catchError((error, stackTrace) {
          if (kDebugMode) {
            debugPrint('Coloring serialize failed for $pageKey: $error');
            debugPrint('$stackTrace');
          }
        });
    return _serializeChain;
  }

  Future<File> _payloadFile() {
    return _payloadFileFuture ??= () async {
      final root = await getApplicationDocumentsDirectory();
      final directory = Directory('${root.path}/$_storageDirectoryName');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final encodedKey = base64Url
          .encode(utf8.encode(pageKey))
          .replaceAll('=', '');
      return File('${directory.path}/$encodedKey.json');
    }();
  }

  T _profileSync<T>(String label, T Function() action) {
    if (!kDebugMode) {
      return action();
    }

    final stopwatch = Stopwatch()..start();
    final task = dev.TimelineTask(filterKey: 'coloring_save');
    task.start(label, arguments: <String, Object>{'pageKey': pageKey});

    try {
      return action();
    } finally {
      stopwatch.stop();
      task.finish(
        arguments: <String, Object>{'elapsedMs': stopwatch.elapsedMilliseconds},
      );

      if (verboseProfilingLogs) {
        debugPrint(
          '[ColoringSaveController] $label took '
          '${stopwatch.elapsedMilliseconds}ms for $pageKey',
        );
      }
    }
  }

  Future<T> _profileAsync<T>(String label, Future<T> Function() action) async {
    if (!kDebugMode) {
      return action();
    }

    final stopwatch = Stopwatch()..start();
    final task = dev.TimelineTask(filterKey: 'coloring_save');
    task.start(label, arguments: <String, Object>{'pageKey': pageKey});

    try {
      return await action();
    } finally {
      stopwatch.stop();
      task.finish(
        arguments: <String, Object>{'elapsedMs': stopwatch.elapsedMilliseconds},
      );

      if (verboseProfilingLogs) {
        debugPrint(
          '[ColoringSaveController] $label took '
          '${stopwatch.elapsedMilliseconds}ms for $pageKey',
        );
      }
    }
  }

  _SerializedPayload _buildSerializedPayload(
    DrawingState state, {
    required bool includeActiveStroke,
  }) {
    _syncSerializedActionCache(state.actions);

    final serializedActions = <Map<String, dynamic>>[];
    for (final action in _cachedSerializedActions) {
      if (action != null) {
        serializedActions.add(action);
      }
    }

    int pointCount = _cachedPointCount;
    if (includeActiveStroke && state.activeStroke != null) {
      final serializedStroke = _serializeStroke(state.activeStroke!);
      serializedActions.add(serializedStroke.json);
      pointCount += serializedStroke.pointCount;
    }

    final payload = <String, dynamic>{
      'version': _schemaVersion,
      'savedAt': DateTime.now().toIso8601String(),
      'currentColor': state.currentColor.toARGB32(),
      'currentTool': state.currentTool.name,
      'currentBrushType': state.currentBrushType.name,
      'currentBrushSize': state.currentBrushSize.name,
      'precisionMode': state.precisionMode,
      'paperTextureEnabled': state.paperTextureEnabled,
      'actions': serializedActions,
    };

    return _SerializedPayload(payload: payload, pointCount: pointCount);
  }

  Future<String> _encodePayload(
    Map<String, dynamic> payload, {
    required int pointCount,
  }) {
    if (pointCount < _isolateEncodePointThreshold) {
      return Future<String>.value(jsonEncode(payload));
    }
    return Isolate.run(() => jsonEncode(payload));
  }

  void _syncSerializedActionCache(List<DrawingAction> actions) {
    final commonLength = actions.length < _cachedActionRefs.length
        ? actions.length
        : _cachedActionRefs.length;

    int mismatchIndex = commonLength;
    for (int i = 0; i < commonLength; i++) {
      if (!identical(actions[i], _cachedActionRefs[i])) {
        mismatchIndex = i;
        break;
      }
    }

    _truncateSerializedActionCache(mismatchIndex);

    for (int i = _cachedActionRefs.length; i < actions.length; i++) {
      final action = actions[i];
      final serialized = _serializeDrawingAction(action);

      _cachedActionRefs.add(action);
      _cachedSerializedActions.add(serialized?.json);
      final pointCount = serialized?.pointCount ?? 0;
      _cachedSerializedPointCounts.add(pointCount);
      _cachedPointCount += pointCount;
    }
  }

  void _truncateSerializedActionCache(int targetLength) {
    while (_cachedActionRefs.length > targetLength) {
      _cachedActionRefs.removeLast();
      _cachedSerializedActions.removeLast();
      _cachedPointCount -= _cachedSerializedPointCounts.removeLast();
    }
  }

  void _clearSerializedActionCache() {
    _cachedActionRefs.clear();
    _cachedSerializedActions.clear();
    _cachedSerializedPointCounts.clear();
    _cachedPointCount = 0;
  }

  _SerializedAction? _serializeDrawingAction(DrawingAction action) {
    if (action is StrokeAction) {
      return _serializeStroke(action.stroke);
    }

    if (action is RegionFillAction) {
      return _SerializedAction(
        json: {
          'type': 'region_fill',
          'regionId': action.regionId,
          'color': action.color.toARGB32(),
        },
        pointCount: 0,
      );
    }

    return null;
  }

  _SerializedAction _serializeStroke(Stroke stroke) {
    final points = stroke.points
        .map((point) => {'x': _round2(point.dx), 'y': _round2(point.dy)})
        .toList(growable: false);

    return _SerializedAction(
      json: {
        'type': 'stroke',
        'color': stroke.color.toARGB32(),
        'width': stroke.width,
        'brushType': stroke.brushType.name,
        'isEraser': stroke.isEraser,
        'points': points,
      },
      pointCount: points.length,
    );
  }

  DrawingState _deserializeState(Map<String, dynamic> json) {
    final rawActions = json['actions'];
    final actions = <DrawingAction>[];

    if (rawActions is List) {
      for (final raw in rawActions) {
        if (raw is! Map) continue;
        final entry = raw.cast<String, dynamic>();
        final type = (entry['type'] as String?)?.trim();

        if (type == 'stroke') {
          final points = _parsePoints(entry['points']);
          if (points.isEmpty) continue;

          final colorValue =
              _parseInt(entry['color']) ?? const Color(0xFF000000).toARGB32();
          final width = _parseDouble(entry['width']) ?? BrushSize.medium.width;
          final brushType = _brushTypeFromName(entry['brushType'] as String?);
          final isEraser = entry['isEraser'] == true;

          actions.add(
            StrokeAction(
              Stroke(
                points: points,
                color: Color(colorValue),
                width: width,
                brushType: brushType,
                isEraser: isEraser,
              ),
            ),
          );
          continue;
        }

        if (type == 'region_fill') {
          final regionId = _parseInt(entry['regionId']);
          final colorValue = _parseInt(entry['color']);
          if (regionId == null || colorValue == null) continue;

          actions.add(
            RegionFillAction(regionId: regionId, color: Color(colorValue)),
          );
        }
      }
    }

    final currentColor = Color(
      _parseInt(json['currentColor']) ?? const Color(0xFF2F3A4A).toARGB32(),
    );

    return DrawingState(
      actions: actions,
      redoStack: const [],
      activeStroke: null,
      currentTool: _toolFromName(json['currentTool'] as String?),
      currentBrushType: _brushTypeFromName(json['currentBrushType'] as String?),
      currentColor: currentColor,
      currentBrushSize: _brushSizeFromName(json['currentBrushSize'] as String?),
      filling: false,
      precisionMode: json['precisionMode'] == true,
      paperTextureEnabled: json['paperTextureEnabled'] != false,
    );
  }

  List<Offset> _parsePoints(Object? raw) {
    if (raw is! List) return const [];
    final points = <Offset>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = item.cast<String, dynamic>();
      final x = _parseDouble(map['x']);
      final y = _parseDouble(map['y']);
      if (x == null || y == null) continue;
      points.add(Offset(x, y));
    }
    return points;
  }

  DrawingTool _toolFromName(String? value) {
    if (value == null) return DrawingTool.marker;
    for (final tool in DrawingTool.values) {
      if (tool.name == value) return tool;
    }
    return DrawingTool.marker;
  }

  BrushType _brushTypeFromName(String? value) {
    if (value == null) return BrushType.marker;
    for (final type in BrushType.values) {
      if (type.name == value) return type;
    }
    return BrushType.marker;
  }

  BrushSize _brushSizeFromName(String? value) {
    if (value == null) return BrushSize.medium;
    for (final size in BrushSize.values) {
      if (size.name == value) return size;
    }
    return BrushSize.medium;
  }

  int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _parseDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double _round2(double value) => (value * 100).roundToDouble() / 100.0;
}

class _SerializedPayload {
  const _SerializedPayload({required this.payload, required this.pointCount});

  final Map<String, dynamic> payload;
  final int pointCount;
}

class _SerializedAction {
  const _SerializedAction({required this.json, required this.pointCount});

  final Map<String, dynamic> json;
  final int pointCount;
}
