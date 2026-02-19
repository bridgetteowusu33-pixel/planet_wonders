import 'dart:convert';

import 'package:crypto/crypto.dart';

class ScreenTimeSettings {
  const ScreenTimeSettings({
    this.dailyLimitMinutes = 60,
    this.bedtimeLockEnabled = false,
    this.bedtimeLockStartHour = 20,
    this.bedtimeLockEndHour = 7,
    this.pinHash,
  });

  /// Daily limit in minutes. 0 means unlimited.
  final int dailyLimitMinutes;

  /// Whether the bedtime lock is enabled (separate from dark-mode bedtime).
  final bool bedtimeLockEnabled;

  /// Hour (0-23) when bedtime lock starts.
  final int bedtimeLockStartHour;

  /// Hour (0-23) when bedtime lock ends.
  final int bedtimeLockEndHour;

  /// SHA-256 hash of the 4-digit PIN, or null if no PIN is set.
  final String? pinHash;

  bool get hasPin => pinHash != null;
  bool get hasLimit => dailyLimitMinutes > 0;

  /// Label for the current limit (for display in Parent Hub subtitle).
  String get limitLabel {
    if (!hasLimit) return 'Unlimited';
    if (dailyLimitMinutes >= 60) {
      final hours = dailyLimitMinutes ~/ 60;
      final mins = dailyLimitMinutes % 60;
      if (mins == 0) return '$hours hr';
      return '$hours hr $mins min';
    }
    return '$dailyLimitMinutes min';
  }

  ScreenTimeSettings copyWith({
    int? dailyLimitMinutes,
    bool? bedtimeLockEnabled,
    int? bedtimeLockStartHour,
    int? bedtimeLockEndHour,
    String? Function()? pinHash,
  }) {
    return ScreenTimeSettings(
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      bedtimeLockEnabled: bedtimeLockEnabled ?? this.bedtimeLockEnabled,
      bedtimeLockStartHour:
          bedtimeLockStartHour ?? this.bedtimeLockStartHour,
      bedtimeLockEndHour: bedtimeLockEndHour ?? this.bedtimeLockEndHour,
      pinHash: pinHash != null ? pinHash() : this.pinHash,
    );
  }

  /// Hash a 4-digit PIN string with SHA-256.
  static String hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }
}
