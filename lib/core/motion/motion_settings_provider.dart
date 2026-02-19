import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Reduce-motion mode: system | on | off
// ---------------------------------------------------------------------------

enum ReduceMotionMode { system, on, off }

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class MotionSettings {
  const MotionSettings({
    this.mode = ReduceMotionMode.system,
    this.systemReduceMotion = false,
  });

  final ReduceMotionMode mode;
  final bool systemReduceMotion;

  /// Whether reduce-motion is effectively active.
  bool get reduceMotionEffective => switch (mode) {
    ReduceMotionMode.on => true,
    ReduceMotionMode.off => false,
    ReduceMotionMode.system => systemReduceMotion,
  };

  /// Fast animation duration (used when reduce motion is effective).
  Duration get animFast => const Duration(milliseconds: 120);

  /// Normal animation duration, clamped to [animFast] when reduced.
  Duration get animNormal =>
      reduceMotionEffective ? animFast : const Duration(milliseconds: 250);

  MotionSettings copyWith({
    ReduceMotionMode? mode,
    bool? systemReduceMotion,
  }) {
    return MotionSettings(
      mode: mode ?? this.mode,
      systemReduceMotion: systemReduceMotion ?? this.systemReduceMotion,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final motionSettingsProvider =
    NotifierProvider<MotionSettingsNotifier, MotionSettings>(
  MotionSettingsNotifier.new,
);

class MotionSettingsNotifier extends Notifier<MotionSettings> {
  static const _key = 'planet_wonders_reduce_motion_mode';

  @override
  MotionSettings build() {
    _loadFromPrefs();
    return const MotionSettings();
  }

  Future<void> setMode(ReduceMotionMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  /// Called with the platform accessibility setting.
  void updateSystemReduceMotion(bool value) {
    if (state.systemReduceMotion != value) {
      state = state.copyWith(systemReduceMotion: value);
    }
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final mode = switch (raw) {
      'on' => ReduceMotionMode.on,
      'off' => ReduceMotionMode.off,
      _ => ReduceMotionMode.system,
    };
    state = state.copyWith(mode: mode);
  }
}

// ---------------------------------------------------------------------------
// Convenience: read effective reduce-motion from context.
//
// Usage:  final reduced = MotionUtil.isReduced(ref);
// ---------------------------------------------------------------------------

class MotionUtil {
  MotionUtil._();

  /// Check from a WidgetRef (inside ConsumerWidget / ConsumerState).
  static bool isReduced(WidgetRef ref) =>
      ref.watch(motionSettingsProvider).reduceMotionEffective;

  /// Check from BuildContext when a ref isn't available.
  /// Falls back to the platform MediaQuery value.
  static bool isReducedFromContext(BuildContext context) =>
      MediaQuery.of(context).disableAnimations;
}
