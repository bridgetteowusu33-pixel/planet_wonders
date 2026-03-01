import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../achievements/providers/achievement_provider.dart';
import '../../learning_report/models/learning_stats.dart';
import '../../learning_report/providers/learning_stats_provider.dart';
import '../../stickers/providers/sticker_provider.dart';
import '../data/rush_mission_builder.dart';
import '../models/ingredient_rush_state.dart';
import '../models/rush_difficulty.dart';
import '../models/rush_mission.dart';
import '../providers/ingredient_rush_controller.dart';
import 'rush_dish_picker_screen.dart';
import 'rush_gameplay_screen.dart';
import 'rush_intro_screen.dart';
import 'rush_retry_screen.dart';
import 'rush_success_screen.dart';

/// Top-level shell for Ingredient Rush.
///
/// Flow: dish picker → intro/briefing → playing → success/timeUp.
/// If a specific [recipeId] is provided, skips the dish picker.
class IngredientRushScreen extends ConsumerStatefulWidget {
  const IngredientRushScreen({
    super.key,
    required this.countryId,
    this.recipeId,
    this.initialDifficulty = 'easy',
  });

  final String countryId;
  final String? recipeId;
  final String initialDifficulty;

  @override
  ConsumerState<IngredientRushScreen> createState() =>
      _IngredientRushScreenState();
}

class _IngredientRushScreenState extends ConsumerState<IngredientRushScreen> {
  RushMission? _mission;
  late List<RushMission> _allMissions;
  RushDifficulty _selectedDifficulty = RushDifficulty.easy;

  /// Whether we're still on the dish picker (no mission selected yet).
  bool get _showingPicker => _mission == null;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = _parseDifficulty(widget.initialDifficulty);
    _allMissions = RushMissionBuilder.missionsForCountry(widget.countryId);

    // If a specific recipe was requested, skip the picker.
    if (widget.recipeId != null) {
      final m = RushMissionBuilder.buildMission(widget.recipeId!);
      if (m != null) _mission = m;
    }
  }

  RushDifficulty _parseDifficulty(String raw) {
    return switch (raw) {
      'medium' => RushDifficulty.medium,
      'hard' => RushDifficulty.hard,
      _ => RushDifficulty.easy,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_allMissions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'No recipes found for ${widget.countryId}.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    final state = ref.watch(ingredientRushProvider);

    // Log achievement + learning report on success.
    ref.listen(ingredientRushProvider, (prev, next) {
      final m = _mission;
      if (m == null) return;
      if (prev?.phase != RushPhase.success &&
          next.phase == RushPhase.success) {
        ref.read(achievementProvider.notifier).markIngredientRushCompleted(
              countryId: m.countryId,
              recipeId: m.recipeId,
              wrongTaps: next.wrongTaps,
              timerFractionRemaining: next.timerFraction,
            );
        ref.read(learningStatsProvider.notifier).logActivity(
              ActivityLogEntry(
                id: '${DateTime.now().millisecondsSinceEpoch}',
                type: ActivityType.game,
                label: 'Ingredient Rush: ${m.recipeName}',
                countryId: m.countryId,
                timestamp: DateTime.now(),
                emoji: '\u{1F3AF}', // 🎯
              ),
            );
        ref.read(stickerProvider.notifier).checkAndAward(
              conditionType: 'cooking_completed',
              countryId: m.countryId,
            );
      }
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF8EDBFF),
              Color(0xFFBDEBFF),
              Color(0xFFE6F9FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Kitchen background.
            Positioned.fill(
              child: IgnorePointer(
                child: _kitchenBackground(widget.countryId),
              ),
            ),

            // Phase content.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _showingPicker
                  ? RushDishPickerScreen(
                      key: const ValueKey<String>('dish_picker'),
                      countryId: widget.countryId,
                      missions: _allMissions,
                      onPick: (mission) {
                        setState(() => _mission = mission);
                      },
                    )
                  : _buildPhase(state),
            ),

            // Back button.
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 8,
              child: IconButton(
                onPressed: () {
                  // If on intro and came from the picker, go back to picker.
                  if (!_showingPicker &&
                      state.phase == RushPhase.intro &&
                      widget.recipeId == null) {
                    setState(() => _mission = null);
                    return;
                  }
                  Navigator.of(context).maybePop();
                },
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase(IngredientRushState state) {
    final m = _mission!;
    return switch (state.phase) {
      RushPhase.intro => RushIntroScreen(
          key: const ValueKey<RushPhase>(RushPhase.intro),
          mission: m,
          difficulty: _selectedDifficulty,
          onDifficultyChanged: (d) => setState(() => _selectedDifficulty = d),
          onStart: () {
            ref
                .read(ingredientRushProvider.notifier)
                .startMission(m, _selectedDifficulty);
          },
        ),
      RushPhase.playing => RushGameplayScreen(
          key: const ValueKey<RushPhase>(RushPhase.playing),
          countryId: widget.countryId,
        ),
      RushPhase.success => RushSuccessScreen(
          key: const ValueKey<RushPhase>(RushPhase.success),
          mission: m,
          wrongTaps: state.wrongTaps,
          timerFractionRemaining: state.timerFraction,
        ),
      RushPhase.timeUp => RushRetryScreen(
          key: const ValueKey<RushPhase>(RushPhase.timeUp),
          mission: m,
          onRetry: () {
            ref.read(ingredientRushProvider.notifier).retry();
          },
        ),
    };
  }

  static Widget _kitchenBackground(String countryId) {
    final id = countryId.trim().toLowerCase();
    return Image.asset(
      'assets/cooking/v2/$id/kitchen_bg.webp',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}
