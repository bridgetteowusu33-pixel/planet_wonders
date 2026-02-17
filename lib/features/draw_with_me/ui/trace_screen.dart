// File: lib/features/draw_with_me/ui/trace_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../models/trace_shape.dart';
import '../providers/trace_controller.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/trace_canvas.dart';
import 'difficulty_selector.dart';
import 'progress_bar.dart';

class TraceScreen extends ConsumerStatefulWidget {
  const TraceScreen({
    super.key,
    required this.packId,
    required this.shapeId,
    required this.initialDifficulty,
  });

  final String packId;
  final String shapeId;
  final TraceDifficulty initialDifficulty;

  @override
  ConsumerState<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends ConsumerState<TraceScreen> {
  final GlobalKey _repaintKey = GlobalKey();

  ProviderSubscription<TraceState>? _traceSub;
  bool _completionHandled = false;

  @override
  void initState() {
    super.initState();

    _traceSub = ref.listenManual<TraceState>(
      traceControllerProvider,
      _onTraceStateChanged,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(traceControllerProvider.notifier)
          .loadSession(
            packId: widget.packId,
            shapeId: widget.shapeId,
            difficulty: widget.initialDifficulty,
          );
    });
  }

  @override
  void dispose() {
    _traceSub?.close();
    super.dispose();
  }

  Future<void> _onTraceStateChanged(
    TraceState? previous,
    TraceState next,
  ) async {
    if (_completionHandled) return;

    if (previous?.completed != true && next.completed) {
      _completionHandled = true;
      await _handleTraceComplete();
    }
  }

  Future<void> _handleTraceComplete() async {
    final recipeId = '${widget.packId}_${widget.shapeId}';
    await ref
        .read(achievementProvider.notifier)
        .markCookingRecipeCompleted(
          countryId: 'draw_with_me',
          recipeId: recipeId,
        );

    if (!mounted) return;
    final shouldExit =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _TraceCelebrationDialog(),
        ) ??
        false;

    if (!mounted || !shouldExit) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/draw-with-me');
  }

  Future<void> _openDifficultySelector(TraceDifficulty current) async {
    final controller = ref.read(traceControllerProvider.notifier);

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: const Color(0xFFD0DAE5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Difficulty',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                DifficultySelector(
                  value: current,
                  onChanged: (difficulty) {
                    controller.setDifficulty(difficulty);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(traceControllerProvider);
    final controller = ref.read(traceControllerProvider.notifier);

    final shape = state.shape;

    if (state.loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null || shape == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.error ?? 'Trace not found',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final segmentText = state.completed
        ? 'Complete'
        : 'Segment ${state.segmentIndex + 1}/${state.totalSegments}';

    return Scaffold(
      appBar: AppBar(
        title: Text(shape.title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [TraceAudioPlayerWidget(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Difficulty:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    onPressed: () => _openDifficultySelector(state.difficulty),
                    avatar: const Icon(Icons.tune_rounded, size: 18),
                    label: Text(
                      state.difficulty.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const Spacer(),
                  if (state.completed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F5E4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Completed!',
                        style: TextStyle(
                          color: Color(0xFF1E7B4D),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TraceCanvas(repaintKey: _repaintKey),
                ),
              ),
              const SizedBox(height: 12),
              TraceProgressBar(
                progress: state.progress,
                segmentText: segmentText,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.requestHint,
                      icon: const Icon(Icons.lightbulb_rounded),
                      label: const Text('Hint'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: state.completed
                          ? () {
                              context.push(
                                '/draw-with-me/decorate/${widget.packId}/${widget.shapeId}',
                              );
                            }
                          : null,
                      icon: const Icon(Icons.brush_rounded),
                      label: const Text('Decorate'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: PWColors.mint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TraceCelebrationDialog extends StatelessWidget {
  const _TraceCelebrationDialog();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 0.9, end: 1),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('🎉', style: TextStyle(fontSize: 26)),
                SizedBox(width: 6),
                Text('✨', style: TextStyle(fontSize: 24)),
                SizedBox(width: 6),
                Text('🎉', style: TextStyle(fontSize: 26)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Great Job!', textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          'You finished tracing this shape.\nDo you want to exit this screen now?',
          textAlign: TextAlign.center,
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: PWColors.coral),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
