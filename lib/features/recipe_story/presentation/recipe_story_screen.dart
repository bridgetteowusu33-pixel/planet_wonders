import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../../achievements/ui/badge_unlock_animation.dart';
import '../data/recipe_story_repository.dart';
import '../domain/character_expression.dart';
import '../domain/recipe.dart';
import '../engine/audio_manager.dart';
import '../providers/recipe_album_provider.dart';
import '../providers/recipe_controller.dart';
import 'scenes/step_scene.dart';
import 'widgets/culture_panel.dart';
import 'widgets/journey_map.dart';
import 'widgets/reward_popup.dart';
import 'widgets/story_hero_header.dart';

// ---------------------------------------------------------------------------
// Entry widget — loads recipe data, then renders the body
// ---------------------------------------------------------------------------

class RecipeStoryScreen extends StatefulWidget {
  const RecipeStoryScreen({
    super.key,
    required this.countryId,
    required this.recipeId,
    this.source = 'food',
  });

  final String countryId;
  final String recipeId;
  final String source;

  @override
  State<RecipeStoryScreen> createState() => _RecipeStoryScreenState();
}

class _RecipeStoryScreenState extends State<RecipeStoryScreen> {
  late final Future<RecipeStory?> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = RecipeStoryRepository.instance.loadRecipe(
      countryId: widget.countryId,
      recipeId: widget.recipeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecipeStory?>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Recipe story not found.')),
          );
        }

        return _RecipeStoryBody(
          key: ValueKey('${widget.countryId}-${widget.recipeId}'),
          countryId: widget.countryId,
          source: widget.source,
          recipe: snapshot.data!,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Main body — orchestrates all V2 views
// ---------------------------------------------------------------------------

class _RecipeStoryBody extends ConsumerStatefulWidget {
  const _RecipeStoryBody({
    super.key,
    required this.countryId,
    required this.source,
    required this.recipe,
  });

  final String countryId;
  final String source;
  final RecipeStory recipe;

  @override
  ConsumerState<_RecipeStoryBody> createState() => _RecipeStoryBodyState();
}

class _RecipeStoryBodyState extends ConsumerState<_RecipeStoryBody> {
  final Set<String> _precachedAssets = <String>{};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeStoryControllerProvider);
    final controller = ref.read(recipeStoryControllerProvider.notifier);

    // Listen for state changes to trigger side effects.
    ref.listen<RecipeStoryState>(recipeStoryControllerProvider, (prev, next) {
      _onStateChanged(prev, next);
    });

    _schedulePrecache(state);

    // Determine if we're on a tablet-width screen.
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Mute toggle
          IconButton(
            icon: Icon(
              RecipeAudioManager.instance.isMuted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                RecipeAudioManager.instance.toggleMute();
              });
            },
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFFFF6EA), Color(0xFFFFFCEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 32 : 16,
                  8,
                  isTablet ? 32 : 16,
                  16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: !state.started
                        ? _IntroView(
                            recipe: widget.recipe,
                            countryId: widget.countryId,
                            source: widget.source,
                            onStart: () => controller.startStory(widget.recipe),
                          )
                        : state.completed
                        ? _CompletedView(
                            recipe: widget.recipe,
                            countryId: widget.countryId,
                            earnedRewards: state.earnedRewards,
                            onReplay: controller.restart,
                            onDone: () => Navigator.of(context).pop(true),
                          )
                        : _StepFlowView(
                            recipe: widget.recipe,
                            countryId: widget.countryId,
                            state: state,
                            onTapAction: () =>
                                controller.completeTapAction(widget.recipe),
                            onDragAction: () =>
                                controller.completeDragAction(widget.recipe),
                            onProgress: (delta, actions) =>
                                controller.addProgress(
                                  widget.recipe,
                                  delta: delta,
                                  actions: actions,
                                ),
                            onDismissReward: controller.dismissReward,
                          ),
                  ),
                ),
              ),
              const BadgeUnlockAnimationListener(),
            ],
          ),
        ),
      ),
    );
  }

  void _onStateChanged(RecipeStoryState? previous, RecipeStoryState next) {
    if (previous == null) return;

    final justCompleted = next.completed && !previous.completed;
    final startedNow = next.started && !previous.started;
    final stepChanged = next.stepIndex != previous.stepIndex && !next.completed;
    final rewardPopped = next.showingReward && !previous.showingReward;

    if (startedNow) {
      final firstStep = widget.recipe.steps.isNotEmpty
          ? widget.recipe.steps.first
          : null;
      if (firstStep != null) {
        final introLine = expressionForAction(firstStep.actionKey).message;
        Future<void>.microtask(
          () => RecipeAudioManager.instance.playNarration(introLine),
        );
      }
    }

    if (stepChanged &&
        next.stepIndex >= 0 &&
        next.stepIndex < widget.recipe.steps.length) {
      final step = widget.recipe.steps[next.stepIndex];
      final line = expressionForAction(step.actionKey).message;
      Future<void>.microtask(() async {
        await RecipeAudioManager.instance.playSfx(step.sfx ?? 'tap');
        await RecipeAudioManager.instance.playNarration(line);
      });
    }

    if (rewardPopped) {
      Future<void>.microtask(
        () => RecipeAudioManager.instance.playSfx('reward'),
      );
    }

    if (justCompleted) {
      Future<void>.microtask(() async {
        await RecipeAudioManager.instance.playSfx('fanfare');
        await RecipeAudioManager.instance.playNarration(
          'Dish complete! You are a master chef!',
        );
      });

      // Save to album and mark achievement.
      Future<void>.microtask(() {
        ref
            .read(recipeAlbumProvider.notifier)
            .saveCompletion(
              recipe: widget.recipe,
              countryId: widget.countryId,
              earnedRewards: next.earnedRewards,
            );
        ref
            .read(achievementProvider.notifier)
            .markRecipeStoryCompleted(
              countryId: widget.countryId,
              recipeId: widget.recipe.id,
            );
      });
    }
  }

  void _schedulePrecache(RecipeStoryState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _precacheAsset(widget.recipe.imageAsset);
      _precacheAsset(widget.recipe.thumbnailAsset);
      _precacheAsset(widget.recipe.completionAsset);
      _precacheAsset(_assetForStep(state.stepIndex));
      _precacheAsset(_assetForStep(state.stepIndex + 1));
    });
  }

  String? _assetForStep(int index) {
    if (index < 0 || index >= widget.recipe.steps.length) return null;
    return widget.recipe.steps[index].asset;
  }

  Future<void> _precacheAsset(String? path) async {
    if (path == null || path.isEmpty || _precachedAssets.contains(path)) return;
    _precachedAssets.add(path);
    try {
      await rootBundle.load(path);
      if (!mounted) return;
      await precacheImage(AssetImage(path), context);
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Intro View
// ---------------------------------------------------------------------------

class _IntroView extends StatefulWidget {
  const _IntroView({
    required this.recipe,
    required this.countryId,
    required this.source,
    required this.onStart,
  });

  final RecipeStory recipe;
  final String countryId;
  final String source;
  final VoidCallback onStart;

  @override
  State<_IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<_IntroView> with TickerProviderStateMixin {
  late final AnimationController _floatAnim;
  late final AnimationController _pulseAnim;
  late final AnimationController _fadeAnim;

  @override
  void initState() {
    super.initState();
    _floatAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _fadeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _floatAnim.dispose();
    _pulseAnim.dispose();
    _fadeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterEmoji = characterForCountry(widget.countryId);
    final characterName = characterNameForCountry(widget.countryId);
    final header = widget.source == 'food'
        ? 'Let\'s cook with a story!'
        : 'Cooking story time!';

    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeAnim, curve: Curves.easeOut),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: PWColors.navy.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Character greeting
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            characterEmoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$characterName says: Let\'s cook!',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: PWColors.coral,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Floating recipe image
                      AnimatedBuilder(
                        animation: _floatAnim,
                        builder: (context, child) {
                          final t = _floatAnim.value;
                          final bob = math.sin(t * math.pi) * 8;
                          final tilt = math.sin(t * math.pi) * 0.015;
                          return Transform.translate(
                            offset: Offset(0, bob),
                            child: Transform.rotate(angle: tilt, child: child),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: PWColors.coral.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              widget.recipe.imageAsset,
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                              cacheWidth: 900,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          PWColors.coral.withValues(
                                            alpha: 0.15,
                                          ),
                                          PWColors.yellow.withValues(
                                            alpha: 0.15,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.recipe.emoji,
                                        style: const TextStyle(fontSize: 80),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Title
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              PWColors.coral.withValues(alpha: 0.12),
                              PWColors.yellow.withValues(alpha: 0.12),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${widget.recipe.emoji} ${widget.recipe.title}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              header,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: PWColors.coral,
                                    fontWeight: FontWeight.w700,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.recipe.intro,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.recipe.introFact != null) ...[
                        const SizedBox(height: 10),
                        CulturePanel(fact: widget.recipe.introFact!),
                      ],
                      const SizedBox(height: 10),
                      // Info chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _InfoChip(
                            icon: Icons.format_list_numbered_rounded,
                            label: '${widget.recipe.steps.length} steps',
                            color: PWColors.blue,
                          ),
                          const SizedBox(width: 10),
                          _InfoChip(
                            icon: Icons.star_rounded,
                            label: widget.recipe.difficultyLabel,
                            color: _difficultyColor(
                              widget.recipe.safeDifficulty,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Start button
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) {
                    final scale = 1.0 + _pulseAnim.value * 0.03;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: FilledButton.icon(
                    onPressed: widget.onStart,
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: const Text(
                      'Start Cooking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      backgroundColor: PWColors.coral,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
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
// Step Flow View — the core gameplay loop
// ---------------------------------------------------------------------------

class _StepFlowView extends StatefulWidget {
  const _StepFlowView({
    required this.recipe,
    required this.countryId,
    required this.state,
    required this.onTapAction,
    required this.onDragAction,
    required this.onProgress,
    required this.onDismissReward,
  });

  final RecipeStory recipe;
  final String countryId;
  final RecipeStoryState state;
  final VoidCallback onTapAction;
  final VoidCallback onDragAction;
  final _ProgressCallback onProgress;
  final VoidCallback onDismissReward;

  @override
  State<_StepFlowView> createState() => _StepFlowViewState();
}

class _StepFlowViewState extends State<_StepFlowView> {
  String? _selectedChoice;

  @override
  Widget build(BuildContext context) {
    final step = widget.recipe.steps[widget.state.stepIndex];
    final sceneTitle = _sceneTitleForAction(step.actionKey);
    final helperText = _helperForAction(step.actionKey);
    final choices = _choicesForAction(step.actionKey);

    return Column(
      children: [
        if (widget.state.expression != null)
          StoryHeroHeader(
            countryId: widget.countryId,
            expression: widget.state.expression!,
            actionKey: step.actionKey,
          ),
        const SizedBox(height: 8),
        _StepStoryCard(
          stepIndex: widget.state.stepIndex,
          totalSteps: widget.recipe.steps.length,
          title: sceneTitle,
          story: step.story,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: RepaintBoundary(
                  key: ValueKey<String>(
                    'scene_${widget.state.stepIndex}_${step.actionKey}',
                  ),
                  child: StepScene.forStep(
                    step: step,
                    progress: widget.state.stepProgress,
                    interactionCount: widget.state.interactionCount,
                    onTapAction: widget.onTapAction,
                    onDragAccepted: widget.onDragAction,
                    onProgressDelta: (delta) {
                      widget.onProgress(delta, {
                        RecipeActionType.stir,
                        RecipeActionType.hold,
                        RecipeActionType.shake,
                      });
                    },
                  ),
                ),
              ),
              if (widget.state.showingReward && widget.state.lastReward != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: RewardPopup(
                    reward: widget.state.lastReward!,
                    onDismiss: widget.onDismissReward,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _HelperPanel(
          helperText: helperText,
          choices: choices,
          selectedChoice: _selectedChoice,
          onChoiceSelected: (choice) =>
              setState(() => _selectedChoice = choice),
        ),
        if (step.fact != null) ...[
          const SizedBox(height: 6),
          CulturePanel(fact: step.fact!),
        ],
        const SizedBox(height: 8),
        JourneyMap(
          steps: widget.recipe.steps,
          currentStep: widget.state.stepIndex,
        ),
      ],
    );
  }

  String _sceneTitleForAction(String actionKey) {
    return switch (actionKey) {
      'tap_bowl' => 'Rain Time!',
      'tap_chop' => 'Chop Time!',
      'drag_oil_to_pot' => 'Pour Slowly!',
      'drag_tomato_mix' => 'Tomato Splash!',
      'tap_spice_shaker' => 'Spice Sparkles!',
      'stir_circle' || 'stir' => 'Swirl Magic!',
      'hold_to_cook' || 'hold' || 'hold_cook' => 'Steam Moment!',
      _ => 'Cooking Moment!',
    };
  }

  String _helperForAction(String actionKey) {
    return switch (actionKey) {
      'tap_bowl' => 'Tap fast to make rain drops wash the rice.',
      'tap_chop' => 'Quick taps make tiny chopped pieces.',
      'drag_oil_to_pot' => 'Drag the bottle and drop when the pot glows.',
      'drag_tomato_mix' => 'Drag tomatoes into the pot for rich color.',
      'tap_spice_shaker' => 'Tap repeatedly for extra flavor.',
      'stir_circle' ||
      'stir' => 'Draw big circles. Smooth stirring earns more stars.',
      'hold_to_cook' ||
      'hold' ||
      'hold_cook' => 'Press and hold gently while steam rises.',
      _ => 'Follow Afia and complete this story step.',
    };
  }

  List<String> _choicesForAction(String actionKey) {
    if (actionKey == 'tap_spice_shaker') {
      return const <String>['Mild 🌿', 'Spicy 🌶️'];
    }
    if (actionKey == 'drag_tomato_mix') {
      return const <String>['More Tomato 🍅', 'Less Tomato 🥄'];
    }
    if (actionKey == 'drag_oil_to_pot') {
      return const <String>['Less Oil 💧', 'Normal Oil 🫙'];
    }
    return const <String>[];
  }
}

class _StepStoryCard extends StatelessWidget {
  const _StepStoryCard({
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.story,
  });

  final int stepIndex;
  final int totalSteps;
  final String title;
  final String story;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              PWColors.yellow.withValues(alpha: 0.2),
              PWColors.coral.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PWColors.yellow.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Step ${stepIndex + 1}/$totalSteps',
                  style: TextStyle(
                    fontSize: 11,
                    color: PWColors.navy.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: PWColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              story,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelperPanel extends StatelessWidget {
  const _HelperPanel({
    required this.helperText,
    required this.choices,
    required this.selectedChoice,
    required this.onChoiceSelected,
  });

  final String helperText;
  final List<String> choices;
  final String? selectedChoice;
  final ValueChanged<String> onChoiceSelected;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PWColors.blue.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Helper Hint',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PWColors.blue,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              helperText,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            if (choices.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: choices
                    .map(
                      (choice) => ChoiceChip(
                        label: Text(choice),
                        selected: choice == selectedChoice,
                        onSelected: (_) => onChoiceSelected(choice),
                        selectedColor: PWColors.mint.withValues(alpha: 0.24),
                        side: BorderSide(
                          color: PWColors.navy.withValues(alpha: 0.14),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Completed View
// ---------------------------------------------------------------------------

class _CompletedView extends StatefulWidget {
  const _CompletedView({
    required this.recipe,
    required this.countryId,
    required this.earnedRewards,
    required this.onReplay,
    required this.onDone,
  });

  final RecipeStory recipe;
  final String countryId;
  final List earnedRewards;
  final VoidCallback onReplay;
  final VoidCallback onDone;

  @override
  State<_CompletedView> createState() => _CompletedViewState();
}

class _CompletedViewState extends State<_CompletedView>
    with TickerProviderStateMixin {
  late final AnimationController _entranceAnim;
  late final AnimationController _starAnim;
  late final AnimationController _badgeAnim;

  @override
  void initState() {
    super.initState();
    _entranceAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _starAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _badgeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _starAnim.forward();
    });
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _badgeAnim.forward();
    });
  }

  @override
  void dispose() {
    _entranceAnim.dispose();
    _starAnim.dispose();
    _badgeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterEmoji = characterForCountry(widget.countryId);
    final characterName = characterNameForCountry(widget.countryId);

    return FadeTransition(
      opacity: CurvedAnimation(parent: _entranceAnim, curve: Curves.easeOut),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        PWColors.yellow.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: PWColors.navy.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Celebration emoji
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _entranceAnim,
                          curve: Curves.elasticOut,
                        ),
                        child: const Text(
                          '\u{1F389}',
                          style: TextStyle(fontSize: 52),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Well done!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You made ${widget.recipe.title}!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: PWColors.navy.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Character congratulation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            characterEmoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$characterName: "Amazing job, chef!"',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  color: PWColors.coral,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Completion image
                      if (widget.recipe.completionAsset != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            widget.recipe.completionAsset!,
                            width: 260,
                            height: 200,
                            fit: BoxFit.cover,
                            cacheWidth: 980,
                            errorBuilder: (context, error, stackTrace) =>
                                const Text(
                                  '\u{1F37D}\u{FE0F}',
                                  style: TextStyle(fontSize: 62),
                                ),
                          ),
                        )
                      else
                        const Text(
                          '\u{1F37D}\u{FE0F}',
                          style: TextStyle(fontSize: 62),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        widget.recipe.completionMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(height: 1.3),
                      ),
                      const SizedBox(height: 14),
                      // Animated stars
                      _AnimatedStars(controller: _starAnim),
                      const SizedBox(height: 10),
                      // Earned micro-rewards
                      if (widget.earnedRewards.isNotEmpty) ...[
                        Text(
                          'Badges Earned',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: PWColors.navy.withValues(alpha: 0.5),
                              ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: widget.earnedRewards
                              .map(
                                (r) =>
                                    _BadgeChip(emoji: r.emoji, title: r.title),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Chef badge
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _badgeAnim,
                          curve: Curves.elasticOut,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                PWColors.mint.withValues(alpha: 0.2),
                                PWColors.mint.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: PWColors.mint.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '\u{1F9D1}\u{200D}\u{1F373}',
                                style: TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  children: [
                                    Text(
                                      'Badge Earned!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: PWColors.mint,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      widget.recipe.badgeTitle ??
                                          '${_countryLabel(widget.recipe.country)} Chef Star',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: PWColors.yellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '\u{2B50} +${widget.recipe.rewardCultureStars} Culture Star',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: PWColors.navy.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: (widget.recipe.completionAsset != null)
                                  ? Image.asset(
                                      widget.recipe.completionAsset!,
                                      width: 74,
                                      height: 74,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 74,
                                                height: 74,
                                                color: PWColors.yellow
                                                    .withValues(alpha: 0.2),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  widget.recipe.emoji,
                                                  style: const TextStyle(
                                                    fontSize: 30,
                                                  ),
                                                ),
                                              ),
                                    )
                                  : Container(
                                      width: 74,
                                      height: 74,
                                      color: PWColors.yellow.withValues(
                                        alpha: 0.2,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        widget.recipe.emoji,
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '🍽️ My Recipe Book',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: PWColors.navy,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.recipe.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '⭐ Stars: ★★★\n📅 Cooked Today',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.3,
                                      fontWeight: FontWeight.w700,
                                      color: PWColors.navy.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.recipe.completionFact != null) ...[
                        const SizedBox(height: 10),
                        CulturePanel(fact: widget.recipe.completionFact!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onReplay,
                        icon: const Icon(Icons.replay_rounded, size: 20),
                        label: const Text('Replay'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: widget.onDone,
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text('Done'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 54),
                          backgroundColor: PWColors.mint,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
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
// Shared small widgets
// ---------------------------------------------------------------------------

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.emoji, required this.title});

  final String emoji;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: PWColors.yellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PWColors.yellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _AnimatedStars extends StatelessWidget {
  const _AnimatedStars({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final delay = i * 0.25;
          final curve = CurvedAnimation(
            parent: controller,
            curve: Interval(
              delay.clamp(0.0, 0.5),
              (delay + 0.5).clamp(0.0, 1.0),
              curve: Curves.elasticOut,
            ),
          );
          return ScaleTransition(
            scale: curve,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '\u{2B50}',
                style: TextStyle(fontSize: i == 1 ? 40 : 32),
              ),
            ),
          );
        }),
      ),
    );
  }
}

Color _difficultyColor(int difficulty) {
  return switch (difficulty) {
    1 => PWColors.mint,
    2 => PWColors.yellow,
    _ => PWColors.coral,
  };
}

String _countryLabel(String countryId) {
  return countryId
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

typedef _ProgressCallback =
    void Function(double delta, Set<RecipeActionType> actions);
