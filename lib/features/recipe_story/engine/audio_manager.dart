import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Manages sound effects and narration for recipe stories.
///
/// Currently provides haptic feedback as a substitute for audio.
/// When actual audio assets are added, this class will be extended
/// to play WAV/MP3 files via an audio plugin (e.g., audioplayers).
///
/// Architecture note: This is intentionally a simple service rather
/// than a Riverpod provider. Audio playback is fire-and-forget and
/// doesn't need reactive state management.
class RecipeAudioManager {
  RecipeAudioManager._();

  static final RecipeAudioManager instance = RecipeAudioManager._();

  bool _muted = false;
  FlutterTts? _tts;
  bool _ttsReady = false;

  bool get isMuted => _muted;

  void toggleMute() => _muted = !_muted;

  void setMuted(bool value) => _muted = value;

  /// Play a sound effect cue.
  ///
  /// Cue names map to planned audio files:
  /// - 'splash'   → water splash for washing
  /// - 'chop'     → knife chopping
  /// - 'sizzle'   → oil/frying sizzle
  /// - 'pour'     → liquid pouring
  /// - 'stir'     → spoon stirring
  /// - 'steam'    → pot steaming
  /// - 'shake'    → shaker sound
  /// - 'ding'     → step complete chime
  /// - 'fanfare'  → recipe complete celebration
  /// - 'reward'   → badge earned popup
  ///
  /// Until audio files are provided, we fall back to haptic feedback
  /// which provides tactile response without requiring audio assets.
  Future<void> playSfx(String cue) async {
    if (_muted) return;

    try {
      switch (cue) {
        case 'splash':
        case 'chop':
        case 'tap':
        case 'drop':
          await HapticFeedback.selectionClick();
        case 'sizzle':
        case 'pour':
        case 'stir':
        case 'steam':
        case 'hold':
          await HapticFeedback.lightImpact();
        case 'shake':
          await HapticFeedback.mediumImpact();
        case 'ding':
        case 'reward':
          await HapticFeedback.mediumImpact();
        case 'fanfare':
        case 'celebrate':
        case 'complete':
          await HapticFeedback.heavyImpact();
        default:
          await HapticFeedback.selectionClick();
      }
    } catch (_) {
      // Haptic feedback is optional — some devices don't support it.
    }
  }

  /// Play narration for a step.
  ///
  /// Placeholder for TTS or pre-recorded narration audio.
  /// When implemented, this will use flutter_tts or play
  /// pre-recorded audio from assets/audio/narration/.
  Future<void> playNarration(String text) async {
    if (_muted) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    try {
      final tts = await _ensureTts();
      if (tts == null) return;
      await tts.stop();
      await tts.speak(trimmed);
    } catch (_) {
      // TTS may fail on unsupported simulators/devices; ignore gracefully.
    }
  }

  /// Stop all currently playing audio.
  Future<void> stopAll() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }

  /// Dispose audio resources.
  void dispose() {
    try {
      _tts?.stop();
    } catch (_) {}
    _tts = null;
    _ttsReady = false;
  }

  Future<FlutterTts?> _ensureTts() async {
    if (_ttsReady && _tts != null) {
      return _tts;
    }

    try {
      final tts = _tts ?? FlutterTts();
      _tts = tts;
      await tts.setLanguage('en-US');
      await tts.setPitch(1.05);
      await tts.setSpeechRate(0.48);
      _ttsReady = true;
      return tts;
    } catch (_) {
      _ttsReady = false;
      return null;
    }
  }
}
