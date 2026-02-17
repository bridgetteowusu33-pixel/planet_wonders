import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/pw_theme.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../../achievements/ui/badge_unlock_animation.dart';
import '../data/recipe_story_repository.dart';
import '../domain/recipe.dart';
import '../providers/recipe_controller.dart';
import '../utils/story_feedback.dart';
import 'step_widget.dart';

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

        final recipe = snapshot.data!;
        return _RecipeStoryBody(
          key: ValueKey('${widget.countryId}-${widget.recipeId}'),
          countryId: widget.countryId,
          source: widget.source,
          recipe: recipe,
        );
      },
    );
  }
}

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

    ref.listen<RecipeStoryState>(recipeStoryControllerProvider, (
      previous,
      next,
    ) {
      _onStoryStateChanged(previous, next);
    });

    _schedulePrecache(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipe Story - ${widget.recipe.title}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: !state.started
                  ? _IntroView(
                      recipe: widget.recipe,
                      source: widget.source,
                      onStart: controller.startStory,
                    )
                  : state.completed
                  ? _CompletedView(
                      recipe: widget.recipe,
                      onReplay: controller.restart,
                      onDone: () => Navigator.of(context).pop(true),
                    )
                  : _StepFlowView(
                      recipe: widget.recipe,
                      state: state,
                      onTapAction: () =>
                          controller.completeTapAction(widget.recipe),
                      onDragAction: () =>
                          controller.completeDragAction(widget.recipe),
                      onProgress: (delta, actions) => controller.addProgress(
                        widget.recipe,
                        delta: delta,
                        actions: actions,
                      ),
                    ),
            ),
            const BadgeUnlockAnimationListener(),
          ],
        ),
      ),
    );
  }

  void _onStoryStateChanged(RecipeStoryState? previous, RecipeStoryState next) {
    if (previous == null) return;

    final advancedStep = next.stepIndex > previous.stepIndex;
    final justCompleted = next.completed && !previous.completed;

    if (!advancedStep && !justCompleted) {
      return;
    }

    final completedStepIndex = previous.stepIndex;
    if (completedStepIndex >= 0 &&
        completedStepIndex < widget.recipe.steps.length) {
      final cue =
          widget.recipe.steps[completedStepIndex].sfx ??
          (justCompleted ? 'complete' : 'tap');
      RecipeStoryFeedback.playCue(cue);
    }

    if (justCompleted) {
      RecipeStoryFeedback.playCue('celebrate');
      Future<void>.microtask(() {
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
    if (index < 0 || index >= widget.recipe.steps.length) {
      return null;
    }
    return widget.recipe.steps[index].asset;
  }

  Future<void> _precacheAsset(String? assetPath) async {
    if (assetPath == null || assetPath.isEmpty) return;
    if (_precachedAssets.contains(assetPath)) return;

    _precachedAssets.add(assetPath);
    try {
      // Verify the asset exists before precaching to avoid noisy runtime errors.
      await rootBundle.load(assetPath);
      if (!mounted) return;
      await precacheImage(AssetImage(assetPath), context);
    } catch (_) {
      // Optional assets can be missing in early content drops.
    }
  }
}

class _IntroView extends StatelessWidget {
  const _IntroView({
    required this.recipe,
    required this.source,
    required this.onStart,
  });

  final RecipeStory recipe;
  final String source;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final header = source == 'food'
        ? 'Let\'s cook with a story!'
        : 'Cooking story time!';

    return LayoutBuilder(
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        recipe.imageAsset,
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        cacheWidth: 900,
                        errorBuilder: (context, error, stackTrace) => Text(
                          recipe.emoji,
                          style: const TextStyle(fontSize: 70),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${recipe.emoji} ${recipe.title}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      header,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PWColors.navy.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe.intro,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    if (recipe.introFact != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: PWColors.yellow.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '💡 ${recipe.introFact!}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Cooking'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: PWColors.coral,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepFlowView extends StatelessWidget {
  const _StepFlowView({
    required this.recipe,
    required this.state,
    required this.onTapAction,
    required this.onDragAction,
    required this.onProgress,
  });

  final RecipeStory recipe;
  final RecipeStoryState state;
  final VoidCallback onTapAction;
  final VoidCallback onDragAction;
  final ValueChangedWithActions onProgress;

  @override
  Widget build(BuildContext context) {
    final step = recipe.steps[state.stepIndex];
    final stepNumber = state.stepIndex + 1;
    final hasNextStep = state.stepIndex + 1 < recipe.steps.length;
    final nextStep = hasNextStep ? recipe.steps[state.stepIndex + 1] : null;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: PWColors.yellow.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PWColors.navy.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step $stepNumber/${recipe.steps.length}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(step.story, style: Theme.of(context).textTheme.bodyLarge),
              if (step.fact != null) ...[
                const SizedBox(height: 8),
                Text(
                  '💡 ${step.fact!}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PWColors.navy.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              if (nextStep?.fact != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Up next: ${nextStep!.fact}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PWColors.navy.withValues(alpha: 0.58),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: PWColors.navy.withValues(alpha: 0.1),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                if (step.asset != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      step.asset!,
                      width: double.infinity,
                      height: 90,
                      fit: BoxFit.cover,
                      cacheWidth: 900,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Expanded(
                  child: RecipeStepWidget(
                    step: step,
                    progress: state.stepProgress,
                    interactionCount: state.interactionCount,
                    onTapAction: onTapAction,
                    onDragAccepted: onDragAction,
                    onProgressDelta: (delta) {
                      onProgress(delta, {
                        RecipeActionType.stir,
                        RecipeActionType.hold,
                        RecipeActionType.shake,
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletedView extends StatelessWidget {
  const _CompletedView({
    required this.recipe,
    required this.onReplay,
    required this.onDone,
  });

  final RecipeStory recipe;
  final VoidCallback onReplay;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                    const Text(
                      'Well done!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You made ${recipe.title}!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (recipe.completionAsset != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          recipe.completionAsset!,
                          width: 260,
                          height: 200,
                          fit: BoxFit.cover,
                          cacheWidth: 980,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text('🍽️', style: TextStyle(fontSize: 62)),
                        ),
                      ),
                    ] else ...[
                      const Text('🍽️', style: TextStyle(fontSize: 62)),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      recipe.completionMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: PWColors.mint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🧑‍🍳 Badge: ${recipe.badgeTitle ?? '${_countryLabel(recipe.country)} Chef Star'}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '⭐ +${recipe.rewardCultureStars} Culture Star',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (recipe.completionFact != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '💡 ${recipe.completionFact!}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PWColors.navy.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReplay,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Replay'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onDone,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        backgroundColor: PWColors.mint,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _countryLabel(String countryId) {
  return countryId
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

typedef ValueChangedWithActions =
    void Function(double delta, Set<RecipeActionType> actions);
