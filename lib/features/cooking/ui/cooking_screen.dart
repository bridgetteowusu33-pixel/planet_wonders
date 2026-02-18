import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../animations/confetti_anim.dart';
import '../data/ghana_recipes.dart';
import '../engine/cooking_controller.dart';
import '../engine/cooking_engine.dart';
import '../engine/cooking_step.dart';
import '../models/recipe.dart';
import 'chef_widget.dart';
import 'ingredient_widget.dart';
import 'pot_widget.dart';
import 'serve_widget.dart';

class CookingScreen extends StatefulWidget {
  const CookingScreen({
    super.key,
    this.recipe = ghanaJollofRecipe,
    this.onExit,
    this.onCompleted,
  });

  final Recipe recipe;
  final VoidCallback? onExit;
  final Future<void> Function(Recipe recipe, CookingScore score)? onCompleted;

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  late final CookingController _controller;
  Offset? _lastSpicePoint;
  DateTime? _lastSpiceTime;

  @override
  void initState() {
    super.initState();
    _controller = CookingController(
      recipe: widget.recipe,
      onCompleted: widget.onCompleted,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.preloadAssets(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _exit() {
    final onExit = widget.onExit;
    if (onExit != null) {
      onExit();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final baseTextStyle = Theme.of(context).textTheme;

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
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 860;
              final horizontalPadding = isTablet ? 32.0 : 16.0;
              final contentMaxWidth = isTablet ? 1200.0 : 700.0;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: const _StorybookKitchenPainter(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(height: 8),
                            _Header(recipeName: widget.recipe.name),
                            const SizedBox(height: 10),
                            AnimatedBuilder(
                              animation: _controller.state,
                              builder: (context, _) {
                                return _FactCard(
                                  text: _controller.state.currentFact.text,
                                  country:
                                      _controller.state.currentFact.country,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: isTablet
                                  ? _TabletGameLayout(
                                      controller: _controller,
                                      recipe: widget.recipe,
                                      onSpicePanUpdate: _onSpicePanUpdate,
                                      onSpicePanStart: _onSpicePanStart,
                                      onSpicePanEnd: _onSpicePanEnd,
                                    )
                                  : _PhoneGameLayout(
                                      controller: _controller,
                                      recipe: widget.recipe,
                                      onSpicePanUpdate: _onSpicePanUpdate,
                                      onSpicePanStart: _onSpicePanStart,
                                      onSpicePanEnd: _onSpicePanEnd,
                                    ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedBuilder(
                              animation: _controller.state,
                              builder: (context, _) {
                                return _StepTracker(
                                  currentStep: _controller.state.currentStep,
                                  style: baseTextStyle,
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            _StickerActionButton(
                              title: 'Exit Kitchen',
                              onTap: _exit,
                              colors: const <Color>[
                                Color(0xFFFF9E7D),
                                Color(0xFFFF7B89),
                              ],
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                      Positioned(
                        left: horizontalPadding,
                        right: horizontalPadding,
                        bottom: 16,
                        child: IgnorePointer(
                          ignoring: true,
                          child: ValueListenableBuilder<String>(
                            valueListenable: _controller.chefMessage,
                            builder: (context, message, _) {
                              return ValueListenableBuilder<ChefMood>(
                                valueListenable: _controller.chefMood,
                                builder: (context, mood, ignoredChild) {
                                  return Align(
                                    alignment: Alignment.bottomLeft,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: isTablet ? 460 : 320,
                                      ),
                                      child: ChefWidget(
                                        message: message,
                                        mood: mood,
                                        chefAsset: widget.recipe.chefAsset,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: _controller.confettiTick,
                        builder: (context, tick, _) {
                          return Positioned.fill(
                            child: ConfettiAnim(playTick: tick),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _controller.state,
                        builder: (context, _) {
                          if (!_controller.state.isComplete) {
                            return const SizedBox.shrink();
                          }
                          return Positioned.fill(
                            child: _CompletionOverlay(
                              recipe: widget.recipe,
                              scoreListenable: _controller.score,
                              onExit: _exit,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onSpicePanStart(DragStartDetails details) {
    _lastSpicePoint = details.localPosition;
    _lastSpiceTime = DateTime.now();
  }

  void _onSpicePanUpdate(DragUpdateDetails details) {
    final previous = _lastSpicePoint;
    final previousTime = _lastSpiceTime;
    final now = DateTime.now();

    if (previous == null || previousTime == null) {
      _lastSpicePoint = details.localPosition;
      _lastSpiceTime = now;
      return;
    }

    final distance = (details.localPosition - previous).distance;
    final dtMs = math.max(1, now.difference(previousTime).inMilliseconds);
    final intensity = distance / dtMs * 40;

    _controller.onSpiceMotion(intensity);
    _lastSpicePoint = details.localPosition;
    _lastSpiceTime = now;
  }

  void _onSpicePanEnd(DragEndDetails details) {
    _lastSpicePoint = null;
    _lastSpiceTime = null;
  }
}

class _TabletGameLayout extends StatelessWidget {
  const _TabletGameLayout({
    required this.controller,
    required this.recipe,
    required this.onSpicePanStart,
    required this.onSpicePanUpdate,
    required this.onSpicePanEnd,
  });

  final CookingController controller;
  final Recipe recipe;
  final GestureDragStartCallback onSpicePanStart;
  final GestureDragUpdateCallback onSpicePanUpdate;
  final GestureDragEndCallback onSpicePanEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: _PotAndSpiceArea(
            controller: controller,
            recipe: recipe,
            onSpicePanStart: onSpicePanStart,
            onSpicePanUpdate: onSpicePanUpdate,
            onSpicePanEnd: onSpicePanEnd,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: Column(
            children: <Widget>[
              AnimatedBuilder(
                animation: controller.state,
                builder: (context, _) {
                  return ServeWidget(
                    step: controller.state.currentStep,
                    progress: controller.state.currentStep == CookingStep.serve
                        ? controller.state.progress
                        : 0,
                    servedCount: controller.state.servedCount,
                    requiredServes: recipe.requiredServeScoops,
                    onServe: controller.onServeDropped,
                  );
                },
              ),
              const SizedBox(height: 10),
              Expanded(child: _IngredientBoard(controller: controller)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneGameLayout extends StatelessWidget {
  const _PhoneGameLayout({
    required this.controller,
    required this.recipe,
    required this.onSpicePanStart,
    required this.onSpicePanUpdate,
    required this.onSpicePanEnd,
  });

  final CookingController controller;
  final Recipe recipe;
  final GestureDragStartCallback onSpicePanStart;
  final GestureDragUpdateCallback onSpicePanUpdate;
  final GestureDragEndCallback onSpicePanEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;
        final gap = compact ? 6.0 : 10.0;

        return Column(
          children: <Widget>[
            Expanded(
              flex: compact ? 5 : 4,
              child: _PotAndSpiceArea(
                controller: controller,
                recipe: recipe,
                onSpicePanStart: onSpicePanStart,
                onSpicePanUpdate: onSpicePanUpdate,
                onSpicePanEnd: onSpicePanEnd,
              ),
            ),
            SizedBox(height: gap),
            Expanded(
              flex: compact ? 5 : 4,
              child: Column(
                children: <Widget>[
                  AnimatedBuilder(
                    animation: controller.state,
                    builder: (context, _) {
                      return ServeWidget(
                        step: controller.state.currentStep,
                        progress:
                            controller.state.currentStep == CookingStep.serve
                            ? controller.state.progress
                            : 0,
                        servedCount: controller.state.servedCount,
                        requiredServes: recipe.requiredServeScoops,
                        onServe: controller.onServeDropped,
                      );
                    },
                  ),
                  SizedBox(height: gap),
                  Expanded(child: _IngredientBoard(controller: controller)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PotAndSpiceArea extends StatelessWidget {
  const _PotAndSpiceArea({
    required this.controller,
    required this.recipe,
    required this.onSpicePanStart,
    required this.onSpicePanUpdate,
    required this.onSpicePanEnd,
  });

  final CookingController controller;
  final Recipe recipe;
  final GestureDragStartCallback onSpicePanStart;
  final GestureDragUpdateCallback onSpicePanUpdate;
  final GestureDragEndCallback onSpicePanEnd;

  @override
  Widget build(BuildContext context) {
    final list = Listenable.merge(<Listenable>[
      controller.state,
      controller.splashTick,
      controller.successGlow,
      controller.lastDroppedIngredientAsset,
    ]);

    return AnimatedBuilder(
      animation: list,
      builder: (context, _) {
        return Column(
          children: <Widget>[
            Expanded(
              child: PotWidget(
                potAsset: recipe.potAsset,
                step: controller.state.currentStep,
                progress: controller.state.progress,
                splashTick: controller.splashTick.value,
                successGlow: controller.successGlow.value,
                dropAssetPath: controller.lastDroppedIngredientAsset.value,
                onIngredientAccepted: controller.onIngredientDropped,
                onStirStart: controller.onStirStart,
                onStirUpdate: controller.onStirUpdate,
                onStirEnd: controller.onStirEnd,
              ),
            ),
            const SizedBox(height: 10),
            _SpicePad(
              isVisible: controller.state.currentStep == CookingStep.spice,
              progress: controller.state.currentStep == CookingStep.spice
                  ? controller.state.progress
                  : 0,
              onPanStart: onSpicePanStart,
              onPanUpdate: onSpicePanUpdate,
              onPanEnd: onSpicePanEnd,
            ),
          ],
        );
      },
    );
  }
}

class _IngredientBoard extends StatelessWidget {
  const _IngredientBoard({required this.controller});

  final CookingController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.state,
      builder: (context, _) {
        final canAdd =
            controller.state.currentStep == CookingStep.addIngredients;
        final ingredients = controller.recipe.ingredients;

        return RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFFFF3C4), Color(0xFFFFE8A3)],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 12,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ingredients
                          .map((ingredient) {
                            final isAdded = controller.state.addedIngredientIds
                                .contains(ingredient.id);
                            return IgnorePointer(
                              ignoring: !canAdd || isAdded,
                              child: Opacity(
                                opacity: (!canAdd || isAdded) ? 0.48 : 1,
                                child: IngredientWidget(
                                  ingredient: ingredient,
                                  onTapToss: () => controller
                                      .onIngredientDropped(ingredient),
                                ),
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpicePad extends StatelessWidget {
  const _SpicePad({
    required this.isVisible,
    required this.progress,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final bool isVisible;
  final double progress;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      child: IgnorePointer(
        ignoring: !isVisible,
        child: RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: onPanStart,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            child: Container(
              height: 92,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFD6F0FF), Color(0xFFC0EAFF)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.travel_explore_rounded,
                    color: Color(0xFF1D3557),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Shake here to add spice',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D3557),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Text(
                      '${(progress * 100).round()}%',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D3557),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.recipeName});

  final String recipeName;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFFFD166), Color(0xFFFFB86B)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 12,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.restaurant_menu_rounded,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cooking Fun: $recipeName',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.text, required this.country});

  final String text;
  final String country;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFFFA600),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$country Fact: $text',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF264653),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTracker extends StatelessWidget {
  const _StepTracker({required this.currentStep, required this.style});

  final CookingStep currentStep;
  final TextTheme style;

  @override
  Widget build(BuildContext context) {
    const steps = <CookingStep>[
      CookingStep.addIngredients,
      CookingStep.stir,
      CookingStep.spice,
      CookingStep.serve,
      CookingStep.complete,
    ];

    return RepaintBoundary(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: steps
            .map((step) {
              final isActive = step == currentStep;
              final isDone = step.index < currentStep.index;
              final fill = isDone
                  ? const Color(0xFF74C69D)
                  : (isActive
                        ? const Color(0xFFFFD166)
                        : const Color(0xFFFFFFFF));
              final textColor = (isDone || isActive)
                  ? Colors.white
                  : const Color(0xFF6B7280);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  step.title,
                  style:
                      style.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ) ??
                      TextStyle(fontWeight: FontWeight.w900, color: textColor),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _CompletionOverlay extends StatelessWidget {
  const _CompletionOverlay({
    required this.recipe,
    required this.scoreListenable,
    required this.onExit,
  });

  final Recipe recipe;
  final ValueListenable<CookingScore?> scoreListenable;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.18)),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: RepaintBoundary(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFFFF8D6), Color(0xFFFFE9A8)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 20,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: ValueListenableBuilder<CookingScore?>(
                valueListenable: scoreListenable,
                builder: (context, score, _) {
                  final stars = score?.stars ?? 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Dish Complete!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1D3557),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 90,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.dinner_dining,
                              size: 34,
                              color: Color(0xFF355070),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Fresh & Ready!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF355070),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.85, end: 1),
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: SizedBox(
                          height: 88,
                          child: Image.asset(
                            recipe.badge.iconAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.emoji_events,
                                  size: 68,
                                  color: Color(0xFFFFB703),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Badge Unlocked: ${recipe.badge.title}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF264653),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('⭐' * stars, style: const TextStyle(fontSize: 34)),
                      const SizedBox(height: 12),
                      if (score != null)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            _MetricChip(
                              label: 'Accuracy',
                              value: score.accuracy,
                            ),
                            _MetricChip(label: 'Speed', value: score.speed),
                            _MetricChip(
                              label: 'Smoothness',
                              value: score.smoothness,
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),
                      _StickerActionButton(
                        title: 'Awesome! Exit',
                        onTap: onExit,
                        colors: const <Color>[
                          Color(0xFF6BCB77),
                          Color(0xFF4CAF50),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label $value%',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1D3557),
        ),
      ),
    );
  }
}

class _StickerActionButton extends StatelessWidget {
  const _StickerActionButton({
    required this.title,
    required this.onTap,
    required this.colors,
  });

  final String title;
  final VoidCallback onTap;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 12,
                offset: Offset(0, 7),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _StorybookKitchenPainter extends CustomPainter {
  const _StorybookKitchenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = const Color(0x24FFFFFF);
    const clouds = <Offset>[
      Offset(0.15, 0.07),
      Offset(0.75, 0.1),
      Offset(0.32, 0.26),
      Offset(0.84, 0.34),
      Offset(0.2, 0.53),
      Offset(0.62, 0.62),
    ];

    for (final cloud in clouds) {
      final center = Offset(size.width * cloud.dx, size.height * cloud.dy);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 140, height: 42),
          const Radius.circular(30),
        ),
        cloudPaint,
      );
      canvas.drawCircle(center.translate(-35, -8), 21, cloudPaint);
      canvas.drawCircle(center.translate(20, -14), 26, cloudPaint);
    }

    final counterTop = Rect.fromLTWH(
      0,
      size.height * 0.79,
      size.width,
      size.height * 0.22,
    );
    final counterPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFFFEED2), Color(0xFFFFDDB6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(counterTop);
    canvas.drawRect(counterTop, counterPaint);

    final stripePaint = Paint()..color = const Color(0x15A66E38);
    const stripeGap = 34.0;
    for (
      double x = -size.height;
      x < size.width + size.height;
      x += stripeGap
    ) {
      final path = Path()
        ..moveTo(x, counterTop.top)
        ..lineTo(x + 30, counterTop.top)
        ..lineTo(x + 64, counterTop.bottom)
        ..lineTo(x + 34, counterTop.bottom)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StorybookKitchenPainter oldDelegate) => false;
}
