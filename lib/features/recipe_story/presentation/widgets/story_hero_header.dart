import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/pw_theme.dart';
import '../../domain/character_expression.dart';

class StoryHeroHeader extends StatefulWidget {
  const StoryHeroHeader({
    super.key,
    required this.countryId,
    required this.expression,
    this.actionKey,
  });

  final String countryId;
  final CharacterExpression expression;
  final String? actionKey;

  @override
  State<StoryHeroHeader> createState() => _StoryHeroHeaderState();
}

class _StoryHeroHeaderState extends State<StoryHeroHeader>
    with TickerProviderStateMixin {
  late final AnimationController _bobController;
  late final AnimationController _bubbleController;
  String _lastMessage = '';

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _lastMessage = widget.expression.message;
  }

  @override
  void didUpdateWidget(covariant StoryHeroHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expression.message != _lastMessage) {
      _lastMessage = widget.expression.message;
      _bubbleController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bobController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterEmoji =
        widget.expression.characterEmoji ??
        characterForCountry(widget.countryId);
    final name = characterNameForCountry(widget.countryId);
    final moodEmoji = widget.expression.moodEmoji;
    final color = _moodColor(widget.expression.mood);

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Colors.white, color.withValues(alpha: 0.12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.26), width: 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            AnimatedBuilder(
              animation: _bobController,
              builder: (context, child) {
                final bob = math.sin(_bobController.value * math.pi) * 5;
                return Transform.translate(
                  offset: Offset(0, bob),
                  child: child,
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.18),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      characterEmoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        moodEmoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _bubbleController,
                  curve: Curves.elasticOut,
                ),
                alignment: Alignment.centerLeft,
                child: Container(
                  key: ValueKey<String>(widget.expression.message),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            '$name says',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.actionKey != null)
                            Text(
                              _scenePropForAction(widget.actionKey!),
                              style: const TextStyle(fontSize: 14),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.expression.message,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _moodColor(CharacterMood mood) {
    return switch (mood) {
      CharacterMood.excited => PWColors.coral,
      CharacterMood.encouraging => PWColors.blue,
      CharacterMood.focused => PWColors.navy,
      CharacterMood.proud => PWColors.mint,
      CharacterMood.celebrating => PWColors.yellow,
    };
  }

  String _scenePropForAction(String actionKey) {
    return switch (actionKey) {
      'tap_bowl' => '🥣',
      'tap_chop' => '🔪',
      'drag_oil_to_pot' => '🫙',
      'drag_tomato_mix' => '🍅',
      'tap_spice_shaker' => '🧂',
      'stir_circle' || 'stir' => '🥄',
      'hold_to_cook' || 'hold' || 'hold_cook' => '🤫',
      _ => '🍳',
    };
  }
}
