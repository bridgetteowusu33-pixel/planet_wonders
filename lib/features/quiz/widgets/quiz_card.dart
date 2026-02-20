import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

/// Tap-to-reveal card showing a quiz question and hidden answer.
///
/// First tap reveals the answer + fun fact. Calls [onRevealed] once.
class QuizCard extends StatefulWidget {
  const QuizCard({
    super.key,
    required this.question,
    required this.answer,
    required this.funFact,
    required this.onRevealed,
    this.reduceMotion = false,
  });

  final String question;
  final String answer;
  final String funFact;
  final VoidCallback onRevealed;
  final bool reduceMotion;

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  bool _revealed = false;

  void _handleTap() {
    if (_revealed) return;
    setState(() => _revealed = true);
    widget.onRevealed();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.reduceMotion
        ? const Duration(milliseconds: 80)
        : const Duration(milliseconds: 350);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _revealed
                ? PWColors.mint.withValues(alpha: 0.18)
                : PWColors.blue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _revealed
                  ? PWColors.mint.withValues(alpha: 0.45)
                  : PWColors.blue.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question — always visible
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('\u{2753}',
                      style: TextStyle(fontSize: 22)), // ❓
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.question,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: PWColors.navy,
                                height: 1.35,
                              ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Answer area
              AnimatedCrossFade(
                firstChild: _TapPrompt(reduceMotion: widget.reduceMotion),
                secondChild: _RevealedContent(
                  answer: widget.answer,
                  funFact: widget.funFact,
                ),
                crossFadeState: _revealed
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: duration,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Tap to reveal!" prompt
// ---------------------------------------------------------------------------

class _TapPrompt extends StatelessWidget {
  const _TapPrompt({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: PWColors.yellow.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PWColors.yellow.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          const Text('\u{1F449}', style: TextStyle(fontSize: 28)), // 👉
          const SizedBox(height: 6),
          Text(
            'Tap to reveal!',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PWColors.navy.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Revealed answer + fun fact
// ---------------------------------------------------------------------------

class _RevealedContent extends StatelessWidget {
  const _RevealedContent({
    required this.answer,
    required this.funFact,
  });

  final String answer;
  final String funFact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Answer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: PWColors.mint.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Text('\u{2705}',
                  style: TextStyle(fontSize: 20)), // ✅
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  answer,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PWColors.navy,
                      ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Fun fact
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: PWColors.coral.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text('\u{1F4A1}',
                    style: TextStyle(fontSize: 16)), // 💡
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  funFact,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PWColors.navy.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
