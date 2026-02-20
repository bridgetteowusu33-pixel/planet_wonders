import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/motion/motion_settings_provider.dart';
import '../../../features/screen_time/providers/screen_time_settings_provider.dart';
import '../../../features/screen_time/providers/usage_tracker_provider.dart';
import '../../../features/screen_time/widgets/pin_dialog.dart';
import '../data/puzzle_models.dart';
import '../data/puzzle_repository.dart';
import '../domain/puzzle_engine/jigsaw_engine.dart';
import '../providers/puzzle_providers.dart';
import 'widgets/draggable_piece.dart';
import 'widgets/hint_button.dart';
import 'widgets/puzzle_board.dart';
import 'widgets/star_row.dart';
import 'widgets/timer_chip.dart';
import 'widgets/win_modal.dart';
import '../../../core/services/achievements_service.dart';

class PuzzlePlayRouteGate extends ConsumerWidget {
  const PuzzlePlayRouteGate({
    super.key,
    required this.puzzleId,
    this.packId,
  });

  final String puzzleId;
  final String? packId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = ref.watch(usageTrackerProvider);

    if (tracker.isBedtimeLocked) {
      return const _PuzzleBedtimeLockScreen();
    }

    return PuzzlePlayScreen(
      puzzleId: puzzleId,
      packId: packId,
    );
  }
}

class PuzzlePlayScreen extends ConsumerStatefulWidget {
  const PuzzlePlayScreen({
    super.key,
    required this.puzzleId,
    this.packId,
  });

  final String puzzleId;
  final String? packId;

  @override
  ConsumerState<PuzzlePlayScreen> createState() => _PuzzlePlayScreenState();
}

class _PuzzlePlayScreenState extends ConsumerState<PuzzlePlayScreen> {
  JigsawEngine? _engine;
  PuzzleItem? _puzzle;
  PuzzleResumeState? _resumeToApply;
  PuzzleRepository? _repo;

  final Stopwatch _stopwatch = Stopwatch();
  final ValueNotifier<int> _elapsedSeconds = ValueNotifier<int>(0);
  final ValueNotifier<bool> _showHintOverlay = ValueNotifier<bool>(false);

  Timer? _ticker;
  Timer? _hintTimer;
  Timer? _saveDebounce;

  int _seed = 0;
  int _baseElapsedMs = 0;
  bool _winShown = false;

  @override
  void dispose() {
    _ticker?.cancel();
    _hintTimer?.cancel();
    _saveDebounce?.cancel();
    _showHintOverlay.dispose();
    _elapsedSeconds.dispose();

    final puzzle = _puzzle;
    final engine = _engine;
    final repo = _repo;
    if (puzzle != null && engine != null && repo != null && !engine.completed) {
      unawaited(
        repo.saveResume(
          puzzle: puzzle,
          seed: _seed,
          placedPieceIds: engine.placedPieceIds,
          moves: engine.moves,
          elapsedMs: _elapsedMs,
          hintsUsed: engine.hintsUsed,
        ),
      );
    }

    _engine?.removeListener(_onEngineUpdated);
    _engine?.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puzzleAsync = ref.watch(puzzleByIdProvider(widget.puzzleId));
    return puzzleAsync.when(
      data: (puzzle) {
        if (puzzle == null) {
          return _MissingPuzzleScreen(puzzleId: widget.puzzleId);
        }

        _ensureSessionStarted(puzzle);

        final engine = _engine;
        if (engine == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(puzzle.title),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Semantics(
              label: 'Back',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEAF5FF), Color(0xFFFFF5DB)],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = constraints.maxWidth > constraints.maxHeight;
                  final boardFlex = isLandscape ? 7 : 5;
                  final trayFlex = isLandscape ? 4 : 3;

                  final boardSection = Expanded(
                    flex: boardFlex,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: AnimatedBuilder(
                        animation: engine,
                        builder: (context, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: _showHintOverlay,
                            builder: (context, showHint, _) {
                              return PuzzleBoard(
                                puzzle: puzzle,
                                engine: engine,
                                showHint: showHint,
                                onPieceDropped: _onPieceDropped,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );

                  final traySection = Expanded(
                    flex: trayFlex,
                    child: Padding(
                      padding: isLandscape
                          ? const EdgeInsets.fromLTRB(0, 8, 12, 8)
                          : const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: engine,
                          builder: (context, _) => _PieceTray(
                            puzzle: puzzle,
                            engine: engine,
                            isLandscape: isLandscape,
                          ),
                        ),
                      ),
                    ),
                  );

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _TopHud(
                          elapsedSecondsListenable: _elapsedSeconds,
                          movesListenable: engine,
                          hintsUsed: engine.hintsUsed,
                          maxHints: JigsawEngine.maxHints,
                          onHintPressed: _onHintPressed,
                        ),
                      ),
                      if (isLandscape)
                        Expanded(
                          child: Row(
                            children: [boardSection, traySection],
                          ),
                        )
                      else ...[
                        boardSection,
                        traySection,
                      ],
                      if (engine.completed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: StarRow(
                            stars: _starsForCurrentRun(puzzle, engine),
                            size: 22,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => _MissingPuzzleScreen(puzzleId: widget.puzzleId),
    );
  }

  int get _elapsedMs => _baseElapsedMs + _stopwatch.elapsedMilliseconds;

  Future<void> _ensureSessionStarted(PuzzleItem puzzle) async {
    if (_puzzle?.id == puzzle.id && _engine != null) return;

    _puzzle = puzzle;
    _winShown = false;
    _repo = ref.read(puzzleRepositoryProvider);

    final resume = await ref.read(puzzleActionsProvider).loadResume(puzzle.id);
    if (!mounted) return;

    _resumeToApply = resume;
    _seed = resume?.seed ?? DateTime.now().microsecondsSinceEpoch;
    _baseElapsedMs = resume?.elapsedMs ?? 0;

    _engine?.removeListener(_onEngineUpdated);
    _engine?.dispose();

    final engine = JigsawEngine(puzzle: puzzle, seed: _seed);
    engine.addListener(_onEngineUpdated);

    setState(() {
      _engine = engine;
    });

    await ref.read(puzzleActionsProvider).touchPuzzle(puzzle.id);

    if (mounted) {
      unawaited(
        precacheImage(AssetImage(puzzle.imagePath), context).catchError((_) {}),
      );
    }

    _stopwatch
      ..reset()
      ..start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final seconds = _elapsedMs ~/ 1000;
      if (_elapsedSeconds.value != seconds) {
        _elapsedSeconds.value = seconds;
      }
    });
  }

  Future<void> _onPieceDropped(String pieceId, Offset localDropPosition) async {
    final engine = _engine;
    final puzzle = _puzzle;
    if (engine == null || puzzle == null) return;

    final snapped = engine.tryDropPiece(
      pieceId: pieceId,
      dropPosition: localDropPosition,
    );

    if (snapped) {
      HapticFeedback.lightImpact();
      _queueSave();
    }
  }

  void _onHintPressed() {
    final engine = _engine;
    if (engine == null || engine.hintUsed) return;

    engine.useHint();
    _showHintOverlay.value = true;
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 2), () {
      _showHintOverlay.value = false;
    });
    _queueSave();
  }

