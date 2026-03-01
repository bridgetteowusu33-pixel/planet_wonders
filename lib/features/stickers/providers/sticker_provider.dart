import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sticker.dart';

final stickerProvider = NotifierProvider<StickerNotifier, StickerState>(
  StickerNotifier.new,
);

class StickerState {
  const StickerState({
    required this.catalog,
    required this.collectedIds,
    required this.seenIds,
    required this.pendingUnlockIds,
    required this.loading,
  });

  const StickerState.initial()
    : catalog = const [],
      collectedIds = const <String>{},
      seenIds = const <String>{},
      pendingUnlockIds = const [],
      loading = true;

  final List<Sticker> catalog;
  final Set<String> collectedIds;
  final Set<String> seenIds;
  final List<String> pendingUnlockIds;
  final bool loading;

  int get totalCount => catalog.length;
  int get collectedCount => collectedIds.length;
  int get newCount => collectedIds.difference(seenIds).length;

  List<Sticker> stickersForCountry(String countryId) =>
      catalog.where((s) => s.countryId == countryId).toList(growable: false);

  bool isCollected(String stickerId) => collectedIds.contains(stickerId);
  bool isSeen(String stickerId) => seenIds.contains(stickerId);
  bool isNew(String stickerId) =>
      collectedIds.contains(stickerId) && !seenIds.contains(stickerId);

  Sticker? get pendingUnlockSticker {
    if (pendingUnlockIds.isEmpty) return null;
    final id = pendingUnlockIds.first;
    for (final sticker in catalog) {
      if (sticker.id == id) return sticker;
    }
    return null;
  }

  /// All distinct country IDs present in the catalog.
  List<String> get countryIds {
    final seen = <String>{};
    final result = <String>[];
    for (final sticker in catalog) {
      if (seen.add(sticker.countryId)) result.add(sticker.countryId);
    }
    return result;
  }

  StickerState copyWith({
    List<Sticker>? catalog,
    Set<String>? collectedIds,
    Set<String>? seenIds,
    List<String>? pendingUnlockIds,
    bool? loading,
  }) {
    return StickerState(
      catalog: catalog ?? this.catalog,
      collectedIds: collectedIds ?? this.collectedIds,
      seenIds: seenIds ?? this.seenIds,
      pendingUnlockIds: pendingUnlockIds ?? this.pendingUnlockIds,
      loading: loading ?? this.loading,
    );
  }
}

class StickerNotifier extends Notifier<StickerState> {
  static const String _catalogPath = 'assets/stickers/sticker_catalog.json';
  static const String _kCollectedIds = 'stickers_collected_ids';
  static const String _kSeenIds = 'stickers_seen_ids';

  Future<void>? _loadingTask;

  @override
  StickerState build() {
    _loadingTask ??= _load();
    return const StickerState.initial();
  }

  /// Award any stickers whose earn condition matches the given activity.
  Future<void> checkAndAward({
    required String conditionType,
    required String countryId,
  }) async {
    await _waitForInitialLoad();

    var collected = {...state.collectedIds};
    final queue = [...state.pendingUnlockIds];
    var changed = false;

    for (final sticker in state.catalog) {
      if (collected.contains(sticker.id)) continue;
      final c = sticker.earnCondition;
      if (c.type == conditionType &&
          (c.countryId == null || c.countryId == countryId)) {
        collected.add(sticker.id);
        queue.add(sticker.id);
        changed = true;
      }
    }

    if (!changed) return;
    state = state.copyWith(collectedIds: collected, pendingUnlockIds: queue);
    await _persistProgress();
  }

  /// Mark a single sticker as seen (clears the "NEW" badge).
  void markSeen(String stickerId) {
    if (state.seenIds.contains(stickerId)) return;
    state = state.copyWith(seenIds: {...state.seenIds, stickerId});
    _persistProgress();
  }

  /// Mark all collected stickers as seen (bulk — e.g. when opening the album).
  void markAllSeen() {
    if (state.collectedIds.difference(state.seenIds).isEmpty) return;
    state = state.copyWith(seenIds: {...state.collectedIds});
    _persistProgress();
  }

  /// Dequeue the front of the pending-unlock animation queue.
  void consumePendingUnlock() {
    if (state.pendingUnlockIds.isEmpty) return;
    final queue = [...state.pendingUnlockIds]..removeAt(0);
    state = state.copyWith(pendingUnlockIds: queue);
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  Future<void> _load() async {
    try {
      final catalog = await _loadCatalog();
      final prefs = await SharedPreferences.getInstance();

      state = state.copyWith(
        catalog: catalog,
        collectedIds:
            (prefs.getStringList(_kCollectedIds) ?? const []).toSet(),
        seenIds: (prefs.getStringList(_kSeenIds) ?? const []).toSet(),
        loading: false,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Sticker catalog load failed: $error');
        debugPrint('$stackTrace');
      }
      state = state.copyWith(loading: false);
    }
  }

  Future<void> _waitForInitialLoad() async {
    _loadingTask ??= _load();
    await _loadingTask;
  }

  Future<List<Sticker>> _loadCatalog() async {
    final raw = await rootBundle.loadString(_catalogPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Sticker catalog JSON root must be an object.',
      );
    }

    final entries = decoded['stickers'];
    if (entries is! List) {
      throw const FormatException(
        'Sticker catalog must contain a stickers list.',
      );
    }

    return entries
        .whereType<Map>()
        .map((e) => Sticker.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<void> _persistProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kCollectedIds, state.collectedIds.toList());
    await prefs.setStringList(_kSeenIds, state.seenIds.toList());
  }
}
