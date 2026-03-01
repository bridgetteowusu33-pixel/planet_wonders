import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Fire-and-forget SFX service for the V2 cooking game.
///
/// Resolves sound files per country:
///   `assets/cooking/sounds/{countryId}/{cue}.mp3`
///
/// Falls back to haptic feedback when audio files are missing or fail to play.
class CookingAudioService {
  CookingAudioService._();

  static final CookingAudioService instance = CookingAudioService._();

  bool _muted = false;
  AudioPlayer? _sfxPlayer;

  bool get isMuted => _muted;

  void setMuted(bool value) => _muted = value;

  void toggleMute() => _muted = !_muted;

  /// Play a sound effect cue for the given country.
  ///
  /// Cue names:
  /// - `chop`           — knife chop / afrobeat tap
  /// - `season`         — spice shaker / afrobeat tap
  /// - `stir`           — spoon stirring
  /// - `sizzle`         — oil/heat sizzle
  /// - `bubble`         — bubble pop
  /// - `drop`           — ingredient drop into pot
  /// - `plate`          — plate clink
  /// - `step_complete`  — talking drum / step transition
  /// - `recipe_complete`— fanfare / celebration
  Future<void> playSfx(String cue, String countryId) async {
    if (_muted) return;

    // Map cue names to audio file names.
    final fileName = _fileNameForCue(cue);
    final assetPath = 'cooking/sounds/$countryId/$fileName';

    try {
      if (_sfxPlayer == null) {
        AudioLogger.logLevel = AudioLogLevel.none;
        _sfxPlayer = AudioPlayer();
      }
      await _sfxPlayer!.play(AssetSource(assetPath));
    } catch (_) {
      // Audio file missing or playback failed — use haptic fallback.
      await _hapticFallback(cue);
    }
  }

  /// Stop all playback.
  Future<void> stopAll() async {
    try {
      await _sfxPlayer?.stop();
    } catch (_) {}
  }

  /// Release audio resources.
  void dispose() {
    try {
      _sfxPlayer?.dispose();
    } catch (_) {}
    _sfxPlayer = null;
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  String _fileNameForCue(String cue) {
    return switch (cue) {
      'chop' || 'season' => 'afrobeat_tap.mp3',
      'stir'             => 'stir_loop.mp3',
      'sizzle'           => 'sizzle.mp3',
      'bubble'           => 'bubble_pop.mp3',
      'drop'             => 'drop.mp3',
      'plate'            => 'plate_clink.mp3',
      'step_complete'    => 'talking_drum.mp3',
      'recipe_complete'  => 'fanfare.mp3',
      _                  => '$cue.mp3',
    };
  }

  Future<void> _hapticFallback(String cue) async {
    try {
      switch (cue) {
        case 'chop':
        case 'drop':
          await HapticFeedback.selectionClick();
        case 'stir':
        case 'sizzle':
        case 'bubble':
          await HapticFeedback.lightImpact();
        case 'season':
        case 'plate':
        case 'step_complete':
          await HapticFeedback.mediumImpact();
        case 'recipe_complete':
          await HapticFeedback.heavyImpact();
        default:
          await HapticFeedback.selectionClick();
      }
    } catch (_) {
      // Haptic feedback is optional.
    }
  }
}
