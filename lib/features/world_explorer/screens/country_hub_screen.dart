import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/audio/narration_service.dart';
import '../../../core/audio/narration_state.dart';
import '../../../core/theme/pw_theme.dart';
import '../data/world_data.dart';
import '../widgets/character_intro_card.dart';

/// The hub for a single country — shows activity cards the kid can explore.
class CountryHubScreen extends StatefulWidget {
  const CountryHubScreen({
    super.key,
    required this.continentId,
    required this.countryId,
  });

  final String continentId;
  final String countryId;

  @override
  State<CountryHubScreen> createState() => _CountryHubScreenState();
}

class _CountryHubScreenState extends State<CountryHubScreen> {
  static const _kVisitedPrefix = 'welcome_visited_';

  final _narration = NarrationService.instance;
  StreamSubscription<NarrationState>? _narrationSub;
  bool _speaking = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _narrationSub = _narration.stateStream.listen((state) {
      if (!mounted) return;
      setState(() => _speaking = state == NarrationState.playing);
    });
    _initAudio();
  }

  Future<void> _initAudio() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kVisitedPrefix${widget.countryId}';
    final visitedBefore = prefs.getBool(key) ?? false;

    if (visitedBefore) {
      // Auto-mute after first visit.
      setState(() => _muted = true);
    } else {
      // First visit — play welcome and mark as visited.
      await prefs.setBool(key, true);
      setState(() => _muted = false);
      _playWelcome();
    }
  }

  Future<void> _playWelcome() async {
    final country =
        findCountry(widget.continentId, widget.countryId);
    if (country == null) return;

    final fallback =
        '${country.greeting} Discover the wonders of ${country.name}!';
    await _narration.playWelcome(
      countryId: country.id,
      fallbackText: fallback,
    );
  }

  void _toggleMute() {
    final willMute = !_muted;
    setState(() => _muted = willMute);
    _narration.setMuted(willMute);
    if (willMute) {
      _narration.stop();
    } else {
      _playWelcome();
    }
  }

  /// Stop audio before navigating to a child screen.
  void _navigateTo(String path) {
    _narration.stop();
    context.push(path);
  }

  @override
  void dispose() {
    _narrationSub?.cancel();
    _narration.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final country =
        findCountry(widget.continentId, widget.countryId);

    if (country == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Country not found')),
      );
    }

    final bgPath = 'assets/backgrounds/country/${country.id}.png';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (country.flagAsset != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.asset(
                  country.flagAsset!,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Text(
                    country.flagEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  country.flagEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            Text(
              country.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: PWColors.navy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: PWColors.navy),
        actions: [
          // Audio mute/unmute toggle
          GestureDetector(
            onTap: _toggleMute,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _muted
                    ? PWColors.navy.withValues(alpha: 0.08)
                    : _speaking
                        ? PWColors.blue
                        : PWColors.blue.withValues(alpha: 0.15),
              ),
              child: Icon(
                _muted
                    ? Icons.volume_off_rounded
                    : _speaking
                        ? Icons.graphic_eq_rounded
                        : Icons.volume_up_rounded,
                size: 20,
                color: _muted
                    ? PWColors.navy.withValues(alpha: 0.5)
                    : _speaking
                        ? Colors.white
                        : PWColors.blue,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _narration.stop();
              context.go('/');
            },
            icon: const Icon(Icons.home_rounded, color: PWColors.navy),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Country-specific background image
          Image.asset(
            bgPath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          // Semi-transparent overlay for readability
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
          SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // --- Banner ---
                  _CountryBanner(
                    flagEmoji: country.flagEmoji,
                    flagAsset: country.flagAsset,
                    greeting: country.greeting,
                    countryName: country.name,
                    localGreeting: country.localGreeting,
                  ),

                  const SizedBox(height: 12),

                  // --- Meet the Characters ---
                  CharacterIntroCard(countryId: country.id),

                  const SizedBox(height: 12),

                  // --- Activity grid ---
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      _ActivitySticker(
                        label: 'Color',
                        iconAsset: 'assets/icons/crayon.webp',
                        fallbackEmoji: '\u{1F58D}',
                        gradientTop: const Color(0xFFFF6B5F),
                        gradientBottom: const Color(0xFFE23C2D),
                        onTap: () => _navigateTo('/color/${country.id}'),
                      ),
                      _ActivitySticker(
                        label: 'Story',
                        iconAsset: 'assets/icons/book.webp',
                        fallbackEmoji: '\u{1F4D6}',
                        gradientTop: const Color(0xFF2F9DFF),
                        gradientBottom: const Color(0xFF215AE5),
                        onTap: () => _navigateTo('/story/${country.id}'),
                      ),
                      _ActivitySticker(
                        label: 'Fashion',
                        iconAsset: 'assets/icons/dress.webp',
                        fallbackEmoji: '\u{1F457}',
                        gradientTop: const Color(0xFF5BE3CF),
                        gradientBottom: const Color(0xFF20AFA0),
                        onTap: () => _navigateTo('/fashion/${country.id}'),
                      ),
                      _ActivitySticker(
                        label: 'Food',
                        iconAsset: 'assets/icons/cooking.webp',
                        fallbackEmoji: '\u{1F373}',
                        gradientTop: const Color(0xFFFFC23B),
                        gradientBottom: const Color(0xFFEA8B1D),
                        onTap: () => _navigateTo('/food/${country.id}'),
                      ),
                      _ActivitySticker(
                        label: 'Games',
                        iconAsset: 'assets/icons/games.png',
                        fallbackEmoji: '\u{1F3AE}',
                        gradientTop: const Color(0xFF9C5FFF),
                        gradientBottom: const Color(0xFF6B3FA0),
                        onTap: () =>
                            _navigateTo('/games?countryId=${country.id}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
          ),
        ],
      ),
    );
  }

}

/// Illustrated banner for the country hub.
///
/// Shows the country flag prominently at the top with greeting text below.
class _CountryBanner extends StatelessWidget {
  const _CountryBanner({
    required this.flagEmoji,
    this.flagAsset,
    required this.greeting,
    required this.countryName,
    this.localGreeting,
  });

  final String flagEmoji;
  final String? flagAsset;
  final String greeting;
  final String countryName;
  final String? localGreeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PWColors.yellow.withValues(alpha: 0.35),
            PWColors.mint.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Flag — pinned to the top, fills width
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: _buildFlag(),
          ),
          // Text content inside the box
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              children: [
                if (localGreeting != null) ...[
                  Text(
                    localGreeting!,
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: PWColors.navy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: PWColors.navy,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover the wonders of $countryName!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        color: PWColors.navy,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlag() {
    if (flagAsset != null) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(<double>[
            1.1, 0, 0, 0, -10, //
            0, 1.1, 0, 0, -10, //
            0, 0, 1.1, 0, -10, //
            0, 0, 0, 1, 0, //
          ]),
          child: Image.asset(
            flagAsset!,
            height: 130,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 130,
              alignment: Alignment.center,
              child: Text(flagEmoji, style: const TextStyle(fontSize: 64)),
            ),
          ),
        ),
      );
    }
    return Container(
      height: 130,
      alignment: Alignment.center,
      child: Text(flagEmoji, style: const TextStyle(fontSize: 72)),
    );
  }
}

/// 3D sticker-style activity button matching the home screen design.
class _ActivitySticker extends StatelessWidget {
  const _ActivitySticker({
    required this.label,
    required this.iconAsset,
    required this.fallbackEmoji,
    required this.gradientTop,
    required this.gradientBottom,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final String fallbackEmoji;
  final Color gradientTop;
  final Color gradientBottom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final iconCache = (78 * dpr).round().clamp(1, 512).toInt();

    const radius = BorderRadius.all(Radius.circular(28));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: Color.lerp(gradientBottom, Colors.black, 0.35)
              ?.withValues(alpha: 0.45),
        ),
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradientTop.withValues(alpha: 0.6),
                gradientBottom.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Top shine highlight
              Positioned(
                left: 6,
                right: 6,
                top: 6,
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.45),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        iconAsset,
                        fit: BoxFit.contain,
                        cacheWidth: iconCache,
                        cacheHeight: iconCache,
                        filterQuality: FilterQuality.low,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              fallbackEmoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 26,
                      child: Center(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
