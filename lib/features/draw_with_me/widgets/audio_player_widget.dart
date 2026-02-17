// File: lib/features/draw_with_me/widgets/audio_player_widget.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../providers/trace_controller.dart';

class TraceAudioPlayerWidget extends ConsumerStatefulWidget {
  const TraceAudioPlayerWidget({super.key});

  @override
  ConsumerState<TraceAudioPlayerWidget> createState() =>
      _TraceAudioPlayerWidgetState();
}

class _TraceAudioPlayerWidgetState
    extends ConsumerState<TraceAudioPlayerWidget> {
  late final AudioPlayer _assetPlayer;
  late final FlutterTts _tts;

  ProviderSubscription<TraceState>? _subscription;

  static const Map<TraceAudioCue, String> _assetByCue = {
    TraceAudioCue.followPath: 'assets/audio/follow_path.mp3',
    TraceAudioCue.greatJob: 'assets/audio/great_job.mp3',
    TraceAudioCue.tryAgain: 'assets/audio/try_again.mp3',
    TraceAudioCue.completed: 'assets/audio/completed.mp3',
  };

  static const Map<TraceAudioCue, String> _fallbackSpeech = {
    TraceAudioCue.followPath: 'Follow the path!',
    TraceAudioCue.greatJob: 'Great job!',
    TraceAudioCue.tryAgain: 'Try again!',
    TraceAudioCue.completed: 'Amazing! You finished the trace!',
  };

  @override
  void initState() {
    super.initState();
    _assetPlayer = AudioPlayer();
    _tts = FlutterTts();

    _configureTts();

    _subscription = ref.listenManual<TraceState>(
      traceControllerProvider,
      _onTraceStateChanged,
      fireImmediately: false,
    );
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.1);
  }

  @override
  void dispose() {
    _subscription?.close();
    _assetPlayer.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _onTraceStateChanged(
    TraceState? previous,
    TraceState next,
  ) async {
    final cue = next.pendingAudioCue;
    if (cue == null || next.muted) return;

    final notifier = ref.read(traceControllerProvider.notifier);
    notifier.consumeAudioCue();

    await _playCue(cue);
  }

  Future<void> _playCue(TraceAudioCue cue) async {
    final assetPath = _assetByCue[cue];
    final fallback = _fallbackSpeech[cue] ?? 'Great work!';

    if (assetPath == null) {
      await _tts.speak(fallback);
      return;
    }

    try {
      // Validate that the file is packaged before attempting playback.
      await rootBundle.load(assetPath);

      await _assetPlayer.stop();
      final sourcePath = assetPath.replaceFirst('assets/', '');
      await _assetPlayer.play(AssetSource(sourcePath));
    } catch (_) {
      await _tts.stop();
      await _tts.speak(fallback);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = ref.watch(traceControllerProvider.select((s) => s.muted));
    final controller = ref.read(traceControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7E1EB), width: 1),
      ),
      child: IconButton(
        tooltip: muted ? 'Unmute' : 'Mute',
        onPressed: controller.toggleMute,
        icon: Icon(
          muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          color: const Color(0xFF2F3A4A),
        ),
      ),
    );
  }
}
