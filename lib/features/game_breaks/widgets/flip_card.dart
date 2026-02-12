import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/game_break_types.dart';

/// An animated card that flips between a face-down (star) and face-up (emoji)
/// state. Used in the Memory Match game.
class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.card,
    required this.isRevealed,
    required this.isMatched,
    required this.onTap,
  });

  final MatchCard card;
  final bool isRevealed;
  final bool isMatched;
  final VoidCallback onTap;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _showFront = widget.isRevealed || widget.isMatched;
    if (_showFront) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldShow = widget.isRevealed || widget.isMatched;
    if (shouldShow != _showFront) {
      _showFront = shouldShow;
      if (shouldShow) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isFront = _animation.value >= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        color: PWColors.blue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '\u{2B50}', // ⭐
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isMatched
              ? PWColors.mint.withValues(alpha: 0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isMatched
                ? PWColors.mint
                : PWColors.navy.withValues(alpha: 0.12),
            width: widget.isMatched ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.card.emoji,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 4),
            Text(
              widget.card.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: PWColors.navy.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