  void _onEngineUpdated() {
    final engine = _engine;
    final puzzle = _puzzle;
    if (engine == null || puzzle == null) return;

    // Apply saved resume state once engine has a layout (deferred to avoid
    // calling notifyListeners during build).
    final resume = _resumeToApply;
    if (resume != null && engine.layout != null) {
      _resumeToApply = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        engine.restoreProgress(
          placedPieceIds: resume.placedPieceIds,
          moves: resume.moves,
          hintsUsed: resume.hintsUsed,
        );
      });
    }

    if (engine.completed && !_winShown) {
      _winShown = true;
      _handleWin(puzzle: puzzle, engine: engine);
    }
  }

  Future<void> _handleWin({
    required PuzzleItem puzzle,
    required JigsawEngine engine,
  }) async {
    _ticker?.cancel();
    _stopwatch.stop();

    final elapsedMs = _elapsedMs;
    final progress = await ref.read(puzzleActionsProvider).completePuzzle(
          puzzle: puzzle,
          elapsedMs: elapsedMs,
          moves: engine.moves,
          hintsUsed: engine.hintsUsed,
        );

    await AchievementsService.onPuzzleCompleted(
      puzzleId: puzzle.id,
      packId: puzzle.packId,
      stars: progress.stars,
      completedTimeMs: elapsedMs,
    );

    if (!mounted) return;

    final reduceMotion = ref.read(motionSettingsProvider).reduceMotionEffective;
    await showPuzzleWinModal(
      context: context,
      puzzle: puzzle,
      stars: progress.stars,
      elapsedMs: elapsedMs,
      moves: engine.moves,
      reduceMotion: reduceMotion,
      onReplay: _restartPuzzle,
      onNext: _goToNextPuzzle,
      onDone: _exitToPack,
    );
  }

  Future<void> _restartPuzzle() async {
    final puzzle = _puzzle;
    if (puzzle == null) return;

    _saveDebounce?.cancel();
    await ref.read(puzzleActionsProvider).clearResume(puzzle.id);

    _resumeToApply = null;
    _baseElapsedMs = 0;
    _elapsedSeconds.value = 0;
    _seed = DateTime.now().microsecondsSinceEpoch;
    _winShown = false;

    _engine?.reset(seed: _seed);

    _stopwatch
      ..reset()
      ..start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final seconds = _elapsedMs ~/ 1000;
      if (_elapsedSeconds.value != seconds) {
        _elapsedSeconds.value = seconds;
      }
    });
  }

  Future<void> _goToNextPuzzle() async {
    final puzzle = _puzzle;
    if (puzzle == null) return;

    final pack = await ref.read(puzzlePackProvider(puzzle.packId).future);
    if (!mounted || pack == null) return;

    final index = pack.puzzles.indexWhere((p) => p.id == puzzle.id);
    if (index == -1 || index + 1 >= pack.puzzles.length) {
      _exitToPack();
      return;
    }

    final next = pack.puzzles[index + 1];
    context.go('/games/puzzles/play/${next.id}?packId=${puzzle.packId}');
  }

  void _exitToPack() {
    final puzzle = _puzzle;
    if (puzzle != null) {
      context.go('/games/puzzles/pack/${puzzle.packId}');
      return;
    }

    if (widget.packId != null && widget.packId!.isNotEmpty) {
      context.go('/games/puzzles/pack/${widget.packId}');
    } else {
      context.go('/games/puzzles');
    }
  }

  void _queueSave() {
    final puzzle = _puzzle;
    final engine = _engine;
    if (puzzle == null || engine == null || engine.completed) return;

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 120), () {
      unawaited(
        ref.read(puzzleActionsProvider).saveResume(
              puzzle: puzzle,
              seed: _seed,
              placedPieceIds: engine.placedPieceIds,
              moves: engine.moves,
              elapsedMs: _elapsedMs,
              hintsUsed: engine.hintsUsed,
            ),
      );
    });
  }

  int _starsForCurrentRun(PuzzleItem puzzle, JigsawEngine engine) {
    return calculatePuzzleStars(
      elapsedMs: _elapsedMs,
      targetTimeSec: puzzle.targetTimeSec,
      hintsUsed: engine.hintsUsed,
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.elapsedSecondsListenable,
    required this.movesListenable,
    required this.hintsUsed,
    required this.maxHints,
    required this.onHintPressed,
  });

  final ValueListenable<int> elapsedSecondsListenable;
  final JigsawEngine movesListenable;
  final int hintsUsed;
  final int maxHints;
  final VoidCallback onHintPressed;

  @override
  Widget build(BuildContext context) {
    final allUsed = hintsUsed >= maxHints;
    return Row(
      children: [
        ValueListenableBuilder<int>(
          valueListenable: elapsedSecondsListenable,
          builder: (context, seconds, _) => TimerChip(seconds: seconds),
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: movesListenable,
          builder: (context, _) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFD8E6FF), width: 2),
            ),
            child: Text(
              'Moves ${movesListenable.moves}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E386E),
                  ),
            ),
          ),
        ),
        const Spacer(),
        HintButton(
          enabled: !allUsed,
          used: allUsed,
          remaining: maxHints - hintsUsed,
          onPressed: onHintPressed,
        ),
      ],
    );
  }
}

