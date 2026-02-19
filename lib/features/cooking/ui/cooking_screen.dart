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
                            const SizedBox(height: 6),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: AnimatedBuilder(
                                    animation: _controller.state,
                                    builder: (context, _) {
                                      return _StepTracker(
                                        currentStep:
                                            _controller.state.currentStep,
                                        style: baseTextStyle,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _exit,
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: <Color>[
                                          Color(0xFFFF9E7D),
                                          Color(0xFFFF7B89),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Exit',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 80),
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
    return AnimatedBuilder(
      animation: controller.state,
      builder: (context, _) {
        final isServeStep =
            controller.state.currentStep == CookingStep.serve;
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
                  if (isServeStep) ...<Widget>[
                    ServeWidget(
                      step: controller.state.currentStep,
                      progress: controller.state.progress,
                      servedCount: controller.state.servedCount,
                      requiredServes: recipe.requiredServeScoops,
                      onServe: controller.onServeDropped,
                    ),
                    const SizedBox(height: 10),
                  ],
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
    return AnimatedBuilder(
      animation: controller.state,
      builder: (context, _) {
        final step = controller.state.currentStep;
        final isServeStep = step == CookingStep.serve;

        return Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: _PotAndSpiceArea(
                controller: controller,
                recipe: recipe,
                onSpicePanStart: onSpicePanStart,
                onSpicePanUpdate: onSpicePanUpdate,
                onSpicePanEnd: onSpicePanEnd,
              ),
            ),
            const SizedBox(height: 6),
            // Only show ServeWidget when it's the serve step.
            if (isServeStep) ...<Widget>[
              ServeWidget(
                step: step,
                progress: controller.state.progress,
                servedCount: controller.state.servedCount,
                requiredServes: recipe.requiredServeScoops,
                onServe: controller.onServeDropped,
              ),
              const SizedBox(height: 6),
            ],
            Expanded(
              flex: isServeStep ? 3 : 5,
              child: _IngredientBoard(controller: controller),
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
        final isSpiceStep = controller.state.currentStep == CookingStep.spice;
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
            // Only take space when the spice step is active.
            if (isSpiceStep) ...<Widget>[
              const SizedBox(height: 6),
              _SpicePad(
                isVisible: true,
                progress: controller.state.progress,
                onPanStart: onSpicePanStart,
                onPanUpdate: onSpicePanUpdate,
                onPanEnd: onSpicePanEnd,
              ),
            ],
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
        final step = controller.state.currentStep;
        final canAdd = step == CookingStep.addIngredients;
        final ingredients = controller.recipe.ingredients;
        final addedCount = controller.state.addedIngredientIds.length;
        final totalCount = ingredients.length;

        return RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFFFF3C4), Color(0xFFFFE8A3)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: canAdd
                    ? const Color(0xFFFFD166)
                    : Colors.white,
                width: canAdd ? 2.5 : 2,
              ),
              boxShadow: <BoxShadow>[
                const BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 12,
                  offset: Offset(0, 8),
                ),
                if (canAdd)
                  const BoxShadow(
                    color: Color(0x33FFD166),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      canAdd ? 'Tap to add!' : 'Ingredients',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: addedCount >= totalCount
                            ? const Color(0xFF74C69D)
                            : const Color(0xFFFFB703),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$addedCount/$totalCount',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ingredients
                          .map((ingredient) {
                            final isAdded = controller.state.addedIngredientIds
                                .contains(ingredient.id);
                            return IgnorePointer(
                              ignoring: !canAdd || isAdded,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isAdded ? 0.4 : (canAdd ? 1 : 0.6),
                                child: Stack(
                                  children: <Widget>[
                                    IngredientWidget(
                                      ingredient: ingredient,
                                      onTapToss: () => controller
                                          .onIngredientDropped(ingredient),
                                    ),
                                    if (isAdded)
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF74C69D),
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
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
      duration: const Duration(milliseconds: 200),
      child: AnimatedSlide(
        offset: isVisible ? Offset.zero : const Offset(0, 0.3),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: RepaintBoundary(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: onPanStart,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color.lerp(
                        const Color(0xFFD6F0FF),
                        const Color(0xFFFFD166),
                        progress.clamp(0, 1) * 0.3,
                      )!,
                      Color.lerp(
                        const Color(0xFFC0EAFF),
                        const Color(0xFFFFB347),
                        progress.clamp(0, 1) * 0.3,
                      )!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: <BoxShadow>[
                    const BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                    if (progress > 0.5)
                      BoxShadow(
                        color: const Color(0x44FFD166).withValues(
                          alpha: (progress - 0.5) * 0.8,
                        ),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    const Text(
                      '\u{1F9C2}', // 🧂
                      style: TextStyle(fontSize: 26),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Shake to add spice!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D3557),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0, 1),
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.5),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF8C42),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
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

  static const _stepIcons = <CookingStep, IconData>{
    CookingStep.addIngredients: Icons.egg_alt_rounded,
    CookingStep.stir: Icons.refresh_rounded,
    CookingStep.spice: Icons.local_fire_department_rounded,
    CookingStep.serve: Icons.restaurant_rounded,
    CookingStep.complete: Icons.star_rounded,
  };

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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < steps.length; i++) ...<Widget>[
              if (i > 0)
                Container(
                  width: 16,
                  height: 2,
                  color: steps[i].index <= currentStep.index
                      ? const Color(0xFF74C69D)
                      : const Color(0xFFD1D5DB),
                ),
              _StepDot(
                step: steps[i],
                icon: _stepIcons[steps[i]]!,
                isActive: steps[i] == currentStep,
                isDone: steps[i].index < currentStep.index,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.icon,
    required this.isActive,
    required this.isDone,
  });

  final CookingStep step;
  final IconData icon;
  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final fill = isDone
        ? const Color(0xFF74C69D)
        : (isActive ? const Color(0xFFFFD166) : Colors.white);
    final iconColor = (isDone || isActive)
        ? Colors.white
        : const Color(0xFF9CA3AF);

    return Tooltip(
      message: step.title,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: isActive ? 42 : 34,
        height: isActive ? 42 : 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(
            color: isActive ? const Color(0xFFFFB703) : Colors.white,
            width: isActive ? 3 : 2,
          ),
          boxShadow: isActive
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x44FFD166),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          isDone ? Icons.check_rounded : icon,
          size: isActive ? 22 : 17,
          color: iconColor,
        ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.15),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.7, end: 1),
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0, 1),
              child: Transform.scale(scale: value, child: child),
            );
          },
          child: RepaintBoundary(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFFFFFBE6),
                    Color(0xFFFFF3C4),
                    Color(0xFFFFE9A8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFFFD166),
                  width: 3,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x44FFB703),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Color(0x22000000),
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
                      // Celebration emoji row
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, t, child) {
                          return Transform.scale(scale: 0.5 + t * 0.5, child: child);
                        },
                        child: const Text(
                          '\u{1F389}',
                          style: TextStyle(fontSize: 48),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Dish Complete!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1D3557),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF355070),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Animated stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(3, (i) {
                          final earned = i < stars;
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: earned ? 1 : 0.3),
                            duration: Duration(milliseconds: 400 + i * 200),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.5 + value * 0.5,
                                child: Opacity(
                                  opacity: value.clamp(0, 1),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                earned ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 48,
                                color: earned
                                    ? const Color(0xFFFFB703)
                                    : const Color(0xFFD1D5DB),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      // Badge
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.7, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFD166),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                height: 56,
                                width: 56,
                                child: Image.asset(
                                  recipe.badge.iconAsset,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.emoji_events,
                                        size: 44,
                                        color: Color(0xFFFFB703),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text(
                                      'Badge Unlocked!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFF8C42),
                                      ),
                                    ),
                                    Text(
                                      recipe.badge.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF264653),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (score != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _MetricChip(
                              label: 'Accuracy',
                              value: score.accuracy,
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF74C69D),
                            ),
                            const SizedBox(width: 8),
                            _MetricChip(
                              label: 'Speed',
                              value: score.speed,
                              icon: Icons.bolt_rounded,
                              color: const Color(0xFFFFB703),
                            ),
                            const SizedBox(width: 8),
                            _MetricChip(
                              label: 'Smooth',
                              value: score.smoothness,
                              icon: Icons.waves_rounded,
                              color: const Color(0xFF8ECAE6),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
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
  const _MetricChip({
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  final String label;
  final int value;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? const Color(0xFF1D3557);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 4),
          ],
          Text(
            '$label $value%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
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
    // --- Tiled wall (subtle grid) ---
    final tilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0x0FFFFFFF);
    const tileSize = 48.0;
    final wallBottom = size.height * 0.72;
    for (double y = 0; y < wallBottom; y += tileSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), tilePaint);
    }
    for (double x = 0; x < size.width; x += tileSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, wallBottom), tilePaint);
    }

    // --- Window (arched, top-center) ---
    final windowCenter = Offset(size.width * 0.5, size.height * 0.08);
    final windowRect = Rect.fromCenter(
      center: windowCenter,
      width: size.width * 0.28,
      height: size.height * 0.18,
    );
    final windowPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x40FFFFFF), Color(0x18D6F0FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(windowRect);
    final windowPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        windowRect,
        topLeft: const Radius.circular(60),
        topRight: const Radius.circular(60),
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      ));
    canvas.drawPath(windowPath, windowPaint);
    final windowFrame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x33FFFFFF);
    canvas.drawPath(windowPath, windowFrame);
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top + 10),
      Offset(windowRect.center.dx, windowRect.bottom),
      windowFrame,
    );
    canvas.drawLine(
      Offset(windowRect.left, windowRect.center.dy),
      Offset(windowRect.right, windowRect.center.dy),
      windowFrame,
    );

    // --- Shelf (left side with jars) ---
    final shelfY = size.height * 0.35;
    final shelfPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x44C4A882), Color(0x339C7E5A)],
      ).createShader(Rect.fromLTWH(0, shelfY, size.width * 0.32, 8));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.04, shelfY, size.width * 0.28, 6),
        const Radius.circular(3),
      ),
      shelfPaint,
    );
    final jarPaint = Paint()..color = const Color(0x30FFFFFF);
    final jarX = size.width * 0.08;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(jarX, shelfY - 26, 18, 26),
        const Radius.circular(4),
      ),
      jarPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(jarX + 24, shelfY - 20, 14, 20),
        const Radius.circular(3),
      ),
      jarPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(jarX + 44, shelfY - 30, 16, 30),
        const Radius.circular(4),
      ),
      jarPaint,
    );

    // --- Shelf (right side) ---
    final shelfY2 = size.height * 0.28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, shelfY2, size.width * 0.28, 6),
        const Radius.circular(3),
      ),
      shelfPaint,
    );
    final jar2X = size.width * 0.72;
    canvas.drawCircle(Offset(jar2X + 8, shelfY2 - 12), 10, jarPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(jar2X + 26, shelfY2 - 22, 16, 22),
        const Radius.circular(4),
      ),
      jarPaint,
    );

    // --- Soft clouds ---
    final cloudPaint = Paint()..color = const Color(0x18FFFFFF);
    const clouds = <Offset>[
      Offset(0.15, 0.52),
      Offset(0.78, 0.48),
      Offset(0.45, 0.58),
    ];
    for (final cloud in clouds) {
      final center = Offset(size.width * cloud.dx, size.height * cloud.dy);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 120, height: 34),
          const Radius.circular(20),
        ),
        cloudPaint,
      );
      canvas.drawCircle(center.translate(-28, -6), 17, cloudPaint);
      canvas.drawCircle(center.translate(16, -10), 20, cloudPaint);
    }

    // --- Wooden counter (richer gradient + edge highlight) ---
    final counterTop = Rect.fromLTWH(
      0,
      size.height * 0.72,
      size.width,
      size.height * 0.29,
    );
    final edgePaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFE8D4B0), Color(0xFFD4B896)],
      ).createShader(Rect.fromLTWH(0, counterTop.top, size.width, 6));
    canvas.drawRect(Rect.fromLTWH(0, counterTop.top, size.width, 6), edgePaint);
    final counterPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFFFEED2), Color(0xFFE8D0A8), Color(0xFFD4B896)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(counterTop);
    canvas.drawRect(
      Rect.fromLTWH(0, counterTop.top + 6, size.width, counterTop.height - 6),
      counterPaint,
    );
    final stripePaint = Paint()..color = const Color(0x12A66E38);
    const stripeGap = 34.0;
    for (
      double x = -size.height;
      x < size.width + size.height;
      x += stripeGap
    ) {
      final path = Path()
        ..moveTo(x, counterTop.top + 6)
        ..lineTo(x + 30, counterTop.top + 6)
        ..lineTo(x + 64, counterTop.bottom)
        ..lineTo(x + 34, counterTop.bottom)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
    final shadowPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0x18000000), Color(0x00000000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, counterTop.top + 6, size.width, 20));
    canvas.drawRect(
      Rect.fromLTWH(0, counterTop.top + 6, size.width, 20),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StorybookKitchenPainter oldDelegate) => false;
}
