import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import 'narration_state.dart';

/// Central audio playback service for story narration.
///
/// Plays pre-generated ElevenLabs MP3s from bundled assets when available,
/// falling back to system TTS (flutter_tts) when MP3s are missing.
///
/// Singleton — matches [CookingAudioService] pattern.
class NarrationService {
  NarrationService._();
  static final NarrationService instance = NarrationService._();

  AudioPlayer? _player;
  FlutterTts? _tts;
  bool _muted = false;

  /// Whether narration is currently muted.
  bool get isMuted => _muted;

  final _stateController = StreamController<NarrationState>.broadcast();

  /// Stream of playback state changes.
  Stream<NarrationState> get stateStream => _stateController.stream;

  NarrationState _currentState = NarrationState.idle;

  /// Current playback state.
  NarrationState get currentState => _currentState;

  void _setState(NarrationState s) {
    _currentState = s;
    _stateController.add(s);
  }

  /// Play pre-generated story audio for a specific page.
  ///
  /// Falls back to TTS if the bundled MP3 asset does not exist.
  Future<void> playStoryPage({
    required String countryId,
    required int pageIndex,
    required String fallbackText,
  }) async {
    if (_muted) return;

    await stop();
    _setState(NarrationState.loading);

    final assetPath =
        'assets/audio/stories/$countryId/page_${pageIndex + 1}.mp3';

    if (await _assetExists(assetPath)) {
      await _playAsset(assetPath);
    } else {
      await _speakTts(fallbackText);
    }
  }

  /// Play pre-generated welcome audio for a country hub page.
  ///
  /// Falls back to TTS if the bundled MP3 asset does not exist.
  Future<void> playWelcome({
    required String countryId,
    required String fallbackText,
  }) async {
    if (_muted) return;

    await stop();
    _setState(NarrationState.loading);

    // Try both naming conventions: welcome_page.mp3 and {id}_welcome_page.mp3
    final dir = 'assets/audio/stories/$countryId';
    final candidates = [
      '$dir/welcome_page.mp3',
      '$dir/${countryId}_welcome_page.mp3',
    ];

    for (final path in candidates) {
      if (await _assetExists(path)) {
        await _playAsset(path);
        return;
      }
    }
    await _speakTts(fallbackText);
  }

  /// Speak dynamic text via flutter_tts (for quiz, cooking, etc).
  Future<void> speakText(String text, {String language = 'en-US'}) async {
    if (_muted) return;

    await stop();
    _setState(NarrationState.loading);
    await _speakTts(text, language: language);
  }

  /// Stop all playback — both just_audio and flutter_tts.
  Future<void> stop() async {
    await _player?.stop();
    await _tts?.stop();
    _setState(NarrationState.idle);
  }

  /// Preload the next story page audio into the player cache.
  Future<void> preloadStoryPage({
    required String countryId,
    required int pageIndex,
  }) async {
    final assetPath =
        'assets/audio/stories/$countryId/page_${pageIndex + 1}.mp3';
    if (!await _assetExists(assetPath)) return;

    // Create a temporary player to preload the asset into memory.
    // just_audio caches asset data once loaded.
    try {
      final preloader = AudioPlayer();
      await preloader.setAsset(assetPath);
      await preloader.dispose();
    } catch (_) {
      // Preloading is best-effort — ignore failures.
    }
  }

  /// Mute/unmute all narration.
  void setMuted(bool value) {
    _muted = value;
    if (value) stop();
  }

  /// Release resources.
  void dispose() {
    stop();
    _player?.dispose();
    _player = null;
    _stateController.close();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _playAsset(String assetPath) async {
    try {
      _player ??= AudioPlayer();
      await _player!.setAsset(assetPath);
      _setState(NarrationState.playing);

      // Listen for completion.
      _player!.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _setState(NarrationState.idle);
        }
      });

      await _player!.play();
    } catch (_) {
      _setState(NarrationState.error);
    }
  }

  Future<void> _speakTts(String text, {String language = 'en-US'}) async {
    try {
      _tts ??= FlutterTts();
      await _tts!.setLanguage(language);
      await _tts!.setSpeechRate(0.4);
      await _tts!.setPitch(1.1);

      _tts!.setCompletionHandler(() {
        _setState(NarrationState.idle);
      });

      _setState(NarrationState.playing);
      await _tts!.speak(text);
    } catch (_) {
      _setState(NarrationState.error);
    }
  }
}