class _PieceTray extends StatelessWidget {
  const _PieceTray({
    required this.puzzle,
    required this.engine,
    required this.isLandscape,
  });

  final PuzzleItem puzzle;
  final JigsawEngine engine;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final remaining = engine.remainingPieces;
    final boardSize = engine.layout?.boardSize ?? const Size(320, 320);
    final pieceSize = isLandscape ? 72.0 : 68.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4E3FF), width: 2),
      ),
      child: remaining.isEmpty
          ? Center(
              child: Text(
                'All pieces placed!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2A4B8B),
                    ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: isLandscape
                  ? GridView.builder(
                      itemCount: remaining.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final piece = remaining[index];
                        return DraggablePiece(
                          piece: piece,
                          puzzleImagePath: puzzle.imagePath,
                          boardSize: boardSize,
                          rows: puzzle.rows,
                          cols: puzzle.cols,
                          size: pieceSize,
                        );
                      },
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: remaining.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final piece = remaining[index];
                        return DraggablePiece(
                          piece: piece,
                          puzzleImagePath: puzzle.imagePath,
                          boardSize: boardSize,
                          rows: puzzle.rows,
                          cols: puzzle.cols,
                          size: pieceSize,
                        );
                      },
                    ),
            ),
    );
  }
}

class _PuzzleBedtimeLockScreen extends ConsumerWidget {
  const _PuzzleBedtimeLockScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPin = ref.watch(screenTimeSettingsProvider).hasPin;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A4E), Color(0xFF2D1B69)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌙', style: TextStyle(fontSize: 70)),
                  const SizedBox(height: 10),
                  Text(
                    'Puzzle time is locked for bedtime.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hasPin
                        ? 'Ask a grown-up to unlock with PIN.'
                        : 'Come back in the morning.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                  ),
                  const SizedBox(height: 22),
                  if (hasPin)
                    FilledButton.icon(
                      onPressed: () => _unlock(context, ref),
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Unlock With PIN'),
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlock(BuildContext context, WidgetRef ref) async {
    final verified = await showPinDialog(
      context: context,
      mode: PinMode.verify,
      onVerify: (pin) => ref.read(screenTimeSettingsProvider.notifier).verifyPin(pin),
      onSet: (_) {},
    );

    if (verified && context.mounted) {
      ref.read(usageTrackerProvider.notifier).temporaryUnlock();
    }
  }
}

class _MissingPuzzleScreen extends StatelessWidget {
  const _MissingPuzzleScreen({required this.puzzleId});

  final String puzzleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Puzzle "$puzzleId" was not found.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
