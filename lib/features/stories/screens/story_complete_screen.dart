import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/passport_service.dart';
import '../../../core/theme/pw_theme.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../../stickers/providers/sticker_provider.dart';
import '../../stickers/ui/sticker_chip.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/story_data.dart';

/// Celebration screen shown after finishing a story.
///
/// Shows which stickers were unlocked, how to earn the rest,
/// and an "Add to Passport" action.
class StoryCompleteScreen extends ConsumerStatefulWidget {
  const StoryCompleteScreen({super.key, required this.countryId});

  final String countryId;

  @override
  ConsumerState<StoryCompleteScreen> createState() =>
      _StoryCompleteScreenState();
}

class _StoryCompleteScreenState extends ConsumerState<StoryCompleteScreen> {
  bool _alreadyAdded = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkPassportStatus();
  }

  Future<void> _checkPassportStatus() async {
    final badges = await PassportService.unlockedBadges();
    if (!mounted) return;
    setState(() {
      _alreadyAdded = badges.contains('story_complete_${widget.countryId}');
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final story = findStory(widget.countryId);
    final country = findCountryById(widget.countryId);
    final countryName = country?.name ??
        (widget.countryId[0].toUpperCase() + widget.countryId.substring(1));
    final stickerState = ref.watch(stickerProvider);
    final countryStickers =
        stickerState.stickersForCountry(widget.countryId);

    // Split stickers into unlocked (story_completed) vs others
    final unlockedStickers = <_StickerInfo>[];
    final lockedStickers = <_StickerInfo>[];

    for (final sticker in countryStickers) {
      final collected = stickerState.isCollected(sticker.id);
      if (collected) {
        unlockedStickers.add(_StickerInfo(sticker: sticker, collected: true));
      } else {
        lockedStickers.add(_StickerInfo(sticker: sticker, collected: false));
      }
    }

    // Group locked stickers by activity type for hints
    final lockedByType = <String, int>{};
    for (final info in lockedStickers) {
      final type = info.sticker.earnCondition.type;
      lockedByType[type] = (lockedByType[type] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
                  const SizedBox(height: 20),

                  // Add to Passport (top position)
                  if (_loading)
                    const SizedBox.shrink()
                  else if (_alreadyAdded)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: PWColors.mint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: PWColors.mint.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: PWColors.mint,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$countryName is in your Passport!',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: PWColors.navy,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await PassportService.unlockBadge(
                          'story_complete_${widget.countryId}',
                        );
                        ref.invalidate(passportBadgesProvider);
                        ref.read(achievementProvider.notifier).markStoryCompleted(
                              countryId: widget.countryId,
                            );
                        ref.read(stickerProvider.notifier).checkAndAward(
                              conditionType: 'story_completed',
                              countryId: widget.countryId,
                            );
                        if (!mounted) return;
                        setState(() => _alreadyAdded = true);
                        messenger.showSnackBar(
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

                  const SizedBox(height: 20),

                  // --- Stickers unlocked section ---
                  if (unlockedStickers.isNotEmpty) ...[
                    Text(
                      unlockedStickers.length == 1
                          ? 'Sticker Unlocked!'
                          : '${unlockedStickers.length} Stickers Unlocked!',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: PWColors.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final info in unlockedStickers)
                          StickerChip(
                            sticker: info.sticker,
                            isCollected: true,
                          ),
                      ],
                    ),
                  ],

                  // --- Locked stickers + how to unlock ---
                  if (lockedStickers.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: PWColors.blue.withValues(alpha: 0.08),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${lockedStickers.length} more stickers to collect!',
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: PWColors.navy,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _buildUnlockHint(lockedByType),
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: PWColors.navy.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final info in lockedStickers)
                                StickerChip(
                                  sticker: info.sticker,
                                  isCollected: false,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

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
      ),
    );
  }

  /// Build a friendly hint telling kids which activities unlock more stickers.
  String _buildUnlockHint(Map<String, int> lockedByType) {
    final activities = <String>[];
    for (final type in lockedByType.keys) {
      final name = _activityName(type);
      if (name != null) activities.add(name);
    }
    if (activities.isEmpty) return 'Keep exploring to earn more!';
    if (activities.length == 1) return 'Try ${activities.first} to unlock them!';
    final last = activities.removeLast();
    return 'Try ${activities.join(", ")} and $last to unlock them!';
  }

  String? _activityName(String conditionType) {
    return switch (conditionType) {
      'cooking_completed' => 'cooking recipes',
      'coloring_completed' => 'coloring pages',
      'quiz_completed' => 'quizzes',
      'pack_suitcase_completed' => 'packing suitcases',
      'drawing_saved' => 'drawing pictures',
      'story_completed' => 'reading stories',
      _ => null,
    };
  }
}

class _StickerInfo {
  const _StickerInfo({required this.sticker, required this.collected});
  final dynamic sticker;
  final bool collected;
}
