import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/pw_theme.dart';
import '../data/character_intros.dart';

// ---------------------------------------------------------------------------
// First-visit tracking
// ---------------------------------------------------------------------------

const _kVisitedCountries = 'character_intro_visited';

Future<bool> _hasVisitedCountry(String countryId) async {
  final prefs = await SharedPreferences.getInstance();
  final visited = prefs.getStringList(_kVisitedCountries) ?? const <String>[];
  return visited.contains(countryId);
}

Future<void> _markCountryVisited(String countryId) async {
  final prefs = await SharedPreferences.getInstance();
  final visited =
      (prefs.getStringList(_kVisitedCountries) ?? const <String>[]).toSet();
  visited.add(countryId);
  await prefs.setStringList(_kVisitedCountries, visited.toList(growable: false));
}

// ---------------------------------------------------------------------------
// Character Intro Card
// ---------------------------------------------------------------------------

/// An animated "Meet the Characters" card shown on the country hub.
///
/// First visit: full intro with speech bubbles, name meaning, facts.
/// Returning visit: compact "Welcome back!" greeting (tappable to expand).
class CharacterIntroCard extends StatefulWidget {
  const CharacterIntroCard({super.key, required this.countryId});

  final String countryId;

  @override
  State<CharacterIntroCard> createState() => _CharacterIntroCardState();
}

class _CharacterIntroCardState extends State<CharacterIntroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  CharacterIntro? _intro;
  bool _isFirstVisit = true;
  bool _expanded = false;
  bool _loaded = false;
  bool _showNameMeaning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _intro = characterIntroFor(widget.countryId);
    _loadVisitState();
  }

  Future<void> _loadVisitState() async {
    final visited = await _hasVisitedCountry(widget.countryId);
    if (!mounted) return;
    setState(() {
      _isFirstVisit = !visited;
      _expanded = !visited; // auto-expand on first visit
      _loaded = true;
    });
    _controller.forward();
    // Mark as visited after showing
    if (!visited) {
      _markCountryVisited(widget.countryId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_intro == null || !_loaded) return const SizedBox.shrink();

    final intro = _intro!;

    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PWColors.blue.withValues(alpha: 0.12),
              PWColors.mint.withValues(alpha: 0.15),
            ],
          ),
          border: Border.all(
            color: PWColors.blue.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header (always visible) ---
            _buildHeader(intro),

            // --- Expanded content ---
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(intro),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 350),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CharacterIntro intro) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Character avatar
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PWColors.yellow.withValues(alpha: 0.3),
                border: Border.all(
                  color: PWColors.yellow.withValues(alpha: 0.5),
                  width: 2.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                intro.characterAvatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    intro.characterEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Greeting text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isFirstVisit
                        ? intro.greeting
                        : 'Welcome back! \u{2014} ${intro.characterName}',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PWColors.navy,
                    ),
                  ),
                  if (!_expanded)
                    Text(
                      'Tap to meet ${intro.characterName}!',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: PWColors.navy,
                      ),
                    ),
                ],
              ),
            ),
            // Expand/collapse chevron
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.expand_more_rounded,
                color: PWColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(CharacterIntro intro) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Speech bubble: self intro ---
          _SpeechBubble(text: intro.selfIntro),

          const SizedBox(height: 12),

          // --- Name meaning (tappable) ---
          GestureDetector(
            onTap: () => setState(() => _showNameMeaning = !_showNameMeaning),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: PWColors.yellow.withValues(alpha: 0.25),
                border: Border.all(
                  color: PWColors.yellow.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Text('\u{2728}', style: TextStyle(fontSize: 18)), // ✨
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedCrossFade(
                      firstChild: Text(
                        'Tap to learn what my name means!',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: PWColors.navy,
                        ),
                      ),
                      secondChild: Text(
                        intro.nameMeaning,
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: PWColors.navy,
                        ),
                      ),
                      crossFadeState: _showNameMeaning
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- Country facts ---
          Text(
            'Did you know?',
            style: GoogleFonts.fredoka(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: PWColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          ...intro.countryFacts.map(
            (fact) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _FactChip(text: fact),
            ),
          ),

          const SizedBox(height: 10),

          // --- Sign-off ---
          _SpeechBubble(
            text: intro.signOff,
            color: PWColors.mint.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Speech bubble
// ---------------------------------------------------------------------------

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color ?? PWColors.blue.withValues(alpha: 0.08),
      ),
      child: Text(
        text,
        style: GoogleFonts.fredoka(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: PWColors.navy,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fact chip
// ---------------------------------------------------------------------------

class _FactChip extends StatelessWidget {
  const _FactChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PWColors.coral.withValues(alpha: 0.2),
            ),
            alignment: Alignment.center,
            child: const Text('\u{1F31F}',
                style: TextStyle(fontSize: 12)), // 🌟
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.fredoka(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: PWColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}
