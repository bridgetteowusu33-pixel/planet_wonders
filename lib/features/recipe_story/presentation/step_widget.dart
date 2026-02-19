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

class _RecipeStepWidgetState extends State<RecipeStepWidget>
    with SingleTickerProviderStateMixin {
  static const int _holdTickMs = 50;

  Timer? _holdTimer;
  bool _holding = false;
  bool _tapPulse = false;
  late final AnimationController _idleAnim;

  @override
  void initState() {
    super.initState();
    _idleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

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
    _idleAnim.dispose();
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

  // ---------------------------------------------------------------------------
  // Tap Action — bouncy card with emoji + sparkles
  // ---------------------------------------------------------------------------

  Widget _buildTapAction(BuildContext context) {
    final emoji = switch (widget.step.actionKey) {
      'tap_bowl' => '\u{1F35A}',
      'tap_chop' => '\u{1F52A}',
      'tap_spice_shaker' => '\u{1F9C2}',
      _ => '\u{1F446}',
    };

    final label = switch (widget.step.actionKey) {
      'tap_bowl' => 'Tap Bowl',
      'tap_chop' => 'Tap to Chop',
      'tap_spice_shaker' => 'Tap Spice Shaker',
      _ => 'Tap',
    };

    final isDone = widget.progress >= 1;
    final successHint = isDone ? '\u{2728} Nice!' : _tapSubLabel();

    return Center(
      child: GestureDetector(
        onTap: () {
          _runTapPulse();
          widget.onTapAction();
        },
        child: AnimatedScale(
          scale: _tapPulse ? 0.92 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutBack,
          child: AnimatedBuilder(
            animation: _idleAnim,
            builder: (context, child) {
              if (_tapPulse) return child!;
              final bob = math.sin(_idleAnim.value * math.pi) * 3;
              return Transform.translate(
                offset: Offset(0, bob),
                child: child,
              );
            },
            child: Container(
              width: 260,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    PWColors.coral.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDone
                      ? PWColors.mint
                      : PWColors.coral.withValues(alpha: 0.65),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDone ? PWColors.mint : PWColors.coral)
                        .withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: _tapPulse ? 1.3 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.elasticOut,
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 52)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          successHint,
                          key: ValueKey(successHint),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDone
                                ? PWColors.mint
                                : PWColors.navy.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Splash particles on tap
                  if (_tapPulse)
                    ...List.generate(4, (i) {
                      final angle = (i * math.pi / 2) + math.pi / 4;
                      return Positioned(
                        left: 130 + math.cos(angle) * 60,
                        top: 90 + math.sin(angle) * 50,
                        child: const Text('\u{2728}',
                            style: TextStyle(fontSize: 16)),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Drag Action — source → pot target with arrow hint
  // ---------------------------------------------------------------------------

  Widget _buildDragAction(BuildContext context) {
    final sourceLabel = switch (widget.step.actionKey) {
      'drag_oil_to_pot' => 'Oil Bottle',
      'drag_tomato_mix' => 'Tomato Mix',
      'drag_rice_to_pot' => 'Rice Bowl',
      _ => 'Ingredient',
    };

    final sourceEmoji = switch (widget.step.actionKey) {
      'drag_oil_to_pot' => '\u{1FAD9}',
      'drag_tomato_mix' => '\u{1F345}',
      'drag_rice_to_pot' => '\u{1F35A}',
      _ => '\u{1F963}',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          // Source draggable
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _idleAnim,
                builder: (context, child) {
                  final bob = math.sin(_idleAnim.value * math.pi) * 4;
                  return Transform.translate(
                    offset: Offset(0, bob),
                    child: child,
                  );
                },
                child: Draggable<String>(
                  data: widget.step.actionKey,
                  feedback: _DraggableChip(
                    opacity: 0.92,
                    emoji: sourceEmoji,
                    label: sourceLabel,
                    isActive: true,
                  ),
                  childWhenDragging: _DraggableChip(
                    opacity: 0.3,
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
          ),
          // Arrow hint
          AnimatedBuilder(
            animation: _idleAnim,
            builder: (context, child) {
              final slide = _idleAnim.value * 6;
              return Transform.translate(
                offset: Offset(slide, 0),
                child: child,
              );
            },
            child: Icon(
              Icons.arrow_forward_rounded,
              color: PWColors.navy.withValues(alpha: 0.25),
              size: 28,
            ),
          ),
          // Drop target
          Expanded(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (details) =>
                  details.data == widget.step.actionKey,
              onAcceptWithDetails: (details) => widget.onDragAccepted(),
              builder: (context, candidateData, rejectedData) {
                final active = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: active
                        ? PWColors.mint.withValues(alpha: 0.25)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: active
                          ? PWColors.mint
                          : PWColors.navy.withValues(alpha: 0.2),
                      width: active ? 3 : 2,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: PWColors.mint.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: PWColors.navy.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          active ? '\u{1F372}' : '\u{1F373}',
                          style: TextStyle(
                              fontSize: active ? 38 : 32),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          active ? 'Drop here!' : 'Drop in Pot',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? PWColors.mint
                                : PWColors.navy.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
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

  // ---------------------------------------------------------------------------
  // Stir Action — rotating spoon + progress ring
  // ---------------------------------------------------------------------------

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
              // Progress ring
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: widget.progress,
                  strokeWidth: 14,
                  strokeCap: StrokeCap.round,
                  backgroundColor: PWColors.blue.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(
                          PWColors.blue,
                          PWColors.mint,
                          widget.progress,
                        ) ??
                        PWColors.blue,
                  ),
                ),
              ),
              // Center circle with rotating spoon
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PWColors.blue.withValues(alpha: 0.14),
                      PWColors.blue.withValues(alpha: 0.04),
                    ],
                  ),
                  border: Border.all(
                    color: PWColors.blue.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PWColors.blue.withValues(alpha: 0.1),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rotating spoon emoji
                      Transform.rotate(
                        angle: widget.progress * math.pi * 4,
                        child: const Text('\u{1F944}',
                            style: TextStyle(fontSize: 42)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.progress >= 1
                            ? '\u{2728} Done!'
                            : 'Swirl to Stir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: widget.progress >= 1
                              ? PWColors.mint
                              : PWColors.navy.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hold Action — lid with steam + progress dots
  // ---------------------------------------------------------------------------

  Widget _buildHoldAction(BuildContext context) {
    final dotsFilled = (widget.progress * 3).floor().clamp(0, 3);

    return GestureDetector(
      onTapDown: (_) => _startHolding(),
      onTapUp: (_) => _stopHolding(),
      onTapCancel: _stopHolding,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 260,
          height: 190,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _holding
                  ? [
                      PWColors.yellow.withValues(alpha: 0.3),
                      PWColors.coral.withValues(alpha: 0.15),
                    ]
                  : [Colors.white, Colors.white],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _holding
                  ? PWColors.yellow
                  : PWColors.navy.withValues(alpha: 0.2),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (_holding ? PWColors.yellow : PWColors.navy)
                    .withValues(alpha: 0.14),
                blurRadius: _holding ? 16 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Steam animation when holding
                if (_holding)
                  AnimatedBuilder(
                    animation: _idleAnim,
                    builder: (context, child) {
                      final opacity = 0.3 + _idleAnim.value * 0.5;
                      final rise = _idleAnim.value * 8;
                      return Transform.translate(
                        offset: Offset(0, -rise),
                        child: Opacity(
                          opacity: opacity,
                          child: child,
                        ),
                      );
                    },
                    child: const Text(
                      '\u{2668}\u{FE0F}',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                // Lid emoji
                AnimatedScale(
                  scale: _holding ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Text('\u{1FA98}',
                      style: TextStyle(fontSize: 46)),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.progress >= 1
                      ? '\u{2728} Cooked!'
                      : _holding
                          ? 'Keep holding...'
                          : 'Hold Lid to Cook',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: widget.progress >= 1
                        ? PWColors.mint
                        : PWColors.navy.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final filled = i < dotsFilled;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: filled ? 16 : 12,
                      height: filled ? 16 : 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? PWColors.coral
                            : PWColors.navy.withValues(alpha: 0.12),
                        border: Border.all(
                          color: filled
                              ? PWColors.coral
                              : PWColors.navy.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shake Action — bouncing shaker
  // ---------------------------------------------------------------------------

  Widget _buildShakeAction(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final delta = math.min(details.delta.dx.abs() / 260, 0.08);
        widget.onProgressDelta(delta);
      },
      child: Center(
        child: AnimatedBuilder(
          animation: _idleAnim,
          builder: (context, child) {
            final shake = math.sin(_idleAnim.value * math.pi * 2) * 8;
            return Transform.translate(
              offset: Offset(shake, 0),
              child: child,
            );
          },
          child: Container(
            width: 250,
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  PWColors.coral.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.progress >= 1
                    ? PWColors.mint
                    : PWColors.coral.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: PWColors.coral.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('\u{1F9C2}',
                      style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: PWColors.navy.withValues(alpha: 0.35),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.progress >= 1
                            ? '\u{2728} Done!'
                            : 'Shake Left & Right',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: widget.progress >= 1
                              ? PWColors.mint
                              : PWColors.navy.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: PWColors.navy.withValues(alpha: 0.35),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

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
    Future<void>.delayed(const Duration(milliseconds: 150), () {
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

// ---------------------------------------------------------------------------
// Draggable Chip
// ---------------------------------------------------------------------------

class _DraggableChip extends StatelessWidget {
  const _DraggableChip({
    required this.opacity,
    required this.emoji,
    required this.label,
    this.isActive = false,
  });

  final double opacity;
  final String emoji;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isActive
                ? PWColors.coral
                : PWColors.coral.withValues(alpha: 0.5),
            width: isActive ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isActive ? PWColors.coral : PWColors.navy)
                  .withValues(alpha: isActive ? 0.25 : 0.12),
              blurRadius: isActive ? 16 : 10,
              offset: const Offset(0, 4),
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
                style: const TextStyle(fontSize: 36),
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
                    fontSize: 13,
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

// ---------------------------------------------------------------------------
// Progress Bar
// ---------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.label});

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDone = progress >= 1.0;

    return Container(
      decoration: BoxDecoration(
        color: isDone
            ? PWColors.mint.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? PWColors.mint.withValues(alpha: 0.3)
              : PWColors.navy.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.timelapse_rounded,
            size: 18,
            color: isDone
                ? PWColors.mint
                : PWColors.navy.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDone ? 'Complete!' : 'Progress $label',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDone
                            ? PWColors.mint
                            : PWColors.navy.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: PWColors.navy.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? PWColors.mint : PWColors.coral,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
