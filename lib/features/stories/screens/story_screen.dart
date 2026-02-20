import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/story_data.dart';
import '../models/story.dart';
import '../widgets/fact_bubble.dart';

/// Page-by-page story reader with a calm, premium feel.
///
/// Layout (top → bottom):
///   1. Custom top bar — `<` chevron, flag + "Country · Story", audio toggle
///   2. Illustration area with emoji placeholder
///   3. Golden progress badge overlapping the illustration/card boundary
///   4. Cream text card with story text and optional "Did You Know?" fact
///   5. Bottom nav — golden "< Back" pill, page indicator, green "Next >" pill
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.countryId});

  final String countryId;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late final PageController _pageController;
  final FlutterTts _tts = FlutterTts();
  int _currentPage = 0;
  bool _audioEnabled = false;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4); // Slow and clear for kids
    await _tts.setPitch(1.1); // Slightly higher pitch — friendly tone

    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    final willEnable = !_audioEnabled;
    setState(() => _audioEnabled = willEnable);

    if (willEnable) {
      _speakCurrentPage();
    } else {
      await _tts.stop();
      setState(() => _speaking = false);
    }
  }

  Future<void> _speakCurrentPage() async {
    final story = findStory(widget.countryId);
    if (story == null || !_audioEnabled) return;

    final page = story.pages[_currentPage];
    await _tts.stop();
    setState(() => _speaking = true);
    await _tts.speak(page.text);
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    if (_audioEnabled) {
      _speakCurrentPage();
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = findStory(widget.countryId);

    if (story == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Story not found')),
      );
    }

    final country = findCountryById(widget.countryId);
    final isFirstPage = _currentPage == 0;
    final isLastPage = _currentPage == story.pageCount - 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _tts.stop();
                      context.pop();
                    },
                    icon: const Icon(Icons.chevron_left_rounded, size: 32),
                    color: PWColors.navy,
                  ),
                  Text(
                    '${country?.flagEmoji ?? ''} ${country?.name ?? widget.countryId}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                  ),
                  Text(
                    ' \u00B7 Story',
                    style: TextStyle(
                      fontSize: 16,
                      color: PWColors.navy.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _AudioToggle(
                    enabled: _audioEnabled,
                    speaking: _speaking,
                    onTap: _toggleAudio,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Page content (swipeable) ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: story.pageCount,
                onPageChanged: _onPageChanged,
                itemBuilder: (_, i) => _PageContent(
                  page: story.pages[i],
                  pageNumber: i + 1,
                  totalPages: story.pageCount,
                ),
              ),
            ),

            // ── Bottom nav ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  // Back
                  if (!isFirstPage)
                    Expanded(
                      child: _PillButton(
                        label: 'Back',
                        color: const Color(0xFFE8A838),
                        leadingText: '<  ',
                        onPressed: () => _goToPage(_currentPage - 1),
                      ),
                    )
                  else
                    const Spacer(),

                  // Page indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${_currentPage + 1} / ${story.pageCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: PWColors.navy.withValues(alpha: 0.4),
                      ),
                    ),
                  ),

                  // Next / Finish
                  Expanded(
                    child: _PillButton(
                      label: isLastPage ? 'Finish!' : 'Next',
                      color: isLastPage
                          ? PWColors.coral
                          : const Color(0xFF4CAF50),
                      trailingText: isLastPage ? null : '  >',
                      onPressed: () {
                        if (isLastPage) {
                          _tts.stop();
                          context.pushReplacement(
                            '/story/${widget.countryId}/complete',
                          );
                        } else {
                          _goToPage(_currentPage + 1);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Audio toggle
// ---------------------------------------------------------------------------

class _AudioToggle extends StatelessWidget {
  const _AudioToggle({
    required this.enabled,
    required this.speaking,
    required this.onTap,
  });

  final bool enabled;
  final bool speaking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? PWColors.blue
              : PWColors.navy.withValues(alpha: 0.08),
        ),
        child: Icon(
          enabled
              ? (speaking
                  ? Icons.graphic_eq_rounded
                  : Icons.volume_up_rounded)
              : Icons.volume_off_rounded,
          size: 22,
          color: enabled ? Colors.white : PWColors.navy.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pill-shaped nav button (golden Back, green Next)
// ---------------------------------------------------------------------------

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.leadingText,
    this.trailingText,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;
  final String? leadingText;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        minimumSize: const Size.fromHeight(50),
        elevation: 4,
        shadowColor: color.withValues(alpha: 0.4),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            if (leadingText != null)
              TextSpan(
                text: leadingText,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            if (trailingText != null)
              TextSpan(
                text: trailingText,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single page content (illustration + overlapping badge + text card)
// ---------------------------------------------------------------------------

class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.page,
    required this.pageNumber,
    required this.totalPages,
  });

  final StoryPage page;
  final int pageNumber;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Illustration area ──
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: page.bgColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: PWColors.navy.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: const TextStyle(fontSize: 100),
              ),
            ),
          ),
        ),

        // ── Text card area with overlapping progress badge ──
        Expanded(
          flex: 9,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Cream text card
              Positioned(
                top: 14,
                left: 20,
                right: 20,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF0),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: PWColors.navy.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.text,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontSize: 17,
                                height: 1.7,
                                color: PWColors.navy,
                              ),
                        ),
                        if (page.hasFact) ...[
                          const SizedBox(height: 16),
                          FactBubble(
                            fact: page.fact!,
                            category: page.factCategory,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Golden progress badge
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBB26A),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFCBB26A).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$pageNumber / $totalPages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
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
