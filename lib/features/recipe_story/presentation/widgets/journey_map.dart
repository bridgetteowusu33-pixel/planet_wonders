import 'package:flutter/material.dart';

import '../../../../core/theme/pw_theme.dart';
import '../../domain/recipe.dart';
import '../../engine/recipe_engine.dart';

class JourneyMap extends StatelessWidget {
  const JourneyMap({super.key, required this.steps, required this.currentStep});

  final List<RecipeStoryStep> steps;
  final int currentStep;

  static const _engine = RecipeEngine();

  @override
  Widget build(BuildContext context) {
    final isCompleted = currentStep >= steps.length;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PWColors.navy.withValues(alpha: 0.12)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Story Journey',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PWColors.navy.withValues(alpha: 0.7),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: steps.length + 1,
                itemBuilder: (context, index) {
                  if (index == steps.length) {
                    return _JourneyNode(
                      emoji: '🎉',
                      label: 'Done',
                      isDone: isCompleted,
                      isCurrent: false,
                    );
                  }

                  final step = steps[index];
                  final done = index < currentStep;
                  final active = index == currentStep;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _JourneyNode(
                        emoji: _engine.journeyIconForStep(step),
                        label: _stepLabel(step),
                        isDone: done,
                        isCurrent: active,
                      ),
                      if (index != steps.length - 1)
                        _JourneyConnector(done: done),
                      if (index == steps.length - 1)
                        _JourneyConnector(done: isCompleted),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepLabel(RecipeStoryStep step) {
    return switch (step.actionKey) {
      'tap_bowl' => 'Wash',
      'tap_chop' => 'Chop',
      'drag_tomato_mix' => 'Tomato',
      'drag_oil_to_pot' => 'Oil',
      'drag_rice_to_pot' => 'Rice',
      'stir_circle' || 'stir' => 'Stir',
      'hold_to_cook' || 'hold' || 'hold_cook' => 'Cook',
      _ => 'Step',
    };
  }
}

class _JourneyNode extends StatefulWidget {
  const _JourneyNode({
    required this.emoji,
    required this.label,
    required this.isDone,
    required this.isCurrent,
  });

  final String emoji;
  final String label;
  final bool isDone;
  final bool isCurrent;

  @override
  State<_JourneyNode> createState() => _JourneyNodeState();
}

class _JourneyNodeState extends State<_JourneyNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isCurrent) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _JourneyNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !oldWidget.isCurrent) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isCurrent && oldWidget.isCurrent) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDone
        ? PWColors.mint
        : widget.isCurrent
        ? PWColors.coral
        : PWColors.navy.withValues(alpha: 0.25);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final scale = widget.isCurrent ? 1 + _pulse.value * 0.08 : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: SizedBox(
        width: 52,
        child: Column(
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDone
                    ? baseColor.withValues(alpha: 0.24)
                    : Colors.white,
                border: Border.all(
                  color: baseColor,
                  width: widget.isCurrent ? 3 : 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(widget.emoji, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: baseColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyConnector extends StatelessWidget {
  const _JourneyConnector({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 3,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: done ? PWColors.mint : PWColors.navy.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
