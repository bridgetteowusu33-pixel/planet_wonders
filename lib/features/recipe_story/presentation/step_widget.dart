import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../domain/recipe.dart';

class RecipeStepWidget extends StatefulWidget {
  const RecipeStepWidget({
    super.key,
    required this.step,
    required this.progress,
    required this.interactionCount,
    required this.onTapAction,
    required this.onDragAccepted,
    required this.onProgressDelta,
  });

  final RecipeStoryStep step;
  final double progress;
  final int interactionCount;
  final VoidCallback onTapAction;
  final VoidCallback onDragAccepted;
  final ValueChanged<double> onProgressDelta;

  @override
  State<RecipeStepWidget> createState() => _RecipeStepWidgetState();
}

class _RecipeStepWidgetState extends State<RecipeStepWidget> {
  static const int _holdTickMs = 50;

  Timer? _holdTimer;
  bool _holding = false;
  bool _tapPulse = false;

  @override
  void didUpdateWidget(covariant RecipeStepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.actionKey != widget.step.actionKey) {
      _stopHolding();
      _tapPulse = false;
    }
  }

  @override
  void dispose() {
    _stopHolding();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.step.action;
    final showCountProgress =
        (action == RecipeActionType.tap || action == RecipeActionType.drag) &&
        widget.step.safeRequiredCount > 1;

    return Column(
      children: [
        Expanded(
          child: switch (action) {
            RecipeActionType.tap => _buildTapAction(context),
            RecipeActionType.drag => _buildDragAction(context),
            RecipeActionType.stir => _buildStirAction(context),
            RecipeActionType.hold => _buildHoldAction(context),
            RecipeActionType.shake => _buildShakeAction(context),
          },
        ),
        if (showCountProgress ||
            action == RecipeActionType.stir ||
            action == RecipeActionType.hold ||
            action == RecipeActionType.shake)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: _ProgressBar(
              progress: widget.progress,
              label: showCountProgress
                  ? '${widget.interactionCount}/${widget.step.safeRequiredCount}'
                  : '${(widget.progress * 100).round()}%',
            ),
          ),
      ],
    );
  }

  Widget _buildTapAction(BuildContext context) {
    final emoji = switch (widget.step.actionKey) {
      'tap_bowl' => '🍚',
      'tap_chop' => '🍅',
      'tap_spice_shaker' => '🧂',
      _ => '👆',
    };

    final label = switch (widget.step.actionKey) {
      'tap_bowl' => 'Tap Bowl',
      'tap_chop' => 'Tap to Chop',
      'tap_spice_shaker' => 'Tap Spice Shaker',
      _ => 'Tap',
    };

    final successHint = widget.progress >= 1 ? '✨ Nice!' : _tapSubLabel();

    return Center(
      child: GestureDetector(
        onTap: () {
          _runTapPulse();
          widget.onTapAction();
        },
        child: AnimatedScale(
          scale: _tapPulse ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 260,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: PWColors.coral.withValues(alpha: 0.65),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: PWColors.navy.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      successHint,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PWColors.navy.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 20,
                  top: 20,
                  child: AnimatedOpacity(
                    opacity: _tapPulse ? 1 : 0,
                    duration: const Duration(milliseconds: 120),
                    child: const Text('💧', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragAction(BuildContext context) {
    final sourceLabel = switch (widget.step.actionKey) {
      'drag_oil_to_pot' => 'Oil Bottle',
      'drag_tomato_mix' => 'Tomato Mix',
      'drag_rice_to_pot' => 'Rice Bowl',
      _ => 'Ingredient',
    };

    final sourceEmoji = switch (widget.step.actionKey) {
      'drag_oil_to_pot' => '🫙',
      'drag_tomato_mix' => '🍅',
      'drag_rice_to_pot' => '🍚',
      _ => '🥣',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Draggable<String>(
                data: widget.step.actionKey,
                feedback: _DraggableChip(
                  opacity: 0.92,
                  emoji: sourceEmoji,
                  label: sourceLabel,
                ),
                childWhenDragging: _DraggableChip(
                  opacity: 0.35,
                  emoji: sourceEmoji,
                  label: sourceLabel,
                ),
                child: _DraggableChip(
                  opacity: 1,
                  emoji: sourceEmoji,
                  label: sourceLabel,
                ),
              ),
            ),
          ),
          Expanded(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (details) =>
                  details.data == widget.step.actionKey,
              onAcceptWithDetails: (details) => widget.onDragAccepted(),
              builder: (context, candidateData, rejectedData) {
                final active = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: active
                        ? PWColors.mint.withValues(alpha: 0.3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: active
                          ? PWColors.mint
                          : PWColors.navy.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Drop in Pot',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStirAction(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final delta = details.delta.distance / 230;
        widget.onProgressDelta(delta.clamp(0.0, 0.08));
      },
      child: Center(
        child: SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: widget.progress,
                  strokeWidth: 12,
                  backgroundColor: PWColors.blue.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(PWColors.blue),
                ),
              ),
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PWColors.blue.withValues(alpha: 0.16),
                      PWColors.blue.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: PWColors.blue.withValues(alpha: 0.45),
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Stir Here',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoldAction(BuildContext context) {
    final dotsFilled = (widget.progress * 3).floor().clamp(0, 3);
    final dots = List<String>.generate(
      3,
      (index) => index < dotsFilled ? '●' : '○',
    ).join(' ');

    return GestureDetector(
      onTapDown: (_) => _startHolding(),
      onTapUp: (_) => _stopHolding(),
      onTapCancel: _stopHolding,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 260,
          height: 180,
          decoration: BoxDecoration(
            color: _holding
                ? PWColors.yellow.withValues(alpha: 0.34)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _holding
                  ? PWColors.yellow
                  : PWColors.navy.withValues(alpha: 0.28),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: PWColors.navy.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hold Lid to Cook',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dots,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
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

  Widget _buildShakeAction(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final delta = math.min(details.delta.dx.abs() / 260, 0.08);
        widget.onProgressDelta(delta);
      },
      child: Center(
        child: Container(
          width: 250,
          height: 170,
          decoration: BoxDecoration(
            color: PWColors.coral.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: PWColors.coral.withValues(alpha: 0.5),
              width: 3,
            ),
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Shake Left and Right',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _tapSubLabel() {
    return switch (widget.step.actionKey) {
      'tap_bowl' => 'Splash splash!',
      'tap_chop' => 'Tap to chop into pieces',
      'tap_spice_shaker' => 'Sprinkle sprinkle!',
      _ => 'Tap to continue',
    };
  }

  void _runTapPulse() {
    setState(() => _tapPulse = true);
    Future<void>.delayed(const Duration(milliseconds: 130), () {
      if (mounted) {
        setState(() => _tapPulse = false);
      }
    });
  }

  void _startHolding() {
    if (_holdTimer != null) return;
    setState(() => _holding = true);

    final holdDurationMs = widget.step.safeHoldDurationMs;
    final tickDelta = (_holdTickMs / holdDurationMs).clamp(0.01, 0.2);

    _holdTimer = Timer.periodic(const Duration(milliseconds: _holdTickMs), (_) {
      widget.onProgressDelta(tickDelta);
    });
  }

  void _stopHolding() {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (_holding) {
      setState(() => _holding = false);
    }
  }
}

class _DraggableChip extends StatelessWidget {
  const _DraggableChip({
    required this.opacity,
    required this.emoji,
    required this.label,
  });

  final double opacity;
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: PWColors.coral.withValues(alpha: 0.65),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 30),
                textScaler: const TextScaler.linear(1.0),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1.0),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.label});

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PWColors.navy.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress $label',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: PWColors.navy.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(PWColors.mint),
            ),
          ),
        ],
      ),
    );
  }
}
