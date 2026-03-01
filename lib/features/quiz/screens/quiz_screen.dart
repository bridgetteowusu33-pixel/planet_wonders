import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/motion/motion_settings_provider.dart';
import '../../../core/theme/pw_theme.dart';
import '../../stickers/providers/sticker_provider.dart';
import '../data/quiz_models.dart';
import '../providers/quiz_providers.dart';
import '../widgets/quiz_badge_popup.dart';
import '../widgets/quiz_card.dart';

/// Full-screen Guess & Learn quiz.
///
/// Shows a landmark image and a tap-to-reveal question card.
/// Supports daily mode (picks today's quiz) or a specific [quizId].
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    this.daily = false,
    this.quizId,
    this.countryId,
  });

  final bool daily;
  final String? quizId;

  /// When set, only quizzes for this country are shown.
  final String? countryId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  bool _speaking = false;
  bool _audioEnabled = false;
  bool _revealed = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.1);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
    setState(() => _ttsReady = true);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (!_ttsReady || !_audioEnabled) return;
    await _tts.stop();
    setState(() => _speaking = true);
    await _tts.speak(text);
  }

  void _toggleAudio(QuizItem quiz) {
    setState(() => _audioEnabled = !_audioEnabled);
    if (_audioEnabled) {
      _speak(
        _revealed
            ? '${quiz.answer}. ${quiz.funFact}'
            : 'Can you guess? ${quiz.question}',
      );
    } else {
      _tts.stop();
      setState(() => _speaking = false);
    }
  }

  /// Resolve which quiz to show from the loaded list.
  QuizItem? _resolveQuiz(List<QuizItem> quizzes) {
    if (quizzes.isEmpty) return null;

    // Specific quiz requested
    if (widget.quizId != null) {
      return quizzes.firstWhere(
        (q) => q.id == widget.quizId,
        orElse: () => quizzes.first,
      );
    }

    // Daily mode — use daily provider
    if (widget.daily) {
      final daily = ref.watch(quizDailyProvider);
      if (daily.featuredQuizId.isNotEmpty) {
        final match = quizzes.where((q) => q.id == daily.featuredQuizId);
        if (match.isNotEmpty) return match.first;
      }
    }

    // Browse mode — show quiz at current index
    if (_currentIndex < quizzes.length) return quizzes[_currentIndex];
    return quizzes.first;
  }

  void _onRevealed(QuizItem quiz) {
    setState(() => _revealed = true);
    _speak('${quiz.answer}. ${quiz.funFact}');

    // Save completion & check badges
    ref.read(quizActionsProvider).completeQuiz(quiz.id, quiz.countryId).then(
      (newBadges) {
        if (!mounted) return;
        for (final badge in newBadges) {
          showQuizBadgePopup(context, badge);
        }
      },
    );
    ref.read(stickerProvider.notifier).checkAndAward(
          conditionType: 'quiz_completed',
          countryId: quiz.countryId,
        );
  }

  void _nextQuiz(List<QuizItem> quizzes) {
    setState(() {
      _currentIndex = (_currentIndex + 1) % quizzes.length;
      _revealed = false;
    });
    _tts.stop();
  }

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = widget.countryId != null
        ? ref.watch(quizItemsByCountryProvider(widget.countryId!))
        : ref.watch(quizItemsProvider);
    final reduceMotion = MotionUtil.isReduced(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: quizzesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('Could not load quizzes')),
          data: (quizzes) {
            // Refresh daily rotation when data loads
            if (widget.daily) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(quizDailyProvider.notifier)
                    .refreshDaily(quizzes);
              });
            }

            final quiz = _resolveQuiz(quizzes);
            if (quiz == null) {
              return const Center(child: Text('No quizzes available'));
            }

            return _QuizBody(
              quiz: quiz,
              revealed: _revealed,
              speaking: _speaking,
              audioEnabled: _audioEnabled,
              reduceMotion: reduceMotion,
              isDaily: widget.daily,
              showNext: !widget.daily && quizzes.length > 1,
              onRevealed: () => _onRevealed(quiz),
              onNext: () => _nextQuiz(quizzes),
              onToggleAudio: () => _toggleAudio(quiz),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz body layout
// ---------------------------------------------------------------------------

class _QuizBody extends StatelessWidget {
  const _QuizBody({
    required this.quiz,
    required this.revealed,
    required this.speaking,
    required this.audioEnabled,
    required this.reduceMotion,
    required this.isDaily,
    required this.showNext,
    required this.onRevealed,
    required this.onNext,
    required this.onToggleAudio,
  });

  final QuizItem quiz;
  final bool revealed;
  final bool speaking;
  final bool audioEnabled;
  final bool reduceMotion;
  final bool isDaily;
  final bool showNext;
  final VoidCallback onRevealed;
  final VoidCallback onNext;
  final VoidCallback onToggleAudio;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Top bar ──
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
              ),
              Expanded(
                child: Text(
                  isDaily
                      ? "\u{2B50} Today's Challenge"
                      : 'Guess & Learn',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Audio toggle button
              IconButton(
                onPressed: onToggleAudio,
                icon: Icon(
                  audioEnabled
                      ? (speaking
                          ? Icons.volume_up_rounded
                          : Icons.volume_down_rounded)
                      : Icons.volume_off_rounded,
                  size: 24,
                  color: audioEnabled
                      ? PWColors.blue
                      : PWColors.navy.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Landmark image ──
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.asset(
                quiz.image,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  color: PWColors.blue.withValues(alpha: 0.1),
                  child: const Center(
                    child:
                        Text('\u{1F5BC}\u{FE0F}', style: TextStyle(fontSize: 48)),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Quiz card ──
          Expanded(
            child: SingleChildScrollView(
              child: QuizCard(
                key: ValueKey(quiz.id),
                question: quiz.question,
                answer: quiz.answer,
                funFact: quiz.funFact,
                reduceMotion: reduceMotion,
                onRevealed: onRevealed,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Bottom buttons ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Exit button
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
                label: const Text('Exit'),
                style: TextButton.styleFrom(
                  foregroundColor: PWColors.navy.withValues(alpha: 0.5),
                ),
              ),

              // Next button (browse mode only)
              if (showNext && revealed) ...[
                const SizedBox(width: 16),
                Flexible(
                  child: FilledButton.icon(
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Next Quiz'),
                    style: FilledButton.styleFrom(
                      backgroundColor: PWColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
