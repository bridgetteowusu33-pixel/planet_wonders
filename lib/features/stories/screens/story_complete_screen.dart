import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../game_breaks/providers/game_break_settings_provider.dart';
import '../../game_breaks/widgets/game_break_prompt.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/story_data.dart';

/// Celebration screen shown after finishing a story.
///
/// Positive and encouraging — no scores, just a badge, stickers,
/// and an "Add to Passport" action. After a short delay, a gentle
/// game break prompt may appear if enabled by the parent.
class StoryCompleteScreen extends ConsumerStatefulWidget {
  const StoryCompleteScreen({super.key, required this.countryId});

  final String countryId;

  @override
  ConsumerState<StoryCompleteScreen> createState() =>
      _StoryCompleteScreenState();
}

class _StoryCompleteScreenState extends ConsumerState<StoryCompleteScreen> {
  bool _promptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowGameBreakPrompt();
    });
  }

  Future<void> _maybeShowGameBreakPrompt() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _promptShown) return;

    final settings = ref.read(gameBreakSettingsProvider);
    if (!settings.enabled || !settings.afterActivities) return;

    _promptShown = true;
    if (!mounted) return;

    showGameBreakPrompt(
      context,
      gameName: 'Memory Match',
      gameEmoji: '\u{1F0CF}', // 🃏
      onPlay: () {
        context.push('/game-break/memory/${widget.countryId}');
      },
      onDismiss: () {
        // Stay on celebration screen — kid can still use passport / go home.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = findStory(widget.countryId);
    final country = findCountryById(widget.countryId);
    final countryName = country?.name ??
        (widget.countryId[0].toUpperCase() + widget.countryId.substring(1));
    final stickers = _stickersFor(widget.countryId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Celebration emoji
                const Text(
                  '\u{1F389}', // 🎉
                  style: TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 16),

                Text(
                  'Story Complete!',
                  style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 28,
                          ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Great exploring!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: PWColors.navy.withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 24),

                // Badge card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: PWColors.yellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PWColors.yellow.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '\u{1F3C6}', // 🏆
                        style: TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        story?.badgeName ?? '$countryName Story Explorer',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Sticker row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < stickers.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _StickerChip(
                        emoji: stickers[i].$1,
                        label: stickers[i].$2,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 32),

                // Add to Passport button
                FilledButton.icon(
                  onPressed: () {
                    // TODO: Actually add to passport data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('$countryName added to your Passport!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text('Add $countryName to Passport'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: PWColors.yellow,
                    foregroundColor: PWColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Back to Home button
                OutlinedButton(
                  onPressed: () => context.go('/'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Country-specific stickers
// ---------------------------------------------------------------------------

List<(String, String)> _stickersFor(String countryId) {
  return switch (countryId) {
    'ghana' => [
      ('\u{1F3A8}', 'Kente'), // 🎨
      ('\u{1F941}', 'Drum'), // 🥁
      ('\u{1F451}', 'Crown'), // 👑
    ],
    'usa' => [
      ('\u{1F680}', 'Rocket'), // 🚀
      ('\u{1F4DA}', 'Books'), // 📚
      ('\u{1F3D4}\u{FE0F}', 'Nature'), // 🏔️
    ],
    _ => [
      ('\u{2B50}', 'Star'), // ⭐
      ('\u{1F30D}', 'Globe'), // 🌍
      ('\u{1F389}', 'Party'), // 🎉
    ],
  };
}

// ---------------------------------------------------------------------------

class _StickerChip extends StatelessWidget {
  const _StickerChip({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PWColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
